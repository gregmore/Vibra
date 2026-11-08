import 'package:vibra/presentation/localization/user_facing_error.dart';
import '../../../core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../core/theme/vibra_colors.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/spotify_auth_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/vibra_avatar.dart';
import '../../widgets/common/vibra_bottom_sheet.dart';
import '../../widgets/common/vibra_logo.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_settings.dart';
import '../../widgets/common/vibra_surface.dart';
import 'theme_appearance_selector.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeStateProvider);
    final profile = ref.watch(myProfileProvider);
    final hasSpotify =
        profile.spotifyId != null && profile.spotifyId!.isNotEmpty;
    final digestFrequency = ref.watch(digestFrequencyProvider);
    final themePreference = ref.watch(themePreferenceProvider);

    String langName = l10n.settingsLanguageSystem;
    if (currentLocale != null) {
      switch (currentLocale.languageCode) {
        case 'en':
          langName = l10n.langEnglish;
          break;
        case 'it':
          langName = l10n.langItalian;
          break;
        case 'es':
          langName = l10n.langSpanish;
          break;
        case 'fr':
          langName = l10n.langFrench;
          break;
        case 'de':
          langName = l10n.langGerman;
          break;
        case 'pt':
          langName = 'Português';
          break;
        case 'ar':
          langName = 'العربية';
          break;
        case 'zh':
          langName = '简体中文';
          break;
        case 'ja':
          langName = '日本語';
          break;
        case 'hi':
          langName = 'हिन्दी';
          break;
        case 'ru':
          langName = 'Русский';
          break;
        case 'nl':
          langName = 'Nederlands';
          break;
        case 'pl':
          langName = 'Polski';
          break;
        case 'tr':
          langName = 'Türkçe';
          break;
        case 'ko':
          langName = '한국어';
          break;
        case 'el':
          langName = 'Ελληνικά';
          break;
        case 'he':
          langName = 'עברית';
          break;
        case 'sv':
          langName = 'Svenska';
          break;
        case 'no':
          langName = 'Norsk';
          break;
        case 'da':
          langName = 'Dansk';
          break;
        case 'fi':
          langName = 'Suomi';
          break;
        case 'cs':
          langName = 'Čeština';
          break;
        case 'hu':
          langName = 'Magyar';
          break;
        case 'ro':
          langName = 'Română';
          break;
        case 'uk':
          langName = 'Українська';
          break;
        case 'id':
          langName = 'Bahasa Indonesia';
          break;
        case 'vi':
          langName = 'Tiếng Việt';
          break;
        case 'th':
          langName = 'ไทย';
          break;
        case 'bg':
          langName = 'Български';
          break;
        case 'ca':
          langName = 'Català';
          break;
        case 'hr':
          langName = 'Hrvatski';
          break;
        case 'et':
          langName = 'Eesti';
          break;
        case 'lv':
          langName = 'Latviešu';
          break;
        case 'lt':
          langName = 'Lietuvių';
          break;
        case 'sk':
          langName = 'Slovenčina';
          break;
        case 'sl':
          langName = 'Slovenščina';
          break;
        case 'mt':
          langName = 'Malti';
          break;
        case 'tl':
          langName = 'Tagalog';
          break;
        case 'fa':
          langName = 'فارسی';
          break;
        case 'ms':
          langName = 'Bahasa Melayu';
          break;
        case 'sw':
          langName = 'Kiswahili';
          break;
      }
    }

    final t = context.vibraTokens;
    final displayName = profile.displayName ?? profile.username;
    final digestLabel = switch (digestFrequency) {
      'monthly' => l10n.settingsMonthly,
      'never' => l10n.settingsNever,
      _ => l10n.settingsWeekly,
    };

    return VibraPageScaffold(
      useGradient: false,
      appBar: AppBar(titleSpacing: 0, title: Text(l10n.settingsTitle)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          VibraSpacing.pagePadding,
          VibraSpacing.sm,
          VibraSpacing.pagePadding,
          VibraSpacing.huge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Account card ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: VibraSpacing.xxl),
              child: VibraSurface(
                onTap: () => context.push('/edit-profile'),
                semanticLabel: l10n.profileEditTitle,
                padding: const EdgeInsets.all(VibraSpacing.lg),
                child: Row(
                  children: [
                    VibraAvatar(
                      imageUrl: profile.avatarUrl,
                      name: displayName,
                      radius: 28,
                      signalRing: hasSpotify,
                    ),
                    const SizedBox(width: VibraSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: VibraTextStyles.titleMedium.copyWith(
                              color: t.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.settingsEditProfileSub,
                            style: VibraTextStyles.caption.copyWith(
                              color: t.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: t.textMuted),
                  ],
                ),
              ),
            ),

            // ── Notifications ────────────────────────────────────
            VibraSettingsSection(
              label: l10n.settingsNotifications,
              children: [
                Consumer(
                  builder: (context, ref, child) => VibraSettingsSwitch(
                    icon: Icons.notifications_active_outlined,
                    title: l10n.settingsNotifications,
                    subtitle: l10n.settingsNotificationsSub,
                    value: ref.watch(pushEnabledProvider),
                    onChanged: (val) =>
                        ref.read(pushEnabledProvider.notifier).toggle(val),
                  ),
                ),
                // Every category, quiet hours and the daily limit
                // (docs/notification-center.md).
                VibraSettingsTile(
                  icon: Icons.tune_rounded,
                  title: l10n.notifSettingsTitle,
                  subtitle: l10n.notifSettingsSubtitle,
                  onTap: () => context.push('/notification-settings'),
                ),
                VibraSettingsTile(
                  icon: Icons.notifications_none_rounded,
                  title: l10n.notifTitle,
                  subtitle: l10n.notifCenterSubtitle,
                  onTap: () => context.push('/notifications'),
                ),
                if (AppConstants.spotifyEnabled)
                  VibraSettingsTile(
                    icon: Icons.auto_awesome_outlined,
                    title: l10n.settingsMusicWeek,
                    subtitle: l10n.settingsMusicWeekBody,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          digestLabel,
                          style: VibraTextStyles.labelMedium.copyWith(
                            color: t.accentPrimary,
                          ),
                        ),
                        Icon(Icons.unfold_more_rounded, color: t.textMuted),
                      ],
                    ),
                    onTap: () => _pickDigest(context, ref, digestFrequency),
                  ),
              ],
            ),

            // ── Music ────────────────────────────────────────────
            if (AppConstants.spotifyEnabled || hasSpotify)
              VibraSettingsSection(
                label: l10n.settingsSectionMusic,
                children: [
                  VibraSettingsTile(
                    icon: Icons.graphic_eq_rounded,
                    iconColor: VibraPalette.spotifyGreen,
                    iconBackground: VibraPalette.spotifyGreen.withValues(
                      alpha: .14,
                    ),
                    title: l10n.settingsSpotifyAccount,
                    subtitle: !AppConstants.spotifyEnabled
                        ? l10n.spotifyUnavailableBody
                        : hasSpotify
                        ? l10n.profileSpotifyConnected
                        : l10n.settingsSpotifyDisconnected,
                    trailing: hasSpotify
                        ? Text(
                            l10n.settingsSpotifyDisconnect,
                            style: VibraTextStyles.labelMedium.copyWith(
                              color: t.error,
                            ),
                          )
                        : null,
                    onTap: () => _onSpotifyTap(context, ref, hasSpotify),
                  ),
                  if (AppConstants.spotifyEnabled)
                    VibraSettingsTile(
                      icon: Icons.library_music_outlined,
                      title: l10n.musicGenresEntry,
                      subtitle: l10n.musicGenresEntrySub,
                      onTap: () => context.push('/music-genres'),
                    ),
                  if (hasSpotify && AppConstants.spotifyEnabled)
                    VibraSettingsTile(
                      icon: Icons.insights_rounded,
                      title: l10n.myProfileMusicStats,
                      subtitle: l10n.myProfileMusicStatsSubtitle,
                      onTap: () => context.push('/music-stats'),
                    ),
                ],
              ),

            // ── General ──────────────────────────────────────────
            VibraSettingsSection(
              label: l10n.settingsSectionGeneral,
              children: [
                VibraSettingsTile(
                  icon: Icons.health_and_safety_outlined,
                  title: l10n.safetyTitle,
                  subtitle: l10n.safetySettingsSubtitle,
                  onTap: () => context.push('/safety'),
                ),
                VibraSettingsTile(
                  icon: Icons.shield_outlined,
                  title: l10n.settingsPrivacyData,
                  subtitle: l10n.settingsPrivacyDataBody,
                  onTap: () => context.push('/privacy-controls'),
                ),
                VibraSettingsTile(
                  icon: Icons.language_rounded,
                  title: l10n.settingsLanguage,
                  subtitle: langName,
                  onTap: () => _pickLanguage(context, ref),
                ),
              ],
            ),

            // ── Appearance ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: VibraSpacing.xxl),
              child: AppearanceSelector(
                value: themePreference,
                onChanged: (value) => ref
                    .read(themePreferenceProvider.notifier)
                    .setPreference(value),
              ),
            ),

            // ── Help ─────────────────────────────────────────────
            VibraSettingsSection(
              label: l10n.settingsSectionHelp,
              children: [
                VibraSettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: l10n.settingsHelpCenter,
                  subtitle: AppConstants.spotifyEnabled
                      ? l10n.settingsHelpCenterBody
                      : '${l10n.navProfile} · ${l10n.navEvents} · ${l10n.navChat}',
                  onTap: () => context.push('/help-center'),
                ),
                VibraSettingsTile(
                  icon: Icons.bug_report_outlined,
                  title: l10n.supportReportTitle,
                  subtitle: l10n.settingsReportProblemBody,
                  onTap: () => context.push('/report-problem'),
                ),
                VibraSettingsTile(
                  icon: Icons.support_agent_rounded,
                  title: l10n.settingsSupport,
                  subtitle: l10n.settingsSupportSub,
                  onTap: () => context.push('/support'),
                ),
              ],
            ),

            // ── Legal ────────────────────────────────────────────
            VibraSettingsSection(
              label: l10n.settingsSectionLegal,
              children: [
                VibraSettingsTile(
                  icon: Icons.policy_outlined,
                  title: l10n.settingsPrivacyPolicy,
                  subtitle: l10n.settingsPrivacyPolicySub,
                  onTap: () => context.push('/privacy-policy'),
                ),
                VibraSettingsTile(
                  icon: Icons.gavel_rounded,
                  title: l10n.settingsTermsOfService,
                  subtitle: l10n.settingsTermsOfServiceSub,
                  onTap: () => context.push('/terms-of-service'),
                ),
                VibraSettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: l10n.settingsAbout,
                  subtitle: l10n.settingsAboutSub,
                  onTap: () => context.push('/about'),
                ),
              ],
            ),

            // ── Account (destructive actions last) ───────────────
            VibraSettingsSection(
              label: l10n.settingsSectionAccount,
              children: [
                VibraSettingsTile(
                  icon: Icons.logout_rounded,
                  title: l10n.settingsLogout,
                  showChevron: false,
                  onTap: () => _signOut(context, ref, everywhere: false),
                ),
                VibraSettingsTile(
                  icon: Icons.phonelink_erase_rounded,
                  title: l10n.settingsLogoutAll,
                  showChevron: false,
                  onTap: () => _signOut(context, ref, everywhere: true),
                ),
                VibraSettingsTile(
                  icon: Icons.delete_forever_rounded,
                  title: l10n.settingsDeleteAccount,
                  subtitle: l10n.settingsDeleteAccountSub,
                  tone: VibraSettingsTone.danger,
                  showChevron: false,
                  onTap: () => _deleteAccount(context, ref),
                ),
              ],
            ),

            // ── Footer ───────────────────────────────────────────
            const SizedBox(height: VibraSpacing.sm),
            Center(child: VibraWordmark(markSize: 16, color: t.textMuted)),
            const SizedBox(height: VibraSpacing.sm),
            Text(
              l10n.settingsVersion(
                AppConstants.appVersion,
                AppConstants.appBuildNumber,
              ),
              textAlign: TextAlign.center,
              style: VibraTextStyles.caption.copyWith(color: t.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDigest(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final selected = await VibraBottomSheet.show<String>(
      context,
      builder: (sheetContext) => VibraBottomSheet(
        title: l10n.settingsMusicWeek,
        subtitle: l10n.settingsMusicWeekBody,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (value, label) in [
              ('weekly', l10n.settingsWeekly),
              ('monthly', l10n.settingsMonthly),
              ('never', l10n.settingsNever),
            ])
              ListTile(
                title: Text(label),
                trailing: value == current
                    ? Icon(Icons.check_rounded, color: t.accentPrimary)
                    : null,
                onTap: () => Navigator.of(sheetContext).pop(value),
              ),
          ],
        ),
      ),
    );
    if (selected != null) {
      await ref.read(digestFrequencyProvider.notifier).setFrequency(selected);
    }
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final current = ref.read(localeStateProvider)?.languageCode ?? '';
    final selectedLanguage = await VibraBottomSheet.show<String>(
      context,
      builder: (sheetContext) => VibraBottomSheet(
        title: l10n.settingsLanguage,
        subtitle: l10n.settingsLanguageSub,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (code, label) in [
                ('', l10n.settingsLanguageSystem),
                ('en', l10n.langEnglish),
                ('it', l10n.langItalian),
                ('es', l10n.langSpanish),
                ('fr', l10n.langFrench),
                ('de', l10n.langGerman),
              ])
                ListTile(
                  title: Text(label),
                  trailing: code == current
                      ? Icon(Icons.check_rounded, color: t.accentPrimary)
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(code),
                ),
            ],
          ),
        ),
      ),
    );
    if (selectedLanguage != null) {
      await ref
          .read(localeStateProvider.notifier)
          .setLocale(selectedLanguage.isEmpty ? null : selectedLanguage);
    }
  }

  Future<void> _onSpotifyTap(
    BuildContext context,
    WidgetRef ref,
    bool hasSpotify,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    if (!hasSpotify) {
      if (AppConstants.spotifyEnabled) context.push('/spotify-connect');
      return;
    }
    final confirm = await confirmVibraAction(
      context,
      title: l10n.settingsSpotifyDisconnectConfirmTitle,
      body: AppConstants.spotifyEnabled
          ? l10n.settingsSpotifyDisconnectConfirmBody
          : l10n.spotifyUnavailableBody,
      confirmLabel: l10n.settingsSpotifyDisconnect,
      cancelLabel: l10n.settingsCancel,
      destructive: true,
    );
    if (!confirm) return;
    var disconnected = true;
    try {
      await ref.read(spotifyAuthProvider.notifier).disconnectSpotify();
    } catch (_) {
      disconnected = false;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            disconnected
                ? l10n.settingsSpotifyDisconnectedSuccess
                : l10n.settingsSpotifyDisconnectError,
          ),
        ),
      );
    }
  }

  Future<void> _signOut(
    BuildContext context,
    WidgetRef ref, {
    required bool everywhere,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await confirmVibraAction(
      context,
      title: everywhere
          ? l10n.settingsLogoutAllConfirmTitle
          : l10n.settingsLogoutConfirmTitle,
      body: everywhere
          ? l10n.settingsLogoutAllConfirmBody
          : l10n.settingsLogoutConfirmBody,
      confirmLabel: everywhere ? l10n.settingsLogoutAll : l10n.settingsLogout,
      cancelLabel: l10n.settingsCancel,
    );
    if (!confirm || !context.mounted) return;
    try {
      await ref
          .read(generalAuthProvider.notifier)
          .signOut(
            scope: everywhere ? SignOutScope.global : SignOutScope.local,
          );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.settingsLogoutError(userFacingError(l10n, e))),
          ),
        );
      }
    }
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await confirmVibraAction(
      context,
      title: l10n.settingsDeleteAccountConfirmTitle,
      body: l10n.settingsDeleteAccountConfirmBody,
      confirmLabel: l10n.settingsDelete,
      cancelLabel: l10n.settingsCancel,
      destructive: true,
    );
    if (!confirm || !context.mounted) return;
    try {
      await ref.read(generalAuthProvider.notifier).deleteAccount();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsDeleteAccountError)),
        );
      }
    }
  }
}
