import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibra/l10n/app_localizations.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/core_providers.dart';
import '../../providers/music_affinity_providers.dart';
import '../../providers/public_users_provider.dart';

import '../../widgets/common/vibra_badge.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/common/vibra_input.dart';
import '../../widgets/common/vibra_surface.dart';
import '../../../domain/entities/friendship.dart';
import '../../providers/public_friends_provider.dart';
import '../../widgets/common/vibra_avatar.dart';
import '../../widgets/vibra_neon_avatar.dart';

class DiscoverUsersScreen extends ConsumerStatefulWidget {
  const DiscoverUsersScreen({super.key});

  @override
  ConsumerState<DiscoverUsersScreen> createState() =>
      _DiscoverUsersScreenState();
}

class _DiscoverUsersScreenState extends ConsumerState<DiscoverUsersScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      await Future.wait([
        ref.refresh(publicUsersProvider(_query).future),
        if (AppConstants.spotifyEnabled)
          ref.read(matchedUsersProvider.notifier).refresh(),
        ref.read(pendingFriendshipsProvider.notifier).refresh(),
      ]);
    } catch (_) {
      // Public search errors remain visible in the provider's error state.
    }
  }

  void _commitQuery(String value) {
    final query = String.fromCharCodes(value.trim().runes.take(100));
    setState(() => _query = query);
  }

  void _changeQuery(String value) {
    _searchDebounce?.cancel();
    setState(() {}); // Update the clear action while the query is debounced.
    _searchDebounce = Timer(const Duration(milliseconds: 330), () {
      if (mounted) _commitQuery(value);
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _commitQuery('');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    // People search is the same for everyone (server-side, by name or
    // username). Spotify adds the affinity layer on top, never replaces it.
    final publicUsers = ref.watch(publicUsersProvider(_query));
    final users = publicUsers.isLoading || publicUsers.hasError
        ? const <MatchedUserPreview>[]
        : publicUsers.asData?.value ?? const <MatchedUserPreview>[];
    final pending = ref.watch(pendingFriendshipsProvider);

    // Only requests addressed to me; sent ones live on the Friends screen.
    final accountId = pending.isEmpty
        ? null
        : ref.watch(supabaseDatasourceProvider).currentUser?.id;
    final received = pending
        .where((f) => f.status == 'pending' && f.receiverId == accountId)
        .toList(growable: false);

    return VibraPageScaffold(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                VibraSpacing.pagePadding,
                VibraSpacing.lg,
                VibraSpacing.pagePadding,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    if (GoRouter.maybeOf(context)?.canPop() ?? false)
                      BackButton(onPressed: () => context.pop()),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          l10n.socialTitle,
                          style: VibraTextStyles.headlineLarge.copyWith(
                            color: t.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    _HeaderAction(
                      icon: Icons.people_alt_outlined,
                      tooltip: l10n.friendsTitle,
                      count: pending.length,
                      onPressed: () => context.push('/friends'),
                    ),
                    const SizedBox(width: VibraSpacing.sm),
                    Builder(
                      builder: (context) {
                        final unreadCount = ref.watch(
                          totalUnreadMessagesCountProvider,
                        );
                        final requestCount = ref
                            .watch(messageRequestsProvider)
                            .length;
                        return _HeaderAction(
                          icon: Icons.chat_bubble_outline_rounded,
                          tooltip: l10n.navChat,
                          count: unreadCount + requestCount,
                          onPressed: () => context.push('/messages'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  VibraSpacing.pagePadding,
                  VibraSpacing.lg,
                  VibraSpacing.pagePadding,
                  0,
                ),
                child: VibraInput(
                  controller: _searchController,
                  hintText: l10n.launchCommunitySubtitle,
                  prefixIcon: Icons.search_rounded,
                  textInputAction: TextInputAction.search,
                  maxLength: 100,
                  onSubmitted: (value) {
                    _searchDebounce?.cancel();
                    _commitQuery(value);
                    FocusScope.of(context).unfocus();
                  },
                  onChanged: _changeQuery,
                  suffix: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: l10n.myEventsClearSearch,
                          icon: const Icon(Icons.close_rounded),
                          onPressed: _clearSearch,
                        ),
                ),
              ),
            ),
            if (received.isNotEmpty && _query.isEmpty)
              SliverToBoxAdapter(child: _RequestsCard(requests: received)),
            if (AppConstants.spotifyEnabled && _query.isEmpty)
              const SliverToBoxAdapter(child: _AffinityEntry()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  VibraSpacing.pagePadding + VibraSpacing.xs,
                  VibraSpacing.xxl,
                  VibraSpacing.pagePadding,
                  VibraSpacing.sm + 2,
                ),
                child: Semantics(
                  header: true,
                  child: Text(
                    (_query.isEmpty
                            ? l10n.socialPeopleSection
                            : l10n.socialDiscoverUsers)
                        .toUpperCase(),
                    style: VibraTextStyles.labelSmall.copyWith(
                      color: t.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            if (publicUsers.isLoading == true)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(VibraSpacing.xxl),
                  child: Center(child: VibraLoadingIndicator()),
                ),
              ),
            if (publicUsers.hasError == true)
              SliverToBoxAdapter(
                child: VibraErrorView(
                  error: publicUsers.error,
                  compact: true,
                  kind: VibraErrorKind.network,
                  title: l10n.commonConnectionError,
                  message: l10n.launchCommunityLoadError,
                  onRetry: () => ref.invalidate(publicUsersProvider(_query)),
                ),
              ),
            if (users.isEmpty &&
                publicUsers.isLoading != true &&
                publicUsers.hasError != true)
              SliverToBoxAdapter(
                child: Padding(
                  padding: VibraSpacing.pageHorizontal,
                  child: VibraEmptyView(
                    compact: true,
                    icon: _query.isEmpty
                        ? Icons.people_outline_rounded
                        : Icons.search_off_rounded,
                    title: l10n.launchCommunityEmptyTitle,
                    message: l10n.launchCommunityEmptyBody,
                    actionLabel: _query.isEmpty
                        ? l10n.commonRetry
                        : l10n.myEventsClearSearch,
                    onActionTap: _query.isEmpty ? _refresh : _clearSearch,
                  ),
                ),
              ),
            if (users.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: VibraSpacing.pageHorizontal,
                  child: VibraSurface(
                    padding: EdgeInsets.zero,
                    clip: true,
                    child: Column(
                      children: [
                        for (var i = 0; i < users.length; i++) ...[
                          if (i > 0)
                            Divider(
                              height: 1,
                              indent: 76,
                              color: t.borderDefault,
                            ),
                          _PersonRow(user: users[i]),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            const SliverToBoxAdapter(
              child: SizedBox(height: VibraSpacing.navBarClearance),
            ),
          ],
        ),
      ),
    );
  }
}

/// One person in the grouped list: avatar (with affinity ring when a real
/// Spotify match exists), name, @username · city, and a quick chat action.
class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.user});

  final MatchedUserPreview user;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final name = user.user.displayName ?? user.user.username;
    final affinity =
        AppConstants.spotifyEnabled &&
        (user.compatibility > 0 || user.topArtists.isNotEmpty);
    final meta = [
      '@${user.user.username}',
      if (user.city.isNotEmpty) user.city,
    ].join(' · ');
    return Semantics(
      button: true,
      label: affinity
          ? '$name, ${l10n.eventAffinitySemantics(user.compatibility)}'
          : name,
      child: InkWell(
        onTap: () => context.push('/user-profile', extra: user.user.id),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            VibraSpacing.lg,
            VibraSpacing.md,
            VibraSpacing.sm,
            VibraSpacing.md,
          ),
          child: Row(
            children: [
              if (affinity)
                VibraNeonAvatar(
                  imageUrl: user.user.avatarUrl ?? '',
                  radius: 22,
                  score: user.compatibility / 100.0,
                  displayName: name,
                )
              else
                VibraAvatar(
                  imageUrl: user.user.avatarUrl,
                  radius: 22,
                  name: name,
                ),
              const SizedBox(width: VibraSpacing.lg),
              Expanded(
                child: ExcludeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: VibraTextStyles.titleSmall.copyWith(
                          color: t.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: VibraTextStyles.caption.copyWith(
                          color: t.textSecondary,
                        ),
                      ),
                      if (affinity && user.topArtists.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          user.topArtists.take(3).join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: VibraTextStyles.caption.copyWith(
                            color: t.accentPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (affinity) ...[
                const SizedBox(width: VibraSpacing.sm),
                ExcludeSemantics(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: t.accentSoft,
                      borderRadius: VibraSpacing.borderFull,
                    ),
                    child: Text(
                      '${user.compatibility}%',
                      style: VibraTextStyles.labelSmall.copyWith(
                        color: t.accentPrimary,
                      ),
                    ),
                  ),
                ),
              ],
              IconButton(
                tooltip: l10n.navChat,
                onPressed: () => context.push(
                  '/chat',
                  extra: {
                    'otherUserId': user.user.id,
                    'otherDisplayName': name,
                  },
                ),
                icon: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: VibraSpacing.iconMd,
                  color: t.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Received friend requests as one compact card with stacked avatars of the
/// real senders (never raw IDs); opens the Friends screen to accept/reject.
class _RequestsCard extends ConsumerWidget {
  const _RequestsCard({required this.requests});

  final List<Friendship> requests;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final profiles =
        ref.watch(publicConnectionProfilesProvider).valueOrNull ??
        const <MatchedUserPreview>[];
    final senders = [
      for (final r in requests)
        profiles.where((p) => p.user.id == r.requesterId).firstOrNull,
    ];
    final first = senders.firstOrNull?.user;
    final firstName =
        first?.displayName ?? first?.username ?? l10n.friendsVibraUser;
    final shown = senders.take(3).toList(growable: false);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        VibraSpacing.pagePadding,
        VibraSpacing.lg,
        VibraSpacing.pagePadding,
        0,
      ),
      child: VibraSurface(
        onTap: () => context.push('/friends'),
        padding: const EdgeInsets.all(VibraSpacing.lg),
        child: Row(
          children: [
            SizedBox(
              width: 40.0 + (shown.length - 1) * 18,
              height: 40,
              child: Stack(
                children: [
                  for (var i = shown.length - 1; i >= 0; i--)
                    Positioned(
                      left: i * 18.0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: t.surface, width: 2),
                        ),
                        child: VibraAvatar(
                          imageUrl: shown[i]?.user.avatarUrl,
                          radius: 18,
                          name:
                              shown[i]?.user.displayName ??
                              shown[i]?.user.username,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: VibraSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.friendsReceivedRequests,
                    style: VibraTextStyles.titleSmall.copyWith(
                      color: t.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.socialRequestsPreview(firstName, requests.length - 1),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: VibraTextStyles.caption.copyWith(
                      color: t.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: VibraSpacing.sm),
            VibraCountBadge(count: requests.length),
            Icon(Icons.chevron_right_rounded, color: t.textMuted),
          ],
        ),
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.tooltip,
    required this.count,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          style: IconButton.styleFrom(backgroundColor: t.surface),
          icon: Icon(icon, size: VibraSpacing.iconMd),
        ),
        if (count > 0)
          Positioned(
            top: 0,
            right: 0,
            child: IgnorePointer(child: VibraCountBadge(count: count)),
          ),
      ],
    );
  }
}

/// Spotify layer on top of the public social graph: opens the affinity deck
/// when Spotify is connected, otherwise invites the user to connect it.
class _AffinityEntry extends ConsumerWidget {
  const _AffinityEntry();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(myProfileProvider);
    final hasSpotify =
        profile.spotifyId != null && profile.spotifyId!.isNotEmpty;
    // Spotify or hand-picked genres: either is enough for the affinity deck.
    final hasGenres =
        ref.watch(myGenrePreferencesProvider).valueOrNull?.isNotEmpty ?? false;
    final connected = hasSpotify || hasGenres;
    final matches = connected
        ? ref.watch(matchedUsersProvider).where((m) => !m.isFriend).length
        : 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        VibraSpacing.pagePadding,
        VibraSpacing.lg,
        VibraSpacing.pagePadding,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _affinityCard(context, t, l10n, connected, matches),
          const SizedBox(height: VibraSpacing.sm),
          // Discovery shortcuts in one compact row, so the people list stays
          // in view. Same Frequency and Radar need musical data. Equal
          // heights, whatever the label length.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (connected) ...[
                  Expanded(
                    child: _ShortcutTile(
                      icon: Icons.sensors_rounded,
                      label: l10n.sameFrequencyTitle,
                      onTap: () => context.push('/same-frequency'),
                    ),
                  ),
                  const SizedBox(width: VibraSpacing.sm),
                  Expanded(
                    child: _ShortcutTile(
                      icon: Icons.radar_rounded,
                      label: l10n.musicRadarTitle,
                      onTap: () => context.push('/music-radar'),
                    ),
                  ),
                  const SizedBox(width: VibraSpacing.sm),
                ],
                Expanded(
                  child: _ShortcutTile(
                    icon: Icons.groups_2_outlined,
                    label: l10n.communitiesTitle,
                    onTap: () => context.push('/communities'),
                  ),
                ),
                const SizedBox(width: VibraSpacing.sm),
                Expanded(
                  child: _ShortcutTile(
                    icon: Icons.bubble_chart_outlined,
                    label: l10n.circlesTitle,
                    onTap: () => context.push('/circles'),
                  ),
                ),
              ],
            ),
          ),
          if (!connected)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => context.push('/music-genres'),
                icon: const Icon(Icons.library_music_outlined, size: 18),
                label: Text(l10n.socialAffinityPickGenres),
              ),
            ),
        ],
      ),
    );
  }

  Widget _affinityCard(
    BuildContext context,
    VibraThemeTokens t,
    AppLocalizations l10n,
    bool connected,
    int matches,
  ) {
    return VibraSurface(
      onTap: () =>
          context.push(connected ? '/vibra-match' : '/spotify-connect'),
      semanticLabel: connected
          ? l10n.socialAffinityCount(matches)
          : l10n.myProfileConnectSpotify,
      color: t.accentSoft,
      borderColor: t.accentPrimary.withValues(alpha: .35),
      padding: const EdgeInsets.all(VibraSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: t.backgroundPrimary,
              borderRadius: VibraSpacing.borderSmall,
            ),
            child: Icon(Icons.graphic_eq_rounded, color: t.accentPrimary),
          ),
          const SizedBox(width: VibraSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.socialAffinityTitle,
                  style: VibraTextStyles.titleSmall.copyWith(
                    color: t.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  connected
                      ? l10n.socialAffinityCount(matches)
                      : l10n.socialConnectSpotifyBody,
                  style: VibraTextStyles.bodySmall.copyWith(
                    color: t.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: VibraSpacing.sm),
          if (connected)
            Icon(Icons.chevron_right_rounded, color: t.textSecondary)
          else
            ExcludeSemantics(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: VibraSpacing.md,
                  vertical: VibraSpacing.xs + 2,
                ),
                decoration: BoxDecoration(
                  color: t.accentFill,
                  borderRadius: VibraSpacing.borderFull,
                ),
                child: Text(
                  l10n.commonConnect,
                  style: VibraTextStyles.labelMedium.copyWith(
                    color: t.onAccent,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return VibraSurface(
      onTap: onTap,
      semanticLabel: label,
      padding: const EdgeInsets.symmetric(
        horizontal: VibraSpacing.sm,
        vertical: VibraSpacing.md,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: t.textPrimary, size: VibraSpacing.iconLg),
          const SizedBox(height: VibraSpacing.xs),
          // One word per line, scaled down only when a word is wider than
          // the tile: a label never breaks inside a word ("Communit-ies").
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label.trim().split(RegExp(r'\s+')).join('\n'),
              textAlign: TextAlign.center,
              style: VibraTextStyles.labelMedium.copyWith(color: t.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
