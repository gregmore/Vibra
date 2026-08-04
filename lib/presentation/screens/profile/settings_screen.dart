import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/vibra_colors.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/spotify_auth_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/core_providers.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_section_header.dart';

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
        return l10n.settingsOptionDiscoverVisible;
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
    final hasSpotify = profile.spotifyId != null && profile.spotifyId!.isNotEmpty;

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
        padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        children: [
          const SizedBox(height: 8),
          VibraSectionHeader(
            title: l10n.settingsHeaderNotificationsPrivacy,
            subtitle: l10n.settingsSubtitleNotificationsPrivacy,
          ),
          Container(
            decoration: BoxDecoration(
              color: VibraColors.surfaceElevated,
              borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
              border: Border.all(color: VibraColors.glassBorder),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: settings.asMap().entries.map((entry) {
                  return SwitchListTile(
                    value: entry.value.enabled,
                    activeThumbColor: VibraColors.accent,
                    activeTrackColor: VibraColors.accent.withValues(alpha: 0.5),
                    inactiveThumbColor: VibraColors.textSecondary,
                    inactiveTrackColor: VibraColors.surfaceVariant,
                    title: Text(_getOptionLabel(context, entry.key), style: VibraTextStyles.bodyMedium),
                    onChanged: (value) {
                      ref.read(settingsStateProvider.notifier).toggle(entry.key, value);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: VibraSpacing.xl),
          
          // Lingua / Language Selection Setting
          Container(
            decoration: BoxDecoration(
              color: VibraColors.surfaceElevated,
              borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
              border: Border.all(color: VibraColors.glassBorder),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
              clipBehavior: Clip.antiAlias,
              child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language_rounded, color: VibraColors.textPrimary),
                  title: Text(l10n.settingsLanguage, style: VibraTextStyles.bodyMedium),
                  subtitle: Text(langName, style: VibraTextStyles.bodySmall.copyWith(color: VibraColors.textSecondary)),
                  onTap: () async {
                    final String? selectedLanguage = await showDialog<String?>(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: VibraColors.surfaceElevated,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
                          side: const BorderSide(color: VibraColors.glassBorder),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(VibraSpacing.md),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(l10n.settingsLanguage, style: VibraTextStyles.titleMedium),
                              const SizedBox(height: VibraSpacing.md),
                              Flexible(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      ListTile(title: Text(l10n.settingsLanguageSystem, style: VibraTextStyles.bodyMedium), onTap: () => Navigator.pop(context, '')),
                                      ListTile(title: Text(l10n.langEnglish, style: VibraTextStyles.bodyMedium), onTap: () => Navigator.pop(context, 'en')),
                                      ListTile(title: Text(l10n.langItalian, style: VibraTextStyles.bodyMedium), onTap: () => Navigator.pop(context, 'it')),
                                      ListTile(title: Text(l10n.langSpanish, style: VibraTextStyles.bodyMedium), onTap: () => Navigator.pop(context, 'es')),
                                      ListTile(title: Text(l10n.langFrench, style: VibraTextStyles.bodyMedium), onTap: () => Navigator.pop(context, 'fr')),
                                      ListTile(title: Text(l10n.langGerman, style: VibraTextStyles.bodyMedium), onTap: () => Navigator.pop(context, 'de')),
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
                      await ref.read(localeStateProvider.notifier).setLocale(
                        selectedLanguage.isEmpty ? null : selectedLanguage,
                      );
                    }
                  },
                ),
                const Divider(height: 1, color: VibraColors.glassBorder),
                ListTile(
                  leading: const Icon(
                    Icons.graphic_eq_rounded,
                    color: Color(0xFF1DB954),
                  ),
                  title: Text(l10n.settingsSpotifyAccount, style: VibraTextStyles.bodyMedium),
                  subtitle: Text(
                    hasSpotify
                        ? l10n.settingsSpotifyConnected(profile.spotifyId ?? '')
                        : l10n.settingsSpotifyDisconnected,
                    style: VibraTextStyles.bodySmall.copyWith(color: VibraColors.textSecondary),
                  ),
                  trailing: hasSpotify
                      ? Text(
                          l10n.settingsSpotifyDisconnect,
                          style: VibraTextStyles.labelLarge.copyWith(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Icon(Icons.chevron_right_rounded, color: VibraColors.textSecondary),
                  onTap: () async {
                    if (hasSpotify) {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: VibraColors.surfaceElevated,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
                            side: const BorderSide(color: VibraColors.glassBorder),
                          ),
                          title: Text(l10n.settingsSpotifyDisconnectConfirmTitle, style: VibraTextStyles.titleMedium),
                          content: Text(
                            l10n.settingsSpotifyDisconnectConfirmBody,
                            style: VibraTextStyles.bodyMedium.copyWith(color: VibraColors.textSecondary),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(l10n.settingsCancel, style: VibraTextStyles.labelLarge.copyWith(color: VibraColors.textPrimary)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                              ),
                              child: Text(l10n.settingsSpotifyDisconnect, style: VibraTextStyles.labelLarge.copyWith(color: Colors.redAccent)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await ref.read(spotifyAuthProvider.notifier).disconnectSpotify();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.settingsSpotifyDisconnectedSuccess),
                            ),
                          );
                        }
                      }
                    } else {
                      context.push('/spotify-connect');
                    }
                  },
                ),
                const Divider(height: 1, color: VibraColors.glassBorder),
                Consumer(
                  builder: (context, ref, child) {
                    final pushEnabled = ref.watch(pushEnabledProvider);
                    return SwitchListTile(
                      secondary: const Icon(Icons.notifications_active_outlined, color: VibraColors.textPrimary),
                      title: Text(l10n.settingsNotifications, style: VibraTextStyles.bodyMedium),
                      subtitle: Text(l10n.settingsNotificationsSub, style: VibraTextStyles.bodySmall.copyWith(color: VibraColors.textSecondary)),
                      value: pushEnabled,
                      onChanged: (val) {
                        ref.read(pushEnabledProvider.notifier).toggle(val);
                      },
                    );
                  },
                ),

                const Divider(height: 1, color: VibraColors.glassBorder),
                ListTile(
                  leading: const Icon(Icons.group_add_outlined, color: VibraColors.textPrimary),
                  title: Text(l10n.settingsGenerateCompatibleUsers, style: VibraTextStyles.bodyMedium),
                  subtitle: Text(l10n.settingsGenerateCompatibleUsersSub, style: VibraTextStyles.bodySmall.copyWith(color: VibraColors.textSecondary)),
                  onTap: () async {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.settingsGenerateCompatibleUsersLoading)),
                      );
                      final supabase = ref.read(supabaseDatasourceProvider).client;
                      final res = await supabase.functions.invoke('seed-compatible-users');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(res.data['message'] ?? l10n.settingsGenerateCompatibleUsersSuccess)),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.settingsError(e.toString())), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
          const SizedBox(height: VibraSpacing.xl),
          Container(
            decoration: BoxDecoration(
              color: VibraColors.surfaceElevated,
              borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
              border: Border.all(color: VibraColors.glassBorder),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
              clipBehavior: Clip.antiAlias,
              child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.policy_outlined, color: VibraColors.textPrimary),
                  title: Text(l10n.settingsPrivacyPolicy, style: VibraTextStyles.bodyMedium),
                  subtitle: Text(l10n.settingsPrivacyPolicySub, style: VibraTextStyles.bodySmall.copyWith(color: VibraColors.textSecondary)),
                  onTap: () => context.push('/privacy-policy'),
                ),
                const Divider(height: 1, color: VibraColors.glassBorder),
                ListTile(
                  leading: const Icon(Icons.gavel_rounded, color: VibraColors.textPrimary),
                  title: Text(l10n.settingsTermsOfService, style: VibraTextStyles.bodyMedium),
                  subtitle: Text(l10n.settingsTermsOfServiceSub, style: VibraTextStyles.bodySmall.copyWith(color: VibraColors.textSecondary)),
                  onTap: () => context.push('/terms-of-service'),
                ),
                const Divider(height: 1, color: VibraColors.glassBorder),
                ListTile(
                  leading: const Icon(Icons.support_agent_rounded, color: VibraColors.textPrimary),
                  title: Text(l10n.settingsSupport, style: VibraTextStyles.bodyMedium),
                  subtitle: Text(l10n.settingsSupportSub, style: VibraTextStyles.bodySmall.copyWith(color: VibraColors.textSecondary)),
                  onTap: () => context.push('/support'),
                ),
                const Divider(height: 1, color: VibraColors.glassBorder),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded, color: VibraColors.textPrimary),
                  title: Text(l10n.settingsAbout, style: VibraTextStyles.bodyMedium),
                  subtitle: Text(l10n.settingsAboutSub, style: VibraTextStyles.bodySmall.copyWith(color: VibraColors.textSecondary)),
                  onTap: () => context.push('/about'),
                ),
              ],
            ),
          ),
        ),
          const SizedBox(height: VibraSpacing.xl),
          Container(
            decoration: BoxDecoration(
              color: VibraColors.surfaceElevated,
              borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
              border: Border.all(color: VibraColors.glassBorder),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
              clipBehavior: Clip.antiAlias,
              child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: VibraColors.textPrimary),
                  title: Text(l10n.settingsLogout, style: VibraTextStyles.bodyMedium),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: VibraColors.surfaceElevated,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
                          side: const BorderSide(color: VibraColors.glassBorder),
                        ),
                        title: Text(l10n.settingsLogoutConfirmTitle, style: VibraTextStyles.titleMedium),
                        content: Text(l10n.settingsLogoutConfirmBody, style: VibraTextStyles.bodyMedium.copyWith(color: VibraColors.textSecondary)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(l10n.settingsCancel, style: VibraTextStyles.labelLarge.copyWith(color: VibraColors.textPrimary)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(l10n.settingsLogout, style: VibraTextStyles.labelLarge.copyWith(color: VibraColors.accent)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      try {
                        await ref.read(generalAuthProvider.notifier).signOut();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.settingsLogoutError(e.toString()))),
                          );
                        }
                      }
                    }
                  },
                ),
                const Divider(height: 1, color: VibraColors.glassBorder),
                ListTile(
                  leading: const Icon(Icons.phonelink_erase_rounded, color: VibraColors.textPrimary),
                  title: Text(l10n.settingsLogoutAll, style: VibraTextStyles.bodyMedium),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: VibraColors.surfaceElevated,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
                          side: const BorderSide(color: VibraColors.glassBorder),
                        ),
                        title: Text(l10n.settingsLogoutAllConfirmTitle, style: VibraTextStyles.titleMedium),
                        content: Text(l10n.settingsLogoutAllConfirmBody, style: VibraTextStyles.bodyMedium.copyWith(color: VibraColors.textSecondary)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(l10n.settingsCancel, style: VibraTextStyles.labelLarge.copyWith(color: VibraColors.textPrimary)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(l10n.settingsLogoutAll, style: VibraTextStyles.labelLarge.copyWith(color: VibraColors.accent)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      try {
                        await ref.read(generalAuthProvider.notifier).signOut(scope: SignOutScope.global);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.settingsLogoutError(e.toString()))),
                          );
                        }
                      }
                    }
                  },
                ),
                const Divider(height: 1, color: VibraColors.glassBorder),
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                  title: Text(l10n.settingsDeleteAccount, style: VibraTextStyles.bodyMedium.copyWith(color: Colors.redAccent)),
                  subtitle: Text(l10n.settingsDeleteAccountConfirmBody, style: VibraTextStyles.bodySmall.copyWith(color: VibraColors.textSecondary)),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: VibraColors.surfaceElevated,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
                          side: const BorderSide(color: VibraColors.glassBorder),
                        ),
                        title: Text(l10n.settingsDeleteAccountConfirmTitle, style: VibraTextStyles.titleMedium),
                        content: Text(l10n.settingsDeleteAccountConfirmBody, style: VibraTextStyles.bodyMedium.copyWith(color: VibraColors.textSecondary)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(l10n.settingsCancel, style: VibraTextStyles.labelLarge.copyWith(color: VibraColors.textPrimary)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: Text(l10n.settingsDelete, style: VibraTextStyles.labelLarge.copyWith(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      try {
                        await ref.read(generalAuthProvider.notifier).deleteAccount();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.settingsDeleteAccountError),
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
        ],
      ),
    );
  }
}
