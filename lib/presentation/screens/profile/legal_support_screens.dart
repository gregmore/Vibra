import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/vibra_glassmorphic_card.dart';

class _InfoSection {
  const _InfoSection({required this.title, required this.body});

  final String title;
  final String body;
}

class _StaticInfoScreen extends StatelessWidget {
  const _StaticInfoScreen({
    required this.title,
    required this.subtitle,
    required this.sections,
    this.publicUrl,
  });

  final String title;
  final String subtitle;
  final List<_InfoSection> sections;
  final String? publicUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.vibraTokens;

    return VibraPageScaffold(
      appBar: AppBar(title: Text(title)),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(color: t.textSecondary),
          ),
          const SizedBox(height: 20),
          Text(AppConstants.legalOwner, style: theme.textTheme.bodyMedium),
          if (publicUrl != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse(publicUrl!),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(title),
              ),
            ),
          ...sections.asMap().entries.map(
            (entry) =>
                VibraGlassmorphicCard(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.value.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry.value.body,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: t.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: (80 * entry.key).ms, duration: 400.ms)
                    .slideY(begin: 0.03),
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
      publicUrl: AppConstants.privacyUrl,
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
      publicUrl: AppConstants.termsUrl,
      subtitle: l10n.legalTermsSubtitle,
      sections: [
        _InfoSection(title: l10n.legalTermsSec1, body: l10n.legalTermsBody1),
        _InfoSection(title: l10n.legalTermsSec2, body: l10n.legalTermsBody2),
        _InfoSection(title: l10n.legalTermsSec3, body: l10n.legalTermsBody3),
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
      publicUrl: AppConstants.supportUrl,
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
          body: l10n.legalAboutBody1(
            AppConstants.appVersion,
            AppConstants.appBuildNumber,
          ),
        ),
        _InfoSection(
          title: l10n.legalAboutSec2,
          body: l10n.legalAboutBody2(
            AppConstants.androidPackageName,
            AppConstants.iOSBundleId,
          ),
        ),
        _InfoSection(title: l10n.legalAboutSec3, body: l10n.legalAboutBody3),
        _InfoSection(
          title: l10n.legalAboutSec4,
          body: l10n.legalAboutBody4(AppConstants.supportEmail),
        ),
      ],
    );
  }
}
