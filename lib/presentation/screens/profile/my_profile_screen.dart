import '../../../core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/music_profile.dart';
import '../../providers/app_state_providers.dart';
import '../../widgets/common/vibra_avatar.dart';
import '../../widgets/common/vibra_button.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_surface.dart';
import '../../widgets/vibra_signal_wave.dart';

class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(myProfileProvider);
    final music = AppConstants.spotifyEnabled
        ? ref.watch(myMusicProfileProvider)
        : null;
    final myEvents = ref.watch(myEventsProvider);
    final friends = ref.watch(friendsProvider);
    final followStats = ref.watch(userFollowStatsProvider(me.id));
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final t = context.vibraTokens;
    final displayName = me.displayName ?? me.username;
    final hasSpotify =
        AppConstants.spotifyEnabled &&
        me.spotifyId != null &&
        me.spotifyId!.isNotEmpty;
    final eventCount = myEvents.going.length + myEvents.saved.length;

    return VibraPageScaffold(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 128),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              VibraSpacing.pagePadding,
              20,
              VibraSpacing.pagePadding,
              12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.profilePersonalSpace,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: t.textSecondary,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.navProfile,
                        style: theme.textTheme.displaySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.myProfileSettings,
                  onPressed: () => context.push('/settings'),
                  icon: const Icon(Icons.tune_rounded),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.03, end: 0),
          Padding(
            padding: VibraSpacing.pageHorizontal,
            child: _ProfileHero(
              avatarUrl: me.avatarUrl,
              displayName: displayName,
              username: me.username,
              bio: me.bio,
              hasSpotify: hasSpotify,
              onEdit: () => context.push('/edit-profile'),
            ),
          ).animate().fadeIn(delay: 80.ms, duration: 360.ms),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              VibraSpacing.pagePadding,
              20,
              VibraSpacing.pagePadding,
              0,
            ),
            child: _ProfileStats(
              friendsCount: friends.length,
              followersCount: followStats.followersCount,
              followingCount: followStats.followingCount,
              onFriends: () => context.push('/friends'),
              onFollowers: () => context.push(
                '/follow-list',
                extra: {
                  'userId': me.id,
                  'displayName': displayName,
                  'initialTabIndex': 0,
                },
              ),
              onFollowing: () => context.push(
                '/follow-list',
                extra: {
                  'userId': me.id,
                  'displayName': displayName,
                  'initialTabIndex': 1,
                },
              ),
            ),
          ).animate().fadeIn(delay: 130.ms, duration: 320.ms),
          if (AppConstants.spotifyEnabled) ...[
            const SizedBox(height: 28),
            Padding(
              padding: VibraSpacing.pageHorizontal,
              child: hasSpotify
                  ? _MusicSnapshot(
                      artists: music!.topArtists.take(3).toList(),
                      onTap: () => context.push('/music-stats'),
                    )
                  : _SpotifyConnectCard(
                      actionLabel: l10n.myProfileConnectSpotify,
                      onTap: () => context.push('/spotify-connect'),
                    ),
            ).animate().fadeIn(delay: 180.ms, duration: 360.ms),
          ],
          const SizedBox(height: 32),
          Padding(
            padding: VibraSpacing.pageHorizontal,
            child: Text(
              l10n.myProfileOverview.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: t.textSecondary,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (AppConstants.spotifyEnabled)
            _ProfileNavigationRow(
              icon: Icons.graphic_eq_rounded,
              title: l10n.myProfileMusicStats,
              subtitle: l10n.myProfileMusicStatsSubtitle,
              onTap: () => context.push('/music-stats'),
            ).animate().fadeIn(delay: 230.ms, duration: 320.ms),
          _ProfileNavigationRow(
            icon: Icons.calendar_today_rounded,
            title: l10n.myProfileMyEvents,
            subtitle: l10n.myProfileMyEventsSubtitle(eventCount.toString()),
            onTap: () => context.push('/my-events'),
          ).animate().fadeIn(delay: 290.ms, duration: 320.ms),
          _ProfileNavigationRow(
            icon: Icons.tune_rounded,
            title: l10n.myProfileSettings,
            subtitle: l10n.myProfileSettingsSubtitle,
            onTap: () => context.push('/settings'),
          ).animate().fadeIn(delay: 350.ms, duration: 320.ms),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.avatarUrl,
    required this.displayName,
    required this.username,
    required this.bio,
    required this.hasSpotify,
    required this.onEdit,
  });

  final String? avatarUrl;
  final String displayName;
  final String username;
  final String? bio;
  final bool hasSpotify;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.vibraTokens;

    return VibraSurface(
      padding: EdgeInsets.zero,
      radius: VibraSpacing.radiusLarge,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(VibraSpacing.radiusLarge),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 252),
          child: VibraWaveBackdrop(
            color: t.accentPrimary,
            opacity: 0.46,
            height: 128,
            child: Padding(
              padding: const EdgeInsets.all(VibraSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VibraAvatar(
                        imageUrl: avatarUrl,
                        name: displayName,
                        radius: 38,
                        signalRing: true,
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: AppLocalizations.of(context)!.profileEditTitle,
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (hasSpotify)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: t.accentSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.graphic_eq_rounded,
                            color: t.accentPrimary,
                            size: 14,
                          ),
                          SizedBox(width: 5),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.profileSpotifyConnected,
                            style: TextStyle(
                              color: t.accentPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (hasSpotify) const SizedBox(height: 10),
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '@$username',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                    ),
                  ),
                  if (bio != null && bio!.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      bio!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: t.textPrimary.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats({
    required this.friendsCount,
    required this.followersCount,
    required this.followingCount,
    required this.onFriends,
    required this.onFollowers,
    required this.onFollowing,
  });

  final int friendsCount;
  final int followersCount;
  final int followingCount;
  final VoidCallback onFriends;
  final VoidCallback onFollowers;
  final VoidCallback onFollowing;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Row(
      children: [
        Expanded(
          child: _ProfileStat(
            value: friendsCount.toString(),
            label: AppLocalizations.of(context)!.friendsTitle,
            onTap: onFriends,
          ),
        ),
        Container(width: 1, height: 42, color: t.borderStrong),
        Expanded(
          child: _ProfileStat(
            value: followersCount.toString(),
            label: AppLocalizations.of(context)!.profileFollowers,
            onTap: onFollowers,
          ),
        ),
        Container(width: 1, height: 42, color: t.borderStrong),
        Expanded(
          child: _ProfileStat(
            value: followingCount.toString(),
            label: AppLocalizations.of(context)!.profileFollowing,
            onTap: onFollowing,
          ),
        ),
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.value,
    required this.label,
    required this.onTap,
  });

  final String value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.vibraTokens;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: t.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(label, style: theme.textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _MusicSnapshot extends StatelessWidget {
  const _MusicSnapshot({required this.artists, required this.onTap});

  final List<MusicArtistPreference> artists;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.vibraTokens;

    return VibraSurface(
      onTap: onTap,
      semanticLabel: AppLocalizations.of(context)!.profileOpenMusicStats,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.profileYourVibra,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: t.textSecondary,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Icon(Icons.arrow_outward_rounded, size: 18, color: t.textPrimary),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.profileInRotation,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 14),
          if (artists.isEmpty)
            Text(
              AppLocalizations.of(context)!.profileSyncMusicBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: t.textSecondary,
              ),
            )
          else
            ...List.generate(artists.length, (index) {
              final artist = artists[index];
              final rank = index + 1;
              return Padding(
                padding: EdgeInsets.only(top: index == 0 ? 0 : 8),
                child: Row(
                  children: [
                    Text(
                      rank < 10 ? '0$rank' : '$rank',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: t.accentPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        artist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.north_east_rounded,
                      size: 15,
                      color: t.textSecondary,
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _SpotifyConnectCard extends StatelessWidget {
  const _SpotifyConnectCard({required this.actionLabel, required this.onTap});

  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.vibraTokens;

    return VibraSurface(
      color: t.surfaceMuted,
      padding: const EdgeInsets.all(VibraSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 42,
            child: VibraSignalWave(
              height: 42,
              color: t.accentPrimary,
              secondaryColor: t.accentSecondary,
              amplitude: 9,
              animate: true,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.profileShapeTitle,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 5),
          Text(
            AppLocalizations.of(context)!.profileShapeBody,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          VibraButton(
            label: actionLabel,
            leadingIcon: Icons.link_rounded,
            tone: VibraButtonTone.ink,
            onPressed: onTap,
            expanded: true,
          ),
        ],
      ),
    );
  }
}

class _ProfileNavigationRow extends StatelessWidget {
  const _ProfileNavigationRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.vibraTokens;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: VibraSpacing.pagePadding,
        vertical: 4,
      ),
      child: VibraSurface(
        onTap: onTap,
        semanticLabel: title,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Icon(icon, size: 20, color: t.accentPrimary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_outward_rounded, size: 18, color: t.textSecondary),
          ],
        ),
      ),
    );
  }
}
