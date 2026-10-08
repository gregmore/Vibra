#!/usr/bin/env python3
"""Inventory or erase explicitly tagged Vibra fixtures and known legacy bots."""
import argparse
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request

LEGACY_EMAILS = {
    "giulia_bot@vibra.local", "marco_bot@vibra.local", "sofia_bot@vibra.local",
    "luca_metal@vibra.local", "alessia_kpop@vibra.local", "chiara_latino@vibra.local",
    "davide_indie@vibra.local", "bot1_martina@vibra.test", "bot2_ale@vibra.test",
    "bot3_giulia@vibra.test", "bot4_leo@vibra.test", "bot5_elena@vibra.test",
    "bot6_marco@vibra.test",
}
LEGACY_MOCKS = {
    "mock1@vibra.app": "11111111-1111-1111-1111-111111111111",
    "mock2@vibra.app": "22222222-2222-2222-2222-222222222222",
    "mock3@vibra.app": "33333333-3333-3333-3333-333333333333",
}


def owned(user):
    metadata = user.get("app_metadata") or {}
    return (metadata.get("is_test_user") is True or metadata.get("seed_namespace") == "vibra_e2e_v1"
            or user.get("email") in LEGACY_EMAILS
            or (user.get("email") in LEGACY_MOCKS
                and LEGACY_MOCKS[user["email"]] == user.get("id")))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project-ref", required=True, help="Explicit hosted Supabase project to inspect")
    parser.add_argument("--apply", action="store_true", help="Erase only the identified demo records")
    args = parser.parse_args()
    url = os.environ.get("SUPABASE_URL", "").rstrip("/")
    key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY", "")
    if not key or url != f"https://{args.project_ref}.supabase.co":
        raise SystemExit("Set the matching SUPABASE_URL and server-only SUPABASE_SERVICE_ROLE_KEY")

    def request(path, method="GET", body=None, headers=None):
        req = urllib.request.Request(url + path, method=method,
            data=None if body is None else json.dumps(body).encode(),
            headers={"apikey": key, "Authorization": "Bearer " + key,
                     "Content-Type": "application/json", **(headers or {})})
        try:
            with urllib.request.urlopen(req, timeout=30) as response:
                raw = response.read()
                return json.loads(raw) if raw else None
        except urllib.error.HTTPError as error:
            raise RuntimeError(f"Admin operation failed (HTTP {error.code}); check migrations and credentials") from None

    users = []
    for page in range(1, 10001):
        batch = request(f"/auth/v1/admin/users?page={page}&per_page=1000")["users"]
        users.extend(user for user in batch if owned(user))
        if len(batch) < 1000:
            break
    else:
        raise RuntimeError("User inventory exceeded its safe page limit")
    # A missing segmentation column fails before any deletion.
    events = request("/rest/v1/events?select=id&is_test_data=eq.true&limit=1000")
    print(json.dumps({"project_ref": args.project_ref, "demo_accounts": len(users),
                      "demo_events_first_batch": len(events), "apply": args.apply}))
    if not args.apply:
        return
    for user in users:
        # Re-check ownership immediately before any irreversible operation.
        current = request("/auth/v1/admin/users/" + user["id"])
        if not owned(current):
            raise RuntimeError("Demo ownership changed; erasure stopped")
        rpc = {"p_user_id": user["id"]}
        request("/rest/v1/rpc/begin_account_erasure", "POST", rpc)
        for _ in range(100):
            objects = request("/rest/v1/rpc/list_account_storage_objects", "POST", rpc)
            if not objects:
                break
            buckets = {}
            for obj in objects:
                buckets.setdefault(obj["bucket_id"], []).append(obj["name"])
            for bucket, paths in buckets.items():
                request("/storage/v1/object/" + urllib.parse.quote(bucket, safe=""), "DELETE", {"prefixes": paths})
        else:
            raise RuntimeError("Storage erasure exceeded its safe batch limit")
        request("/auth/v1/admin/users/" + user["id"], "DELETE")
    total_events = 0
    while events:
        ids = ",".join(row["id"] for row in events)
        # Repeat the ownership condition in the deletion itself.
        deleted = request(f"/rest/v1/events?is_test_data=eq.true&id=in.({ids})", "DELETE",
                          headers={"Prefer": "return=representation"})
        total_events += len(deleted or [])
        events = request("/rest/v1/events?select=id&is_test_data=eq.true&limit=1000")
        if events and not deleted:
            raise RuntimeError("Event erasure made no progress")
    print(json.dumps({"deleted_demo_accounts": len(users), "deleted_demo_events": total_events}))


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError, RuntimeError) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
