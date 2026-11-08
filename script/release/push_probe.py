#!/usr/bin/env python3
"""Probe one explicitly selected FCM test device; validate-only is the default.

Credentials and device tokens are read from local files or environment variables,
never command-line values. No users are queried and no inbox records are created.
An accepted send is not proof that a phone received or opened the notification.
"""
import argparse
import base64
import json
import os
from pathlib import Path
import plistlib
import re
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request
import uuid

ROOT = Path(__file__).resolve().parents[2]
TOKEN_URL = "https://oauth2.googleapis.com/token"
SCOPE = "https://www.googleapis.com/auth/firebase.messaging"
APP_ID = "com.vibra.app"


class ProbeError(Exception):
    """An operator-safe error; never include provider response text or secrets."""


def local_config():
    android = json.loads((ROOT / "android/app/google-services.json").read_text())
    apple = plistlib.loads((ROOT / "ios/Runner/GoogleService-Info.plist").read_bytes())
    project = android.get("project_info", {}).get("project_id")
    if not project or project != apple.get("PROJECT_ID"):
        raise ProbeError("Android and Apple Firebase projects must match")
    if not any(row.get("client_info", {}).get("android_client_info", {})
               .get("package_name") == APP_ID for row in android.get("client", [])):
        raise ProbeError("Android Firebase configuration must contain com.vibra.app")
    if apple.get("BUNDLE_ID") != APP_ID:
        raise ProbeError("Apple Firebase configuration must use com.vibra.app")
    return project


def read_account(path):
    raw = (path.read_text() if path else
           os.environ.get("FCM_SERVICE_ACCOUNT_JSON") or
           os.environ.get("FIREBASE_SERVICE_ACCOUNT_JSON"))
    if not raw:
        raise ProbeError("Provide --service-account or the server service-account JSON environment variable")
    account = json.loads(raw)
    if (not isinstance(account, dict) or account.get("type") != "service_account" or
            not account.get("client_email") or not account.get("private_key") or
            not re.fullmatch(r"[a-z][a-z0-9-]{4,61}[a-z0-9]", account.get("project_id", ""))):
        raise ProbeError("Invalid service-account configuration")
    return account


