#!/usr/bin/env python3
"""Inspect local App Store signing prerequisites without changing the keychain."""
import argparse
import hashlib
import json
import plistlib
import re
import subprocess
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
APP_ID = "com.vibra.app"


def assess_profile(profile, identity_hashes, team_id, now=None):
    now = now or datetime.now(timezone.utc)
    entitlements = profile.get("Entitlements", {})
    expires = profile.get("ExpirationDate")
    if isinstance(expires, datetime) and expires.tzinfo is None:
        expires = expires.replace(tzinfo=timezone.utc)
    certificates = profile.get("DeveloperCertificates", [])
    # Legacy Apple accounts may use an App ID prefix different from Team ID.
    prefixes = profile.get("AppIdentifierPrefix", [team_id])
    app_identifiers = {f"{prefix}.{APP_ID}" for prefix in prefixes}
    reasons = []
    checks = [
        (team_id and team_id in profile.get("TeamIdentifier", []), "wrong_team"),
        (entitlements.get("application-identifier") in app_identifiers, "wrong_app_identifier"),
        (entitlements.get("com.apple.developer.team-identifier", team_id) == team_id, "wrong_entitlement_team"),
        (isinstance(expires, datetime) and expires > now, "expired_or_missing_expiration"),
        (not profile.get("LocalProvision"), "personal_team_profile"),
        (not profile.get("ProvisionedDevices") and not profile.get("ProvisionsAllDevices"), "not_app_store_profile"),
        (entitlements.get("get-task-allow") is False, "debugging_not_disabled"),
        (entitlements.get("aps-environment") == "production", "missing_production_push"),
        ("Default" in entitlements.get("com.apple.developer.applesignin", []), "missing_sign_in_with_apple"),
        (any(hashlib.sha1(cert).hexdigest().upper() in identity_hashes for cert in certificates), "matching_signing_identity_unavailable"),
    ]
    reasons.extend(reason for condition, reason in checks if not condition)
    return {
        "app_identifier": entitlements.get("application-identifier"),
        "team_ids": profile.get("TeamIdentifier", []),
        "expires_at": expires.isoformat() if isinstance(expires, datetime) else None,
        "personal_team": bool(profile.get("LocalProvision")),
        "ready": not reasons,
        "blockers": reasons,
    }


def signing_report(team_id):
    report = {"team_id": team_id, "app_id": APP_ID, "passed": False,
              "profiles": [], "blockers": [], "notes": [
                  "Local prerequisites only; enrollment and export must still succeed in Apple's services."]}
    try:
        identities = subprocess.run(["security", "find-identity", "-v", "-p", "codesigning"],
                                    capture_output=True, text=True, timeout=20)
        if identities.returncode:
            raise RuntimeError("identity_lookup_failed")
        hashes = set(re.findall(r"\b([A-Fa-f0-9]{40})\s+\"", identities.stdout))
        hashes = {value.upper() for value in hashes}
        report["valid_identity_count"] = len(hashes)
        folders = [Path.home() / "Library/MobileDevice/Provisioning Profiles",
                   Path.home() / "Library/Developer/Xcode/UserData/Provisioning Profiles"]
        failures = 0
        for path in sorted({p for folder in folders for p in folder.glob("*.mobileprovision")}):
            try:
                decoded = subprocess.run(["security", "cms", "-D", "-i", str(path)],
                                         capture_output=True, timeout=20)
                if decoded.returncode:
                    failures += 1
                    continue
                profile = plistlib.loads(decoded.stdout)
                report["profiles"].append(assess_profile(profile, hashes, team_id))
            except (OSError, ValueError, TypeError, subprocess.TimeoutExpired):
                failures += 1
        report["unreadable_profile_count"] = failures
        report["passed"] = any(p["ready"] for p in report["profiles"])
        if not report["passed"]:
            report["blockers"].append(
                "No unexpired App Store profile for the configured team and com.vibra.app with production push, Sign in with Apple and an installed matching signing identity")
    except (OSError, RuntimeError, subprocess.TimeoutExpired):
        report["blockers"].append("Unable to inspect local Apple signing prerequisites")
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", type=Path, default=ROOT / "release/store-config.json")
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    try:
        team = json.loads(args.config.read_text()).get("apple_team_id", "")
        result = signing_report(team)
    except (OSError, ValueError, TypeError):
        result = {"passed": False, "blockers": ["Missing or invalid store configuration"]}
    rendered = json.dumps(result, indent=2) + "\n"
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(rendered)
    print(rendered, end="")
    return 0 if result["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
