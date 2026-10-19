#!/usr/bin/env python3
"""Check store prerequisites without printing credentials or changing services."""
import argparse
import base64
import json
import plistlib
import re
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

from ios_signing import signing_report
from app_config import public_defines

ROOT = Path(__file__).resolve().parents[2]
APP_ID = "com.vibra.app"
PUBLIC_KEYS = {"SUPABASE_URL", "SUPABASE_ANON_KEY", "SPOTIFY_CLIENT_ID",
               "SPOTIFY_REDIRECT_URI", "GOOGLE_WEB_CLIENT_ID", "GOOGLE_IOS_CLIENT_ID",
               "BANDSINTOWN_APP_ID"}


def backend_checks(project_ref):
    """Read hosted deployment metadata; do not fetch or print server secrets."""
    errors = []
    def metadata(arguments):
        result = subprocess.run(
            ["supabase", *arguments, "--output-format", "json", "--agent", "yes"],
            capture_output=True, text=True, timeout=120,
        )
        if result.returncode:
            raise RuntimeError("Supabase metadata check failed")
        return json.loads(result.stdout)
    try:
        linked_ref = (ROOT / "supabase/.temp/project-ref").read_text().strip()
        if linked_ref != project_ref:
            return ["The linked Supabase project differs from the production project"]
        migrations = metadata(["migration", "list", "--linked"])
        applied = {row["remote"] for row in migrations["migrations"] if row["remote"]}
        local = {p.name.split("_", 1)[0] for p in (ROOT / "supabase/migrations").glob("*.sql")}
        missing = sorted(local - applied)
        if missing:
            errors.append(f"Production database is missing {len(missing)} migrations: " + ", ".join(missing))
        deployed = {row["slug"]: row for row in metadata(["functions", "list", "--project-ref", project_ref])["functions"]}
        required = {p.parent.name for p in (ROOT / "supabase/functions").glob("*/index.ts")}
        absent = sorted(name for name in required if deployed.get(name, {}).get("status") != "ACTIVE")
        if absent:
            errors.append("Missing active production Edge Functions: " + ", ".join(absent))
        if "seed-compatible-users" in deployed:
            errors.append("Remove the hosted seed-compatible-users demo endpoint")
        # This endpoint returns names and hashes only, never secret values.
        secrets = {row["name"] for row in metadata(["secrets", "list", "--project-ref", project_ref])["secrets"]}
        for name in ("SPOTIFY_CLIENT_SECRET", "SPOTIFY_TOKEN_ENCRYPTION_KEY"):
            if name not in secrets:
                errors.append(f"Missing production backend secret: {name}")
        if not secrets.intersection({"FCM_SERVICE_ACCOUNT_JSON", "FIREBASE_SERVICE_ACCOUNT_JSON"}):
            errors.append("Missing production backend secret: FCM_SERVICE_ACCOUNT_JSON")
        if "VIBRA_NOTIFICATION_WORKER_KEY" not in secrets:
            errors.append("Missing production backend secret: VIBRA_NOTIFICATION_WORKER_KEY (must match the notification credential in Vault)")
    except (OSError, subprocess.TimeoutExpired, RuntimeError, ValueError, KeyError, TypeError):
        errors.append("Unable to verify the hosted Supabase deployment")
    return errors


def env_file(path):
    values = {}
    if path.exists():
        for line in path.read_text().splitlines():
            key, sep, value = line.partition("=")
            if sep and not key.lstrip().startswith("#"):
                values[key.strip()] = value.strip().strip("\"'")
    return values


