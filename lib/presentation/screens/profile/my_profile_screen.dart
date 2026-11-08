import '../../../core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../providers/core_providers.dart';
import '../../providers/profile_identity_providers.dart';
import '../../../domain/entities/profile_identity.dart';
import '../../widgets/profile_identity_widgets.dart';
import '../../providers/app_state_providers.dart';
import '../../widgets/common/vibra_editorial_event.dart';
import '../../widgets/common/vibra_section_header.dart';
import '../../widgets/common/vibra_settings.dart';
import '../../widgets/common/vibra_surface.dart';

class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(myProfileProvider);
    final myEvents = ref.watch(myEventsProvider);
    final friends = ref.watch(friendsProvider);
    final followStats = ref.watch(userFollowStatsProvider(me.id));
    final identity = me.id.isEmpty
        ? null
        : ref.watch(profileIdentityProvider(me.id)).valueOrNull;
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final displayName = me.displayName ?? me.username;
    final hasSpotify =
        AppConstants.spotifyEnabled &&
        me.spotifyId != null &&
        me.spotifyId!.isNotEmpty;
    final eventCount = myEvents.going.length + myEvents.saved.length;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcoming =
        myEvents.going
            .where((e) => !e.eventDate.toLocal().isBefore(today))
            .toList()
          ..sort((a, b) => a.eventDate.compareTo(b.eventDate));

    void openFollowList(int tab) => context.push(
      '/follow-list',
      extra: {
        'userId': me.id,
        'displayName': displayName,
        'initialTabIndex': tab,
      },
    );

    return Scaffold(
      backgroundColor: t.backgroundPrimary,
      body: CustomScrollView(
        slivers: [
          // Collapsing header: the large title folds into the bar, and the
          // settings action stays fully visible while scrolling.
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: t.backgroundPrimary,
            surfaceTintColor: Colors.transparent,
            toolbarHeight: 64,
            titleSpacing: VibraSpacing.pagePadding,
            title: Text(
              l10n.navProfile,
              style: VibraTextStyles.headlineMedium.copyWith(
                color: t.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                tooltip: l10n.myProfileSettings,
                onPressed: () => context.push('/settings'),
                style: IconButton.styleFrom(backgroundColor: t.surface),
                icon: const Icon(Icons.settings_outlined, size: 22),
              ),
              const SizedBox(width: VibraSpacing.md),
            ],
          ),
          // Musical identity: the avatar ringed by the Musical DNA.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                VibraSpacing.pagePadding,
                VibraSpacing.md,
                VibraSpacing.pagePadding,
                0,
              ),
              child: IdentityHero(
                name: displayName,
                username: me.username,
                avatarUrl: me.avatarUrl,
                bio: me.bio,
                dna: identity?.dna,
                memberSince: identity?.memberSince,
                actions: [
                  OutlinedButton.icon(
                    onPressed: () => context.push('/edit-profile'),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(l10n.profileEditTitle),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/profile-privacy'),
                    icon: const Icon(Icons.lock_outline_rounded, size: 18),
                    label: Text(l10n.profilePrivacyTitle),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                VibraSpacing.pagePadding,
                VibraSpacing.xxl,
                VibraSpacing.pagePadding,
                0,
              ),
              child: _ProfileStats(
                stats: [
                  (
                    friends.length,
                    l10n.friendsTitle,
                    () => context.push('/friends'),
                  ),
                  (
                    followStats.followersCount,
                    l10n.profileFollowers,
                    () => openFollowList(0),
                  ),
                  (
                    followStats.followingCount,
                    l10n.profileFollowing,
                    () => openFollowList(1),
                  ),
                  (
                    eventCount,
                    l10n.profileStatEvents,
                    () => context.push('/my-events'),
                  ),
                ],
              ),
            ),
          ),
          if (AppConstants.spotifyEnabled && !hasSpotify)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  VibraSpacing.pagePadding,
                  VibraSpacing.xl,
                  VibraSpacing.pagePadding,
                  0,
                ),
                child: _SpotifyConnectCard(
                  actionLabel: l10n.myProfileConnectSpotify,
                  onTap: () => context.push('/spotify-connect'),
                ),
              ),
            ),
          // Every identity section, with who can see it.
          if (identity != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  VibraSpacing.pagePadding,
                  VibraSpacing.xl,
                  VibraSpacing.pagePadding,
                  0,
                ),
                // Followers and upcoming events are already on this screen.
                child: IdentitySections(
                  identity: identity,
                  exclude: const {ProfileSection.events},
                ),
              ),
            ),
          if (upcoming.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: VibraSectionHeader(
                eyebrow: l10n.myEventsGoing,
                title: l10n.myEventsUpcoming,
                actionLabel: l10n.commonAll,
                onActionTap: () => context.push('/my-events'),
                padding: const EdgeInsets.fromLTRB(
                  VibraSpacing.pagePadding,
                  VibraSpacing.sectionGap,
                  VibraSpacing.sm,
                  VibraSpacing.xs,
                ),
              ),
            ),
            SliverList.builder(
              itemCount: upcoming.length.clamp(0, 2),
              itemBuilder: (context, index) => Padding(
                padding: VibraSpacing.pageHorizontal,
                child: VibraEventRow(
                  event: upcoming[index],
                  onTap: () =>
                      context.push('/event-detail', extra: upcoming[index]),
                ),
              ),
            ),
          ],
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              VibraSpacing.pagePadding,
              VibraSpacing.sectionGap,
              VibraSpacing.pagePadding,
              VibraSpacing.navBarClearance - VibraSpacing.xxl,
            ),
            sliver: SliverToBoxAdapter(
              child: VibraSettingsSection(
                label: l10n.myProfileOverview,
                children: [
                  if (AppConstants.spotifyEnabled)
                    VibraSettingsTile(
                      icon: Icons.graphic_eq_rounded,
                      title: l10n.myProfileMusicStats,
                      subtitle: hasSpotify
                          ? l10n.myProfileMusicStatsSubtitle
                          : l10n.myProfileConnectSpotify,
                      onTap: () => context.push(
                        hasSpotify ? '/music-stats' : '/spotify-connect',
                      ),
                    ),
                  if (AppConstants.spotifyEnabled)
                    VibraSettingsTile(
                      icon: Icons.donut_large_rounded,
                      title: l10n.musicalDnaProfileTile,
                      subtitle: l10n.musicalDnaProfileTileSubtitle,
                      onTap: () => context.push('/musical-dna'),
                    ),
                  VibraSettingsTile(
                    icon: Icons.dynamic_feed_rounded,
                    title: l10n.feedYourPosts,
                    subtitle: l10n.feedYourPostsSubtitle,
                    onTap: () {
                      final me = ref
                          .read(supabaseFeedDatasourceProvider)
                          .currentUserId;
                      if (me != null) {
                        context.push('/user-posts', extra: {'userId': me});
                      }
                    },
                  ),
                  if (AppConstants.spotifyEnabled)
                    VibraSettingsTile(
                      icon: Icons.person_search_rounded,
                      title: l10n.discoverSavedTitle,
                      subtitle: l10n.discoverSavedSubtitle,
                      onTap: () => context.push('/saved-artists'),
                    ),
                  VibraSettingsTile(
                    icon: Icons.library_music_outlined,
                    title: l10n.discoveriesTitle,
                    subtitle: l10n.discoveriesSubtitle,
                    onTap: () => context.push('/discoveries'),
                  ),
                  VibraSettingsTile(
                    icon: Icons.bookmarks_outlined,
                    title: l10n.feedSavedTitle,
                    subtitle: l10n.feedSavedSubtitle,
                    onTap: () => context.push('/feed-saved'),
                  ),
                  VibraSettingsTile(
                    icon: Icons.bookmark_outline_rounded,
                    title: l10n.myProfileMyEvents,
                    subtitle: l10n.myProfileMyEventsSubtitle(
                      eventCount.toString(),
                    ),
                    onTap: () => context.push('/my-events'),
                  ),
                  VibraSettingsTile(
                    icon: Icons.health_and_safety_outlined,
                    title: l10n.safetyTitle,
                    subtitle: l10n.safetySettingsSubtitle,
                    onTap: () => context.push('/safety'),
                  ),
                  VibraSettingsTile(
                    icon: Icons.settings_outlined,
                    title: l10n.myProfileSettings,
                    subtitle: l10n.myProfileSettingsSubtitle,
                    onTap: () => context.push('/settings'),
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

class _ProfileStats extends StatelessWidget {
  const _ProfileStats({required this.stats});

  final List<(int, String, VoidCallback)> stats;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return VibraSurface(
      padding: const EdgeInsets.symmetric(vertical: VibraSpacing.sm),
      child: Row(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) Container(width: 1, height: 28, color: t.borderDefault),
            Expanded(
              child: _ProfileStat(
                value: stats[i].$1.toString(),
                label: stats[i].$2,
                onTap: stats[i].$3,
              ),
            ),
          ],
        ],
      ),
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
    final t = context.vibraTokens;
    return Semantics(
      button: true,
      label: '$value $label',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: VibraSpacing.borderSmall,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: VibraSpacing.sm),
          child: Column(
            children: [
              Text(
                value,
                style: VibraTextStyles.scoreLarge.copyWith(
                  color: t.textPrimary,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: VibraSpacing.xs),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: VibraTextStyles.caption.copyWith(
                  color: t.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
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
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    return VibraSurface(
      onTap: onTap,
      semanticLabel: actionLabel,
      color: t.accentSoft,
      borderColor: t.accentPrimary.withValues(alpha: .3),
      padding: const EdgeInsets.all(VibraSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: t.backgroundPrimary,
              borderRadius: VibraSpacing.borderMedium,
            ),
            child: Icon(Icons.graphic_eq_rounded, color: t.accentPrimary),
          ),
          const SizedBox(width: VibraSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.profileShapeTitle,
                  style: VibraTextStyles.titleSmall.copyWith(
                    color: t.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.profileSpotifyBenefits,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: VibraTextStyles.caption.copyWith(
                    color: t.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: VibraSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: VibraSpacing.md,
              vertical: VibraSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: t.accentFill,
              borderRadius: VibraSpacing.borderFull,
            ),
            child: Text(
              l10n.commonConnect,
              style: VibraTextStyles.labelMedium.copyWith(color: t.onAccent),
            ),
          ),
        ],
      ),
    );
  }
}