def json_request(url, body, headers):
    request = urllib.request.Request(url, data=body, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(request, timeout=20) as response:
            return response.status, json.load(response)
    except urllib.error.HTTPError as error:
        try:
            result = json.loads(error.read())
        except (ValueError, OSError):
            result = {}
        return error.code, result


def access_token(account):
    def encode(value):
        return base64.urlsafe_b64encode(json.dumps(value, separators=(",", ":"))
                                       .encode()).decode().rstrip("=")
    now = int(time.time())
    unsigned = encode({"alg": "RS256", "typ": "JWT"}) + "." + encode({
        "iss": account["client_email"], "scope": SCOPE, "aud": TOKEN_URL,
        "iat": now, "exp": now + 3600,
    })
    # OpenSSL reads the private key from an owner-only temporary file. Neither
    # the key nor the assertion is passed in the process arguments or printed.
    with tempfile.TemporaryDirectory(prefix="vibra-push-auth-") as directory:
        key = Path(directory) / "key.pem"
        with os.fdopen(os.open(key, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600), "w") as stream:
            stream.write(account["private_key"])
        signed = subprocess.run(
            ["openssl", "dgst", "-sha256", "-sign", str(key)],
            input=unsigned.encode(), capture_output=True, timeout=15,
        )
        if signed.returncode:
            raise ProbeError("Unable to sign the Google OAuth assertion")
    signature = base64.urlsafe_b64encode(signed.stdout).decode().rstrip("=")
    status, result = json_request(TOKEN_URL, urllib.parse.urlencode({
        "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
        "assertion": unsigned + "." + signature,
    }).encode(), {"Content-Type": "application/x-www-form-urlencoded"})
    if status != 200 or not isinstance(result, dict) or not result.get("access_token"):
        raise ProbeError("Google OAuth authorization failed; check service-account access")
    return result["access_token"]


def payload(args, device_token):
    if not device_token or any(character.isspace() for character in device_token):
        raise ProbeError("Provide one nonempty test-device token using --token-file or FCM_TEST_DEVICE_TOKEN")
    if args.send and not args.confirm_test_device:
        raise ProbeError("An actual send requires --send --confirm-test-device for your selected test phone")
    data = {}
    if args.event_id:
        data = {"type": "event_alert", "event_id": str(uuid.UUID(args.event_id))}
    elif args.sender_id:
        data = {"type": "chat_message", "sender_id": str(uuid.UUID(args.sender_id))}
    return {"validate_only": not args.send, "message": {
        "token": device_token,
        "notification": {"title": "Prova notifiche Vibra", "body": "Notifica del dispositivo di collaudo."},
        **({"data": data} if data else {}),
        "android": {"priority": "HIGH", "notification": {"sound": "default"}},
        "apns": {"headers": {"apns-priority": "10"}, "payload": {"aps": {"sound": "default"}}},
    }}


def probe(args):
    project = local_config()
    report = {"firebase_project": project, "app_id": APP_ID,
              "mode": "local_config" if args.local_only else "send" if args.send else "validate_only",
              "device_delivery_verified": False, "apns_configuration_verified": False}
    if args.local_only:
        return {**report, "ok": True, "result": "local_configuration_matches"}
    # Complete all local checks before authenticating or making requests.
    device_token = (args.token_file.read_text() if args.token_file else
                    os.environ.get("FCM_TEST_DEVICE_TOKEN", "")).strip()
    body = payload(args, device_token)
    account = read_account(args.service_account)
    if account["project_id"] != project:
        raise ProbeError("The service account belongs to a different Firebase project")
    authorization = access_token(account)
    status, result = json_request(
        "https://fcm.googleapis.com/v1/projects/" + project + "/messages:send",
        json.dumps(body).encode(),
        {"Content-Type": "application/json", "Authorization": "Bearer " + authorization},
    )
    ok = 200 <= status < 300
    report.update(ok=ok, http_status=status,
                  result=("send_accepted" if args.send else "validation_accepted") if ok else "request_rejected")
    # Deliberately omit the provider message, returned message ID and payload.
    error = result.get("error", {}) if isinstance(result, dict) else {}
    error_status = error.get("status") if isinstance(error, dict) else None
    if isinstance(error_status, str) and re.fullmatch(r"[A-Z_]{1,50}", error_status):
        report["provider_status"] = error_status
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--local-only", action="store_true", help="Check app/project configuration without network access")
    parser.add_argument("--service-account", type=Path, help="Private service-account JSON kept outside the repository")
    parser.add_argument("--token-file", type=Path, help="File containing only the FCM token of your test phone")
    parser.add_argument("--send", action="store_true", help="Send to the explicitly supplied test-device token")
    parser.add_argument("--confirm-test-device", action="store_true", help="Confirm this is your test device and its push consent is enabled")
    target = parser.add_mutually_exclusive_group()
    target.add_argument("--event-id", help="Existing event UUID for testing notification navigation")
    target.add_argument("--sender-id", help="Test chat participant UUID for testing notification navigation")
    parser.add_argument("--report", type=Path, help="Write the same redacted JSON result to a local file")
    args = parser.parse_args()
    try:
        result = probe(args)
    except ProbeError as error:
        result = {"ok": False, "error": str(error), "device_delivery_verified": False}
    except (OSError, ValueError, TypeError, KeyError, subprocess.SubprocessError):
        result = {"ok": False, "error": "Unable to complete the push probe; check local files, UUIDs and connectivity",
                  "device_delivery_verified": False}
    rendered = json.dumps(result, indent=2)
    print(rendered)
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(rendered + "\n")
    return 0 if result["ok"] else 1


if __name__ == "__main__":
    sys.exit(main())
