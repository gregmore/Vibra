import 'package:flutter/material.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../core/constants/app_constants.dart';
import '../../widgets/common/vibra_page_scaffold.dart';

class _InfoSection {
  const _InfoSection({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

class _StaticInfoScreen extends StatelessWidget {
  const _StaticInfoScreen({
    required this.title,
    required this.subtitle,
    required this.sections,
  });

  final String title;
  final String subtitle;
  final List<_InfoSection> sections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return VibraPageScaffold(
      appBar: AppBar(title: Text(title)),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 20),
          ...sections.map(
            (section) => Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(section.title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(section.body, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _StaticInfoScreen(
      title: l10n.legalPrivacyPolicyTitle,
      subtitle: l10n.legalPrivacySubtitle,
      sections: [
        _InfoSection(
          title: l10n.legalPrivacySec1,
          body: l10n.legalPrivacyBody1,
        ),
        _InfoSection(
          title: l10n.legalPrivacySec2,
          body: l10n.legalPrivacyBody2,
        ),
        _InfoSection(
          title: l10n.legalPrivacySec3,
          body: l10n.legalPrivacyBody3,
        ),
        _InfoSection(
          title: l10n.legalPrivacySec4,
          body: l10n.legalPrivacyBody4(AppConstants.privacyEmail),
        ),
      ],
    );
  }
}

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _StaticInfoScreen(
      title: l10n.legalTermsTitle,
      subtitle: l10n.legalTermsSubtitle,
      sections: [
        _InfoSection(
          title: l10n.legalTermsSec1,
          body: l10n.legalTermsBody1,
        ),
        _InfoSection(
          title: l10n.legalTermsSec2,
          body: l10n.legalTermsBody2,
        ),
        _InfoSection(
          title: l10n.legalTermsSec3,
          body: l10n.legalTermsBody3,
        ),
        _InfoSection(
          title: l10n.legalTermsSec4,
          body: l10n.legalTermsBody4(AppConstants.legalEmail),
        ),
      ],
    );
  }
}

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _StaticInfoScreen(
      title: l10n.legalSupportTitle,
      subtitle: l10n.legalSupportSubtitle,
      sections: [
        _InfoSection(
          title: l10n.legalSupportSec1,
          body: l10n.legalSupportBody1(AppConstants.supportEmail),
        ),
        _InfoSection(
          title: l10n.legalSupportSec2,
          body: l10n.legalSupportBody2,
        ),
        _InfoSection(
          title: l10n.legalSupportSec3,
          body: l10n.legalSupportBody3,
        ),
      ],
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _StaticInfoScreen(
      title: l10n.legalAboutTitle,
      subtitle: l10n.legalAboutSubtitle,
      sections: [
        _InfoSection(
          title: l10n.legalAboutSec1,
          body: l10n.legalAboutBody1(AppConstants.appVersion, AppConstants.appBuildNumber),
        ),
        _InfoSection(
          title: l10n.legalAboutSec2,
          body: l10n.legalAboutBody2(AppConstants.androidPackageName, AppConstants.iOSBundleId),
        ),
        _InfoSection(
          title: l10n.legalAboutSec3,
          body: l10n.legalAboutBody3,
        ),
        _InfoSection(
          title: l10n.legalAboutSec4,
          body: l10n.legalAboutBody4(AppConstants.supportEmail),
        ),
      ],
    );
  }
}
