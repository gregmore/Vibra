import 'package:vibra/presentation/localization/user_facing_error.dart';
import '../../../core/constants/app_constants.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/spotify_auth_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_section_header.dart';
import 'theme_appearance_selector.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _getOptionLabel(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context)!;
    switch (index) {
      case 0:
        return l10n.settingsOptionCompatibleEvents;
      case 1:
        return l10n.settingsOptionHighMatchAlerts;
      case 2:
        return l10n.settingsOptionLiveChat;
      case 3:
        return AppLocalizations.of(context)!.settingsPrivateMessages;
      case 4:
        return AppLocalizations.of(context)!.settingsPersonalizedUpdates;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStateProvider);
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

    return VibraPageScaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      child: ListView(
        padding: EdgeInsets.only(bottom: 24, left: 16, right: 16),
        children: [
          SizedBox(height: 8),
          VibraSectionHeader(
            title: l10n.settingsHeaderNotificationsPrivacy,
            subtitle: l10n.settingsSubtitleNotificationsPrivacy,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: context.vibraTokens.surfaceElevated.withValues(
                    alpha: 0.75,
                  ),
                  borderRadius: BorderRadius.circular(
                    VibraSpacing.radiusMedium,
                  ),
                  border: Border.all(color: context.vibraTokens.borderDefault),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    VibraSpacing.radiusMedium,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: settings
                        .asMap()
                        .entries
                        .where(
                          (entry) =>
                              AppConstants.spotifyEnabled ||
                              !const {0, 1, 4}.contains(entry.key),
                        )
                        .map((entry) {
                          return SwitchListTile(
                            value: entry.value.enabled,
                            activeThumbColor: context.vibraTokens.accentPrimary,
                            activeTrackColor: context.vibraTokens.accentPrimary
                                .withValues(alpha: 0.5),
                            inactiveThumbColor:
                                context.vibraTokens.textSecondary,
                            inactiveTrackColor:
                                context.vibraTokens.surfaceMuted,
                            title: Text(
                              _getOptionLabel(context, entry.key),
                              style: VibraTextStyles.bodyMedium,
                            ),
                            onChanged: (value) {
                              ref
                                  .read(settingsStateProvider.notifier)
                                  .toggle(entry.key, value);
                            },
                          );
                        })
                        .toList(),
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 0.ms, duration: 400.ms).slideY(begin: 0.03),
          SizedBox(height: 10),
          if (AppConstants.spotifyEnabled)
            Container(
              decoration: BoxDecoration(
                color: context.vibraTokens.surfaceElevated.withValues(
                  alpha: 0.75,
                ),
                borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
                border: Border.all(color: context.vibraTokens.borderDefault),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.auto_awesome_outlined,
                  color: context.vibraTokens.accentPrimary,
                ),
                title: Text(
                  AppLocalizations.of(context)!.settingsMusicWeek,
                  style: VibraTextStyles.bodyMedium,
                ),
                subtitle: Text(
                  AppLocalizations.of(context)!.settingsMusicWeekBody,
                  style: VibraTextStyles.bodySmall.copyWith(
                    color: context.vibraTokens.textSecondary,
                  ),
                ),
                trailing: DropdownButton<String>(
                  value: digestFrequency,
                  underline: SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(
                      value: 'weekly',
                      child: Text(AppLocalizations.of(context)!.settingsWeekly),
                    ),
                    DropdownMenuItem(
                      value: 'monthly',
                      child: Text(
                        AppLocalizations.of(context)!.settingsMonthly,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'never',
                      child: Text(AppLocalizations.of(context)!.settingsNever),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(digestFrequencyProvider.notifier)
                          .setFrequency(value);
                    }
                  },
                ),
              ),
            ),
          SizedBox(height: VibraSpacing.xl),

          // Lingua / Language Selection Setting
          ClipRRect(
            borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: context.vibraTokens.surfaceElevated.withValues(
                    alpha: 0.75,
                  ),
                  borderRadius: BorderRadius.circular(
                    VibraSpacing.radiusMedium,
                  ),
                  border: Border.all(color: context.vibraTokens.borderDefault),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    VibraSpacing.radiusMedium,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFF8B5CF6).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.shield_outlined,
                            color: Color(0xFF8B5CF6),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          AppLocalizations.of(context)!.settingsPrivacyData,
                          style: VibraTextStyles.bodyMedium,
                        ),
                        subtitle: Text(
                          AppLocalizations.of(context)!.settingsPrivacyDataBody,
                          style: VibraTextStyles.bodySmall.copyWith(
                            color: context.vibraTokens.textSecondary,
                          ),
                        ),
                        onTap: () => context.push('/privacy-controls'),
                      ),
                      Divider(
                        height: 1,
                        color: context.vibraTokens.borderDefault,
                      ),
                      ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: context.vibraTokens.accentPrimary.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.language_rounded,
                            color: context.vibraTokens.accentPrimary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          l10n.settingsLanguage,
                          style: VibraTextStyles.bodyMedium,
                        ),
                        subtitle: Text(
                          langName,
                          style: VibraTextStyles.bodySmall.copyWith(
                            color: context.vibraTokens.textSecondary,
                          ),
                        ),
                        onTap: () async {
                          final String?
                          selectedLanguage = await showDialog<String?>(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor:
                                  context.vibraTokens.surfaceElevated,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  VibraSpacing.radiusMedium,
                                ),
                                side: BorderSide(
                                  color: context.vibraTokens.borderDefault,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(VibraSpacing.md),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      l10n.settingsLanguage,
                                      style: VibraTextStyles.titleMedium,
                                    ),
                                    SizedBox(height: VibraSpacing.md),
                                    Flexible(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            ListTile(
                                              title: Text(
                                                l10n.settingsLanguageSystem,
                                                style:
                                                    VibraTextStyles.bodyMedium,
                                              ),
                                              onTap: () =>
                                                  Navigator.pop(context, ''),
                                            ),
                                            ListTile(
                                              title: Text(
                                                l10n.langEnglish,
                                                style:
                                                    VibraTextStyles.bodyMedium,
                                              ),
                                              onTap: () =>
                                                  Navigator.pop(context, 'en'),
                                            ),
                                            ListTile(
                                              title: Text(
                                                l10n.langItalian,
                                                style:
                                                    VibraTextStyles.bodyMedium,
                                              ),
                                              onTap: () =>
                                                  Navigator.pop(context, 'it'),
                                            ),
                                            ListTile(
                                              title: Text(
                                                l10n.langSpanish,
                                                style:
                                                    VibraTextStyles.bodyMedium,
                                              ),
                                              onTap: () =>
                                                  Navigator.pop(context, 'es'),
                                            ),
                                            ListTile(
                                              title: Text(
                                                l10n.langFrench,
                                                style:
                                                    VibraTextStyles.bodyMedium,
                                              ),
                                              onTap: () =>
                                                  Navigator.pop(context, 'fr'),
                                            ),
                                            ListTile(
                                              title: Text(
                                                l10n.langGerman,
                                                style:
                                                    VibraTextStyles.bodyMedium,
                                              ),
                                              onTap: () =>
                                                  Navigator.pop(context, 'de'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                          if (selectedLanguage != null) {
                            await ref
                                .read(localeStateProvider.notifier)
                                .setLocale(
                                  selectedLanguage.isEmpty
                                      ? null
                                      : selectedLanguage,
                                );
                          }
                        },
                      ),
                      if (AppConstants.spotifyEnabled || hasSpotify)
                        Divider(
                          height: 1,
                          color: context.vibraTokens.borderDefault,
                        ),
                      if (AppConstants.spotifyEnabled || hasSpotify)
                        ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFF1DB954).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.graphic_eq_rounded,
                              color: Color(0xFF1DB954),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            l10n.settingsSpotifyAccount,
                            style: VibraTextStyles.bodyMedium,
                          ),
                          subtitle: Text(
                            !AppConstants.spotifyEnabled
                                ? l10n.spotifyUnavailableBody
                                : hasSpotify
                                ? l10n.settingsSpotifyConnected(
                                    profile.spotifyId ?? '',
                                  )
                                : l10n.settingsSpotifyDisconnected,
                            style: VibraTextStyles.bodySmall.copyWith(
                              color: context.vibraTokens.textSecondary,
                            ),
                          ),
                          trailing: hasSpotify
                              ? Text(
                                  l10n.settingsSpotifyDisconnect,
                                  style: VibraTextStyles.labelLarge.copyWith(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Icon(
                                  Icons.chevron_right_rounded,
                                  color: context.vibraTokens.textSecondary,
                                ),
                          onTap: () async {
                            if (hasSpotify) {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor:
                                      context.vibraTokens.surfaceElevated,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      VibraSpacing.radiusMedium,
                                    ),
                                    side: BorderSide(
                                      color: context.vibraTokens.borderDefault,
                                    ),
                                  ),
                                  title: Text(
                                    l10n.settingsSpotifyDisconnectConfirmTitle,
                                    style: VibraTextStyles.titleMedium,
                                  ),
                                  content: Text(
                                    AppConstants.spotifyEnabled
                                        ? l10n.settingsSpotifyDisconnectConfirmBody
                                        : l10n.spotifyUnavailableBody,
                                    style: VibraTextStyles.bodyMedium.copyWith(
                                      color: context.vibraTokens.textSecondary,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text(
                                        l10n.settingsCancel,
                                        style: VibraTextStyles.labelLarge
                                            .copyWith(
                                              color: context
                                                  .vibraTokens
                                                  .textPrimary,
                                            ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.redAccent,
                                      ),
                                      child: Text(
                                        l10n.settingsSpotifyDisconnect,
                                        style: VibraTextStyles.labelLarge
                                            .copyWith(color: Colors.redAccent),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await ref
                                    .read(spotifyAuthProvider.notifier)
                                    .disconnectSpotify();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l10n.settingsSpotifyDisconnectedSuccess,
                                      ),
                                    ),
                                  );
                                }
                              }
                            } else if (AppConstants.spotifyEnabled) {
                              context.push('/spotify-connect');
                            }
                          },
                        ),
                      Divider(
                        height: 1,
                        color: context.vibraTokens.borderDefault,
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          final pushEnabled = ref.watch(pushEnabledProvider);
                          return SwitchListTile(
                            secondary: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: context.vibraTokens.accentPrimary
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.notifications_active_outlined,
                                color: context.vibraTokens.accentPrimary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              l10n.settingsNotifications,
                              style: VibraTextStyles.bodyMedium,
                            ),
                            subtitle: Text(
                              l10n.settingsNotificationsSub,
                              style: VibraTextStyles.bodySmall.copyWith(
                                color: context.vibraTokens.textSecondary,
                              ),
                            ),
                            value: pushEnabled,
                            onChanged: (val) {
                              ref
                                  .read(pushEnabledProvider.notifier)
                                  .toggle(val);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.03),
          SizedBox(height: VibraSpacing.xl),
          ClipRRect(
            borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
            child: Container(
              decoration: BoxDecoration(
                color: context.vibraTokens.surfaceElevated.withValues(
                  alpha: 0.75,
                ),
                borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
                border: Border.all(color: context.vibraTokens.borderDefault),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.help_outline_rounded,
                        color: context.vibraTokens.accentPrimary,
                      ),
                      title: Text(
                        AppLocalizations.of(context)!.settingsHelpCenter,
                        style: VibraTextStyles.bodyMedium,
                      ),
                      subtitle: Text(
                        AppConstants.spotifyEnabled
                            ? AppLocalizations.of(
                                context,
                              )!.settingsHelpCenterBody
                            : '${l10n.navProfile} · ${l10n.navEvents} · ${l10n.navChat}',
                        style: VibraTextStyles.bodySmall.copyWith(
                          color: context.vibraTokens.textSecondary,
                        ),
                      ),
                      trailing: Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push('/help-center'),
                    ),
                    Divider(
                      height: 1,
                      color: context.vibraTokens.borderDefault,
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.bug_report_outlined,
                        color: context.vibraTokens.error,
                      ),
                      title: Text(
                        AppLocalizations.of(context)!.supportReportTitle,
                        style: VibraTextStyles.bodyMedium,
                      ),
                      subtitle: Text(
                        AppLocalizations.of(context)!.settingsReportProblemBody,
                        style: VibraTextStyles.bodySmall.copyWith(
                          color: context.vibraTokens.textSecondary,
                        ),
                      ),
                      trailing: Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push('/report-problem'),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
          SizedBox(height: VibraSpacing.xl),
          ClipRRect(
                borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.vibraTokens.surfaceElevated.withValues(
                        alpha: 0.75,
                      ),
                      borderRadius: BorderRadius.circular(
                        VibraSpacing.radiusMedium,
                      ),
                      border: Border.all(
                        color: context.vibraTokens.borderDefault,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        VibraSpacing.radiusMedium,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(
                                  0xFF60A5FA,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.policy_outlined,
                                color: Color(0xFF60A5FA),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              l10n.settingsPrivacyPolicy,
                              style: VibraTextStyles.bodyMedium,
                            ),
                            subtitle: Text(
                              l10n.settingsPrivacyPolicySub,
                              style: VibraTextStyles.bodySmall.copyWith(
                                color: context.vibraTokens.textSecondary,
                              ),
                            ),
                            onTap: () => context.push('/privacy-policy'),
                          ),
                          Divider(
                            height: 1,
                            color: context.vibraTokens.borderDefault,
                          ),
                          ListTile(
                            leading: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(
                                  0xFFF59E0B,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.gavel_rounded,
                                color: Color(0xFFF59E0B),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              l10n.settingsTermsOfService,
                              style: VibraTextStyles.bodyMedium,
                            ),
                            subtitle: Text(
                              l10n.settingsTermsOfServiceSub,
                              style: VibraTextStyles.bodySmall.copyWith(
                                color: context.vibraTokens.textSecondary,
                              ),
                            ),
                            onTap: () => context.push('/terms-of-service'),
                          ),
                          Divider(
                            height: 1,
                            color: context.vibraTokens.borderDefault,
                          ),
                          ListTile(
                            leading: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(
                                  0xFF14B8A6,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.support_agent_rounded,
                                color: Color(0xFF14B8A6),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              l10n.settingsSupport,
                              style: VibraTextStyles.bodyMedium,
                            ),
                            subtitle: Text(
                              l10n.settingsSupportSub,
                              style: VibraTextStyles.bodySmall.copyWith(
                                color: context.vibraTokens.textSecondary,
                              ),
                            ),
                            onTap: () => context.push('/support'),
                          ),
                          Divider(
                            height: 1,
                            color: context.vibraTokens.borderDefault,
                          ),
                          ListTile(
                            leading: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(
                                  0xFF06B6D4,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFF06B6D4),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              l10n.settingsAbout,
                              style: VibraTextStyles.bodyMedium,
                            ),
                            subtitle: Text(
                              l10n.settingsAboutSub,
                              style: VibraTextStyles.bodySmall.copyWith(
                                color: context.vibraTokens.textSecondary,
                              ),
                            ),
                            onTap: () => context.push('/about'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.03),
          SizedBox(height: VibraSpacing.xl),
          ClipRRect(
                borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.vibraTokens.surfaceElevated.withValues(
                        alpha: 0.75,
                      ),
                      borderRadius: BorderRadius.circular(
                        VibraSpacing.radiusMedium,
                      ),
                      border: Border.all(
                        color: context.vibraTokens.borderDefault,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        VibraSpacing.radiusMedium,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(
                                  0xFFF97316,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.logout_rounded,
                                color: Color(0xFFF97316),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              l10n.settingsLogout,
                              style: VibraTextStyles.bodyMedium,
                            ),
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor:
                                      context.vibraTokens.surfaceElevated,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      VibraSpacing.radiusMedium,
                                    ),
                                    side: BorderSide(
                                      color: context.vibraTokens.borderDefault,
                                    ),
                                  ),
                                  title: Text(
                                    l10n.settingsLogoutConfirmTitle,
                                    style: VibraTextStyles.titleMedium,
                                  ),
                                  content: Text(
                                    l10n.settingsLogoutConfirmBody,
                                    style: VibraTextStyles.bodyMedium.copyWith(
                                      color: context.vibraTokens.textSecondary,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text(
                                        l10n.settingsCancel,
                                        style: VibraTextStyles.labelLarge
                                            .copyWith(
                                              color: context
                                                  .vibraTokens
                                                  .textPrimary,
                                            ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: Text(
                                        l10n.settingsLogout,
                                        style: VibraTextStyles.labelLarge
                                            .copyWith(
                                              color: context
                                                  .vibraTokens
                                                  .accentPrimary,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true && context.mounted) {
                                try {
                                  await ref
                                      .read(generalAuthProvider.notifier)
                                      .signOut();
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          l10n.settingsLogoutError(
                                            userFacingError(l10n, e),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                          Divider(
                            height: 1,
                            color: context.vibraTokens.borderDefault,
                          ),
                          ListTile(
                            leading: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(
                                  0xFFEF4444,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.phonelink_erase_rounded,
                                color: Color(0xFFEF4444),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              l10n.settingsLogoutAll,
                              style: VibraTextStyles.bodyMedium,
                            ),
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor:
                                      context.vibraTokens.surfaceElevated,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      VibraSpacing.radiusMedium,
                                    ),
                                    side: BorderSide(
                                      color: context.vibraTokens.borderDefault,
                                    ),
                                  ),
                                  title: Text(
                                    l10n.settingsLogoutAllConfirmTitle,
                                    style: VibraTextStyles.titleMedium,
                                  ),
                                  content: Text(
                                    l10n.settingsLogoutAllConfirmBody,
                                    style: VibraTextStyles.bodyMedium.copyWith(
                                      color: context.vibraTokens.textSecondary,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text(
                                        l10n.settingsCancel,
                                        style: VibraTextStyles.labelLarge
                                            .copyWith(
                                              color: context
                                                  .vibraTokens
                                                  .textPrimary,
                                            ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: Text(
                                        l10n.settingsLogoutAll,
                                        style: VibraTextStyles.labelLarge
                                            .copyWith(
                                              color: context
                                                  .vibraTokens
                                                  .accentPrimary,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true && context.mounted) {
                                try {
                                  await ref
                                      .read(generalAuthProvider.notifier)
                                      .signOut(scope: SignOutScope.global);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          l10n.settingsLogoutError(
                                            userFacingError(l10n, e),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                          Divider(
                            height: 1,
                            color: context.vibraTokens.borderDefault,
                          ),
                          ListTile(
                            leading: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: context.vibraTokens.error.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.delete_forever_rounded,
                                color: context.vibraTokens.error,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              l10n.settingsDeleteAccount,
                              style: VibraTextStyles.bodyMedium.copyWith(
                                color: Colors.redAccent,
                              ),
                            ),
                            subtitle: Text(
                              l10n.settingsDeleteAccountConfirmBody,
                              style: VibraTextStyles.bodySmall.copyWith(
                                color: context.vibraTokens.textSecondary,
                              ),
                            ),
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor:
                                      context.vibraTokens.surfaceElevated,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      VibraSpacing.radiusMedium,
                                    ),
                                    side: BorderSide(
                                      color: context.vibraTokens.borderDefault,
                                    ),
                                  ),
                                  title: Text(
                                    l10n.settingsDeleteAccountConfirmTitle,
                                    style: VibraTextStyles.titleMedium,
                                  ),
                                  content: Text(
                                    l10n.settingsDeleteAccountConfirmBody,
                                    style: VibraTextStyles.bodyMedium.copyWith(
                                      color: context.vibraTokens.textSecondary,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text(
                                        l10n.settingsCancel,
                                        style: VibraTextStyles.labelLarge
                                            .copyWith(
                                              color: context
                                                  .vibraTokens
                                                  .textPrimary,
                                            ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: Text(
                                        l10n.settingsDelete,
                                        style: VibraTextStyles.labelLarge
                                            .copyWith(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true && context.mounted) {
                                try {
                                  await ref
                                      .read(generalAuthProvider.notifier)
                                      .deleteAccount();
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          l10n.settingsDeleteAccountError,
                                        ),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideY(begin: 0.03),
          SizedBox(height: VibraSpacing.xl),
          AppearanceSelector(
            value: themePreference,
            onChanged: (value) =>
                ref.read(themePreferenceProvider.notifier).setPreference(value),
          ),
        ],
      ),
    );
  }
}