def check(platform, config_path, technical_only=False, online=False):
    errors = []
    notes = []
    def require(condition, message):
        if not condition:
            errors.append(message)

    public = env_file(ROOT / ".env.public")
    require(bool(public), "Generate .env.public with script/security/prepare_client_env.py")
    require(not set(public) - PUBLIC_KEYS, "The mobile configuration contains keys outside the public allowlist")
    for key in ("SUPABASE_URL", "SUPABASE_ANON_KEY", "SPOTIFY_CLIENT_ID", "GOOGLE_WEB_CLIENT_ID", "GOOGLE_IOS_CLIENT_ID"):
        value = public.get(key, "")
        require(bool(value) and not re.search(r"YOUR_|INSERT|PLACEHOLDER|example", value, re.I), f"Missing production value: {key}")
    url = urllib.parse.urlparse(public.get("SUPABASE_URL", ""))
    require(url.scheme == "https" and (url.hostname or "").endswith(".supabase.co"), "Supabase must use the production HTTPS project URL")
    require(public.get("SPOTIFY_REDIRECT_URI") == APP_ID + "://callback", "Spotify redirect must match the native app URL scheme")
    key = public.get("SUPABASE_ANON_KEY", "")
    require(not key.startswith("sb_secret_"), "A Supabase secret key must never be bundled")
    if key.count(".") == 2:
        try:
            part = key.split(".")[1]
            claims = json.loads(base64.urlsafe_b64decode(part + "=" * (-len(part) % 4)))
            require(claims.get("role") == "anon", "The Supabase client JWT must have the anon role")
            require(claims.get("ref") in (None, (url.hostname or "").split(".")[0]), "The Supabase client key belongs to another project")
        except (ValueError, KeyError):
            errors.append("Invalid Supabase public JWT")
    else:
        require(key.startswith("sb_publishable_"), "Use a Supabase publishable key or anon JWT")

    manifest = plistlib.loads((ROOT / "ios/Runner/PrivacyInfo.xcprivacy").read_bytes())
    require(manifest.get("NSPrivacyTracking") is False, "Verify the iOS tracking declaration")
    require(bool(manifest.get("NSPrivacyCollectedDataTypes")), "Missing iOS privacy declarations")
    pubspec = (ROOT / "pubspec.yaml").read_text()
    version = re.search(r"^version:\s*(\S+)", pubspec, re.M).group(1)
    require(not re.search(r"^\s*-\s*\.env\s*$", pubspec, re.M), "The raw .env must not be a Flutter asset")
    require(not re.search(r"^\s+integration_test:\s*$", pubspec, re.M), "Keep the native integration-test plugin outside the production app")
    for family in ("Inter", "Syne"):
        require(f"- family: {family}" in pubspec, f"Declare bundled {family} fonts")
        require((ROOT / f"assets/fonts/{family}-SemiBold.ttf").exists(), f"Missing bundled {family} font")
    font_assets = re.findall(r"^\s*- asset:\s*(assets/fonts/\S+\.ttf)\s*$", pubspec, re.M)
    require(bool(font_assets), "Bundle fonts for first launch without a network connection")
    for asset in font_assets:
        require((ROOT / asset).is_file(), f"Missing declared font: {asset}")
    require(not any((ROOT / p).exists() for p in (
        "script/seed_bots.dart", "script/seed_test_data.mjs", "supabase/seed_demo_bots.sql",
        "supabase/seed_mock_matches.sql", "supabase/seed_social_data.sql",
        "supabase/functions/seed-compatible-users/index.ts")), "Demo generators remain in the project")

    android_firebase = ROOT / "android/app/google-services.json"
    ios_firebase = ROOT / "ios/Runner/GoogleService-Info.plist"
    require(android_firebase.exists(), "Missing Android Firebase configuration")
    require(ios_firebase.exists(), "Missing iOS Firebase configuration")
    if android_firebase.exists():
        firebase = json.loads(android_firebase.read_text())
        require(any(c.get("client_info", {}).get("android_client_info", {}).get("package_name") == APP_ID
                    for c in firebase.get("client", [])), "Android Firebase package differs from the app")
    if ios_firebase.exists():
        ios_values = plistlib.loads(ios_firebase.read_bytes())
        require(ios_values.get("BUNDLE_ID") == APP_ID, "iOS Firebase bundle identifier differs from the app")
        if android_firebase.exists():
            require(ios_values.get("PROJECT_ID") == firebase.get("project_info", {}).get("project_id"), "Android and iOS Firebase projects differ")

    config = {}
    if not technical_only:
        require(config_path.exists(), "Fill release/store-config.json from script/release/store_config.example.json")
        if config_path.exists():
            config = json.loads(config_path.read_text())
        require(url.hostname == config.get("supabase_project_ref", "") + ".supabase.co", "Production Supabase project must match store-config.json")
        for name in ("legal_name", "legal_address"):
            require(bool(str(config.get(name, "")).strip()), f"Confirm {name} in store-config.json")
        constants = (ROOT / "lib/core/constants/app_constants.dart").read_text()
        for name in ("support_email", "privacy_email", "legal_email"):
            email = config.get(name, "")
            require(bool(re.fullmatch(r"[^\s@]+@[^\s@]+\.[^\s@]+", email)), f"Confirm active {name}")
            define_name = "VIBRA_" + name.upper()
            require(define_name in constants, f"Use private release metadata for the in-app {name}")
        try:
            expected_defines = public_defines(config)
            generated_defines = json.loads((ROOT / "release/app-public-defines.json").read_text())
            require(generated_defines == expected_defines, "Regenerate public app metadata from the private release config")
        except (OSError, ValueError, TypeError, AttributeError):
            errors.append("Generate release/app-public-defines.json with script/release/app_config.py")
        for name in ("privacy_url", "terms_url", "support_url", "account_deletion_url"):
            address = config.get(name, "")
            parsed = urllib.parse.urlparse(address)
            valid = parsed.scheme == "https" and bool(parsed.hostname) and parsed.hostname not in ("localhost", "example.com")
            require(valid, f"Provide a public HTTPS {name}")
            if valid and online:
                try:
                    req = urllib.request.Request(address, headers={"User-Agent": "Mozilla/5.0 (compatible; VibraReleasePreflight/1.0)", "Accept": "text/html"})
                    with urllib.request.urlopen(req, timeout=15) as response:
                        require(response.status == 200 and response.url.startswith("https://"), f"{name} is not publicly accessible via HTTPS")
                except (urllib.error.URLError, TimeoutError):
                    errors.append(f"Unable to verify {name}")
        for name in ("backend_release_deployed", "push_delivery_verified", "moderation_operations_verified", "privacy_controls_verified", "physical_device_qa_verified"):
            require(config.get(name) is True, f"Complete and confirm {name}")
        require(isinstance(config.get("spotify_enabled"), bool), "Confirm spotify_enabled for this release")
        if config.get("spotify_enabled") is True:
            require(config.get("spotify_public_access_verified") is True, "Complete and confirm spotify_public_access_verified")
        else:
            require(config.get("spotify_disabled_verified") is True, "Verify disabled Spotify in client, backend and store materials")
        require(config.get("developer_accounts_registered") is True, "Register the developer accounts needed for store publication")
        if online and re.fullmatch(r"[a-z]{20}", config.get("supabase_project_ref", "")):
            errors.extend(backend_checks(config["supabase_project_ref"]))
        elif online:
            errors.append("A valid production project reference is required for backend verification")

        if platform in ("android", "all"):
            props = env_file(ROOT / "android/key.properties")
            for name in ("storePassword", "keyPassword", "keyAlias", "storeFile"):
                require(bool(props.get(name)) and not props.get(name, "").startswith("YOUR_"), f"Missing Android release signing: {name}")
            store = Path(props.get("storeFile", ""))
            if not store.is_absolute():
                store = ROOT / "android/app" / store
            require(store.is_file(), "Android upload keystore does not exist")
            require(store.name != "debug.keystore" and props.get("keyAlias") != "androiddebugkey", "Android release cannot use a debug certificate")
        if platform in ("ios", "all"):
            team = config.get("apple_team_id", "")
            project = (ROOT / "ios/Runner.xcodeproj/project.pbxproj").read_text()
            signing_config = env_file(ROOT / "ios/Flutter/Signing.local.xcconfig")
            require(bool(team) and signing_config.get("VIBRA_DEVELOPMENT_TEAM") == team and
                    'DEVELOPMENT_TEAM = "$(VIBRA_DEVELOPMENT_TEAM)";' in project,
                    "Align ios/Flutter/Signing.local.xcconfig with the private Apple team")
            signing = signing_report(team)
            errors.extend(signing["blockers"])
            notes.append("Apple signing checks include profile expiry, team, bundle, production push, Sign in with Apple and a matching private key")
    else:
        notes.append("Technical checks only. Signing, public legal pages and operational approvals were not evaluated")
    return {"platform": platform, "version": version, "scope": "technical" if technical_only else "store",
            "passed": not errors, "blockers": errors, "notes": notes}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--platform", choices=("ios", "android", "all"), default="all")
    parser.add_argument("--config", type=Path, default=ROOT / "release/store-config.json")
    parser.add_argument("--technical-only", action="store_true")
    parser.add_argument("--online", action="store_true")
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    try:
        result = check(args.platform, args.config, args.technical_only, args.online)
    except (OSError, ValueError, KeyError) as error:
        result = {"passed": False, "blockers": [f"Invalid or missing configuration ({type(error).__name__})"]}
    rendered = json.dumps(result, indent=2)
    print(rendered)
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(rendered + "\n")
    return 0 if result["passed"] else 1


if __name__ == "__main__":
    sys.exit(main())
