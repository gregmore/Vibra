import unittest

from app_config import public_defines


class PublicAppConfigTest(unittest.TestCase):
    def setUp(self):
        self.config = {
            'support_email': 'support@vibra.invalid',
            'privacy_email': 'privacy@vibra.invalid',
            'legal_email': 'legal@vibra.invalid',
            'legal_name': 'Fixture owner',
            'privacy_url': 'https://vibra.invalid/privacy.html',
            'terms_url': 'https://vibra.invalid/termini.html',
            'support_url': 'https://vibra.invalid/supporto.html',
            'account_deletion_url': 'https://vibra.invalid/elimina-account.html',
        }

    def test_only_public_ui_fields_are_copied(self):
        self.config.update(legal_address='Private fixture address',
                           storePassword='fixture-only-value',
                           SUPABASE_SERVICE_ROLE_KEY='fixture-only-value')
        result = public_defines(self.config)
        self.assertEqual(len(result), 9)
        self.assertFalse(any('Private' in value or 'fixture-only' in value
                             for value in result.values()))

    def test_base_url_is_derived_and_can_be_explicit(self):
        self.assertEqual(public_defines(self.config)['VIBRA_PUBLIC_SITE_URL'],
                         'https://vibra.invalid')
        self.config['public_site_url'] = 'https://vibra.invalid/app/'
        self.assertEqual(public_defines(self.config)['VIBRA_PUBLIC_SITE_URL'],
                         'https://vibra.invalid/app')

    def test_missing_and_example_metadata_cannot_make_release_config(self):
        for value in ['', 'support@example.com', 'YOUR_CONTACT']:
            with self.subTest(value=value):
                self.config['support_email'] = value
                with self.assertRaises(ValueError):
                    public_defines(self.config)

    def test_http_links_are_rejected_before_writing_build_defines(self):
        self.config['privacy_url'] = 'http://vibra.invalid/privacy.html'
        with self.assertRaises(ValueError):
            public_defines(self.config)


if __name__ == '__main__':
    unittest.main()
