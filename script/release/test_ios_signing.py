import copy
import hashlib
import unittest
from datetime import datetime, timedelta, timezone

from ios_signing import assess_profile


class AppStoreSigningTest(unittest.TestCase):
    def setUp(self):
        self.now = datetime(2026, 10, 18, tzinfo=timezone.utc)
        self.team = "EXAMPLE123"
        self.cert = b"profile certificate fixture"
        self.identities = {hashlib.sha1(self.cert).hexdigest().upper()}
        self.profile = {
            "TeamIdentifier": [self.team],
            "AppIdentifierPrefix": [self.team],
            "ExpirationDate": self.now + timedelta(days=1),
            "DeveloperCertificates": [self.cert],
            "Entitlements": {
                "application-identifier": self.team + ".com.vibra.app",
                "get-task-allow": False,
                "aps-environment": "production",
                "com.apple.developer.applesignin": ["Default"],
            },
        }

    def assess(self, profile=None, identities=None):
        return assess_profile(profile or self.profile,
                              self.identities if identities is None else identities,
                              self.team, self.now)

    def test_complete_profile_and_matching_identity_are_required(self):
        self.assertTrue(self.assess()["ready"])
        self.assertIn("matching_signing_identity_unavailable", self.assess(identities=set())["blockers"])
        unrelated = {hashlib.sha1(b"other team's private key").hexdigest().upper()}
        self.assertFalse(self.assess(identities=unrelated)["ready"])

    def test_expiry_boundary_and_naive_plist_timestamp(self):
        self.profile["ExpirationDate"] = self.now.replace(tzinfo=None)
        self.assertIn("expired_or_missing_expiration", self.assess()["blockers"])
        self.profile["ExpirationDate"] += timedelta(seconds=1)
        self.assertTrue(self.assess()["ready"])

    def test_wrong_team_or_bundle_cannot_use_other_installed_identity(self):
        self.profile["TeamIdentifier"] = ["OTHERTEAM1"]
        self.profile["Entitlements"]["application-identifier"] = "OTHERTEAM1.com.vibra.app"
        self.assertIn("wrong_team", self.assess()["blockers"])
        self.assertIn("wrong_app_identifier", self.assess()["blockers"])

    def test_development_adhoc_enterprise_and_personal_profiles_are_rejected(self):
        for field, value in [("ProvisionedDevices", ["synthetic-device"]),
                             ("ProvisionsAllDevices", True), ("LocalProvision", True)]:
            with self.subTest(field=field):
                profile = copy.deepcopy(self.profile)
                profile[field] = value
                self.assertFalse(self.assess(profile)["ready"])
        self.profile["Entitlements"]["get-task-allow"] = True
        self.assertFalse(self.assess()["ready"])

    def test_missing_or_development_capabilities_are_rejected(self):
        self.profile["Entitlements"]["aps-environment"] = "development"
        del self.profile["Entitlements"]["com.apple.developer.applesignin"]
        blockers = self.assess()["blockers"]
        self.assertIn("missing_production_push", blockers)
        self.assertIn("missing_sign_in_with_apple", blockers)

    def test_legacy_app_id_prefix_is_independent_of_team_id(self):
        self.profile["AppIdentifierPrefix"] = ["LEGACY1234"]
        self.profile["Entitlements"]["application-identifier"] = "LEGACY1234.com.vibra.app"
        self.profile["Entitlements"]["com.apple.developer.team-identifier"] = self.team
        self.assertTrue(self.assess()["ready"])
        self.profile["Entitlements"]["application-identifier"] += ".other"
        self.assertIn("wrong_app_identifier", self.assess()["blockers"])

    def test_entitlement_team_must_match_profile_team(self):
        self.profile["Entitlements"]["com.apple.developer.team-identifier"] = "OTHERTEAM1"
        self.assertIn("wrong_entitlement_team", self.assess()["blockers"])


if __name__ == "__main__":
    unittest.main()
