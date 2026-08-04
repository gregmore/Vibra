import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../core/theme/vibra_colors.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../providers/app_state_providers.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_section_header.dart';
import '../../widgets/vibra_glassmorphic_card.dart';
import '../../widgets/vibra_neon_avatar.dart';

class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(myProfileProvider);
    final music = ref.watch(myMusicProfileProvider);
    final myEvents = ref.watch(myEventsProvider);
    final theme = Theme.of(context);
    final displayName = me.displayName ?? me.username;

    final l10n = AppLocalizations.of(context)!;

    return VibraPageScaffold(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 160),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(l10n.navProfile, style: theme.textTheme.displaySmall),
          ).animate().fadeIn(duration: 300.ms),

          // Profile Header Card
          VibraGlassmorphicCard(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(20),
                gradient: LinearGradient(
                  colors: [
                    VibraColors.primary.withValues(alpha: 0.1),
                    VibraColors.surfaceElevated,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                child: Column(
                  children: [
                    VibraNeonAvatar(
                      imageUrl: me.avatarUrl ?? '',
                      radius: 46,
                      score: 1.0,
                      displayName: displayName,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (me.spotifyId != null &&
                            me.spotifyId!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF1DB954,
                              ).withValues(alpha: 0.15),
                              borderRadius: VibraSpacing.borderSmall,
                              border: Border.all(
                                color: const Color(
                                  0xFF1DB954,
                                ).withValues(alpha: 0.5),
                                width: 0.5,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.graphic_eq_rounded,
                                  color: Color(0xFF1DB954),
                                  size: 12,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Spotify',
                                  style: TextStyle(
                                    color: Color(0xFF1DB954),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${me.username}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: VibraColors.textSecondary,
                      ),
                    ),
                    if (me.bio != null && me.bio!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        me.bio!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: VibraColors.textPrimary.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: () => context.push('/edit-profile'),
                      icon: const Icon(Icons.edit_rounded, size: 16),
                      label: const Text(
                        'Modifica Profilo',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        minimumSize: const Size(0, 36),
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (me.spotifyId != null && me.spotifyId!.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: music.topArtists
                            .take(3)
                            .map(
                              (a) => Chip(
                                label: Text(a.name),
                                avatar: const Icon(
                                  Icons.music_note_rounded,
                                  size: 12,
                                  color: VibraColors.accent,
                                ),
                              ),
                            )
                            .toList(),
                      )
                    else ...[
                      const SizedBox(height: 4),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/spotify-connect'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1DB954),
                          side: const BorderSide(
                            color: Color(0xFF1DB954),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: VibraSpacing.borderFull,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        icon: const Icon(Icons.link_rounded, size: 18),
                        label: Text(
                          l10n.myProfileConnectSpotify,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .scaleXY(begin: 0.96, end: 1.0),

          const SizedBox(height: 12),

          VibraSectionHeader(
            title: l10n.myProfileOverview,
            subtitle: l10n.myProfileOverviewSubtitle,
            actionLabel: l10n.myProfileSettings,
            onActionTap: () => context.push('/settings'),
          ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

          const SizedBox(height: 8),

          _ActionTile(
                icon: Icons.query_stats_rounded,
                iconColor: VibraColors.primary,
                title: l10n.myProfileMusicStats,
                subtitle: l10n.myProfileMusicStatsSubtitle,
                onTap: () => context.push('/music-stats'),
              )
              .animate()
              .fadeIn(delay: 250.ms, duration: 400.ms)
              .slideY(begin: 0.05, end: 0),

          _ActionTile(
                icon: Icons.event_available_rounded,
                iconColor: VibraColors.accent,
                title: l10n.myProfileMyEvents,
                subtitle: l10n.myProfileMyEventsSubtitle(
                  (myEvents.going.length + myEvents.saved.length).toString(),
                ),
                onTap: () => context.push('/my-events'),
              )
              .animate()
              .fadeIn(delay: 350.ms, duration: 400.ms)
              .slideY(begin: 0.05, end: 0),

          _ActionTile(
                icon: Icons.settings_suggest_rounded,
                iconColor: VibraColors.accentWarm,
                title: l10n.myProfileSettings,
                subtitle: l10n.myProfileSettingsSubtitle,
                onTap: () => context.push('/settings'),
              )
              .animate()
              .fadeIn(delay: 450.ms, duration: 400.ms)
              .slideY(begin: 0.05, end: 0),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: VibraColors.surface,
        borderRadius: VibraSpacing.borderMedium,
        border: Border.all(color: VibraColors.glassBorder, width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: VibraSpacing.borderMedium,
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: VibraColors.textSecondary,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
