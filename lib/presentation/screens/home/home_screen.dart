import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/vibra_motion.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/entities/music_profile.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/music_story_providers.dart';
import '../../providers/vibra_ai_providers.dart';
import '../../widgets/home_signature.dart';
import '../../widgets/common/vibra_avatar.dart';
import '../../widgets/common/vibra_button.dart';
import '../../widgets/common/vibra_editorial_event.dart';
import '../../widgets/common/vibra_logo.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_section_header.dart';
import '../../widgets/common/vibra_surface.dart';
import '../../widgets/music_story_widgets.dart';
import '../notifications/notification_center_screen.dart';

/// Home: music discovery first.
///
/// Hierarchy, top to bottom: who you are (greeting + sound status), the
/// strongest recommendations as full posters, your artists, then nearby and
/// trending as dense rows.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<void> _refresh() {
    ref.invalidate(storyRingProvider);
    return ref.read(allEventsProvider.notifier).refresh();
  }

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final l10n = AppLocalizations.of(context)!;
    if (hour < 12) return l10n.homeGreetingMorning;
    if (hour < 18) return l10n.homeGreetingAfternoon;
    return l10n.homeGreetingEvening;
  }

  void _openEvent(Event event) => context.push('/event-detail', extra: event);

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final featured = ref.watch(featuredEventsProvider);
    final nearby = ref.watch(nearbyEventsProvider);
    final trending = ref.watch(trendingEventsProvider);
    final profile = ref.watch(myProfileProvider);
    final l10n = AppLocalizations.of(context)!;
    final displayName = profile.displayName ?? profile.username;
    final hasSpotify =
        AppConstants.spotifyEnabled &&
        profile.spotifyId != null &&
        profile.spotifyId!.isNotEmpty;
    final topArtists = hasSpotify
        ? ref.watch(topArtistsStatsProvider)
        : const <MusicArtistPreference>[];
    final needsAvatar = profile.avatarUrl == null || profile.avatarUrl!.isEmpty;

    final feedStatus = ref.watch(eventsFeedStatusProvider);
    if (feedStatus.isLoading && featured.isEmpty) return const _HomeSkeleton();

    var section = 0;
    Widget reveal(Widget child) => _Reveal(index: section++, child: child);

    return VibraPageScaffold(
      useGradient: false,
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Brand bar ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  VibraSpacing.pagePadding,
                  VibraSpacing.md,
                  VibraSpacing.md,
                  0,
                ),
                child: Row(
                  children: [
                    const VibraWordmark(markSize: 20),
                    const Spacer(),
                    const NotificationBell(),
                    Semantics(
                      button: true,
                      label: l10n.navProfile,
                      child: InkResponse(
                        onTap: () => context.go('/profile'),
                        radius: 28,
                        child: Padding(
                          padding: const EdgeInsets.all(VibraSpacing.xs),
                          child: VibraAvatar(
                            imageUrl: profile.avatarUrl,
                            name: displayName,
                            radius: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Music Stories ─────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: VibraSpacing.lg),
                child: StoryRing(),
              ),
            ),

            // ── Greeting ──────────────────────────────────────
            SliverToBoxAdapter(
              child: reveal(
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    VibraSpacing.pagePadding,
                    VibraSpacing.xxl,
                    VibraSpacing.pagePadding,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.spotifyEnabled
                            ? l10n.homeYourSoundToday
                            : l10n.launchExploreTitle.toUpperCase(),
                        style: VibraTextStyles.labelSmall.copyWith(
                          color: t.accentPrimary,
                        ),
                      ),
                      const SizedBox(height: VibraSpacing.sm),
                      Semantics(
                        header: true,
                        child: Text(
                          [_getGreeting(context), displayName].join(', '),
                          style: VibraTextStyles.headlineLarge.copyWith(
                            color: t.textPrimary,
                          ),
                        ),
                      ),
                      if (!AppConstants.spotifyEnabled) ...[
                        const SizedBox(height: VibraSpacing.sm),
                        Text(
                          l10n.launchExploreBody,
                          style: VibraTextStyles.bodyMedium.copyWith(
                            color: t.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // ── Spotify status ────────────────────────────────
            if (AppConstants.spotifyEnabled)
              SliverToBoxAdapter(
                child: reveal(
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      VibraSpacing.pagePadding,
                      VibraSpacing.xl,
                      VibraSpacing.pagePadding,
                      0,
                    ),
                    child: hasSpotify
                        ? const _SpotifyConnectedStrip()
                        : _ActionRow(
                            icon: Icons.graphic_eq_rounded,
                            title: l10n.homeSpotifyBannerTitle,
                            body: l10n.homeSpotifyPersonalize,
                            highlighted: true,
                            onTap: () => context.push('/spotify-connect'),
                          ),
                  ),
                ),
              ),

            // ── Signature: find your people through music ─────
            if (AppConstants.spotifyEnabled)
              SliverToBoxAdapter(
                child: reveal(
                  const Padding(
                    padding: EdgeInsets.fromLTRB(
                      VibraSpacing.pagePadding,
                      VibraSpacing.sectionGap,
                      VibraSpacing.pagePadding,
                      0,
                    ),
                    child: HomeSignatureSection(),
                  ),
                ),
              ),

            // ── Daily Vibe ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  VibraSpacing.pagePadding,
                  VibraSpacing.lg,
                  VibraSpacing.pagePadding,
                  0,
                ),
                child: VibraSurface(
                  onTap: () => context.push('/daily-vibe'),
                  semanticLabel: l10n.vibeTitle,
                  padding: const EdgeInsets.all(VibraSpacing.lg),
                  child: Row(
                    children: [
                      Icon(
                        Icons.graphic_eq_rounded,
                        color: context.vibraTokens.accentPrimary,
                      ),
                      const SizedBox(width: VibraSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.vibeQuestion,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              l10n.vibeHomeCta,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: context.vibraTokens.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: context.vibraTokens.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ── VIBRA Feed ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  VibraSpacing.pagePadding,
                  VibraSpacing.md,
                  VibraSpacing.pagePadding,
                  0,
                ),
                child: VibraSurface(
                  onTap: () => context.push('/feed'),
                  semanticLabel: l10n.feedTitle,
                  padding: const EdgeInsets.all(VibraSpacing.lg),
                  child: Row(
                    children: [
                      Icon(
                        Icons.dynamic_feed_rounded,
                        color: context.vibraTokens.accentPrimary,
                      ),
                      const SizedBox(width: VibraSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.feedTitle,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              l10n.feedHomeCta,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: context.vibraTokens.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: context.vibraTokens.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ── Discover my next artist ───────────────────────
            if (AppConstants.spotifyEnabled)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    VibraSpacing.pagePadding,
                    VibraSpacing.md,
                    VibraSpacing.pagePadding,
                    0,
                  ),
                  child: VibraSurface(
                    onTap: () => context.push('/discover-artists'),
                    semanticLabel: l10n.discoverTitle,
                    padding: const EdgeInsets.all(VibraSpacing.lg),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_search_rounded,
                          color: context.vibraTokens.accentPrimary,
                        ),
                        const SizedBox(width: VibraSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.discoverTitle,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              Text(
                                l10n.discoverHomeCta,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: context.vibraTokens.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: context.vibraTokens.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // ── VIBRA AI (optional: hidden when unavailable) ──
            if (ref.watch(aiStatusProvider).valueOrNull?.available == true)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    VibraSpacing.pagePadding,
                    VibraSpacing.md,
                    VibraSpacing.pagePadding,
                    0,
                  ),
                  child: VibraSurface(
                    onTap: () => context.push('/assistant'),
                    semanticLabel: l10n.aiTitle,
                    padding: const EdgeInsets.all(VibraSpacing.lg),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: context.vibraTokens.accentPrimary,
                        ),
                        const SizedBox(width: VibraSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.aiTitle,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              Text(
                                l10n.aiHomeCta,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: context.vibraTokens.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: context.vibraTokens.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // ── For you / Events ──────────────────────────────
            SliverToBoxAdapter(
              child: reveal(
                VibraSectionHeader(
                  eyebrow: l10n.homeNextEvent,
                  title: AppConstants.spotifyEnabled
                      ? l10n.homeForYouTitle
                      : l10n.navEvents,
                  large: true,
                  actionLabel: l10n.commonAll,
                  // "For you" opens the Concert Finder (recommendations with
                  // reasons and filters); without music features, Explore.
                  onActionTap: () => AppConstants.spotifyEnabled
                      ? context.push('/concerts')
                      : context.go('/explore'),
                  padding: const EdgeInsets.fromLTRB(
                    VibraSpacing.pagePadding,
                    VibraSpacing.sectionGap,
                    VibraSpacing.sm,
                    VibraSpacing.lg,
                  ),
                ),
              ),
            ),
            if (featured.isNotEmpty)
              SliverToBoxAdapter(
                child: reveal(
                  _FeaturedCarousel(events: featured, onOpen: _openEvent),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: VibraSpacing.pageHorizontal,
                  child: _HomeEmptyEvents(
                    onTap: () => context.go('/explore'),
                    hasError: feedStatus.hasError,
                    onRetry: _refresh,
                  ),
                ),
              ),

            // ── Profile completion ────────────────────────────
            if (needsAvatar)
              SliverToBoxAdapter(
                child: reveal(
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      VibraSpacing.pagePadding,
                      VibraSpacing.xl,
                      VibraSpacing.pagePadding,
                      0,
                    ),
                    child: _ActionRow(
                      icon: Icons.person_add_alt_1_rounded,
                      title: l10n.homeShapeVibra,
                      semanticLabel: l10n.homeCompleteProfile,
                      onTap: () => context.push('/profile'),
                    ),
                  ),
                ),
              ),

            // ── Your artists (Spotify) ────────────────────────
            if (topArtists.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: VibraSectionHeader(
                  title: l10n.musicStatsTopArtists,
                  actionLabel: l10n.commonAll,
                  onActionTap: () => context.push('/music-stats'),
                  padding: const EdgeInsets.fromLTRB(
                    VibraSpacing.pagePadding,
                    VibraSpacing.sectionGap,
                    VibraSpacing.sm,
                    VibraSpacing.md,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _ArtistStrip(artists: topArtists)),
            ],

            // ── Public launch destinations ────────────────────
            if (!AppConstants.spotifyEnabled)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    VibraSpacing.pagePadding,
                    VibraSpacing.xxl,
                    VibraSpacing.pagePadding,
                    0,
                  ),
                  child: Column(
                    children: [
                      _ActionRow(
                        icon: Icons.people_outline_rounded,
                        title: l10n.launchCommunityTitle,
                        body: l10n.launchCommunityBody,
                        onTap: () => context.go('/social-match'),
                      ),
                      const SizedBox(height: VibraSpacing.md),
                      _ActionRow(
                        icon: Icons.bookmark_outline_rounded,
                        title: l10n.launchSavedTitle,
                        body: l10n.launchSavedBody,
                        onTap: () => context.push('/my-events'),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Nearby ────────────────────────────────────────
            if (nearby.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: VibraSectionHeader(
                  eyebrow: l10n.homeNearbyEyebrow,
                  title: l10n.homeNearYouTitle,
                  actionLabel: l10n.homeNearYouAction,
                  onActionTap: () => context.go('/explore'),
                  padding: const EdgeInsets.fromLTRB(
                    VibraSpacing.pagePadding,
                    VibraSpacing.sectionGap,
                    VibraSpacing.sm,
                    VibraSpacing.sm,
                  ),
                ),
              ),
              SliverPadding(
                padding: VibraSpacing.pageHorizontal,
                sliver: SliverList.builder(
                  itemCount: nearby.length,
                  itemBuilder: (context, index) => _Reveal(
                    index: index,
                    child: VibraEventRow(
                      event: nearby[index],
                      onTap: () => _openEvent(nearby[index]),
                    ),
                  ),
                ),
              ),
            ],

            // ── Trending ──────────────────────────────────────
            if (trending.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: VibraSectionHeader(
                  eyebrow: l10n.homeTrendingEyebrow,
                  title: l10n.homeTrendingTitle,
                  actionLabel: l10n.homeTrendingAction,
                  onActionTap: () => context.go('/explore'),
                  padding: const EdgeInsets.fromLTRB(
                    VibraSpacing.pagePadding,
                    VibraSpacing.sectionGap,
                    VibraSpacing.sm,
                    VibraSpacing.sm,
                  ),
                ),
              ),
              SliverPadding(
                padding: VibraSpacing.pageHorizontal,
                sliver: SliverList.builder(
                  itemCount: trending.length,
                  itemBuilder: (context, index) => _Reveal(
                    index: index,
                    child: VibraEventRow(
                      event: trending[index],
                      onTap: () => _openEvent(trending[index]),
                    ),
                  ),
                ),
              ),
            ],
            const SliverPadding(
              padding: EdgeInsets.only(bottom: VibraSpacing.navBarClearance),
            ),
          ],
        ),
      ),
    );
  }
}

/// One-shot staggered entrance (fade + 8 px rise). Static under reduced
/// motion and after the first build.
class _Reveal extends StatelessWidget {
  const _Reveal({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final delay = VibraMotion.staggerFor(context, index);
    final duration = VibraMotion.durationFor(context, VibraMotion.reveal);
    if (duration == Duration.zero) return child;
    final total = duration + delay;
    final start = delay.inMicroseconds / total.inMicroseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      builder: (context, value, child) {
        final v = Interval(start, 1, curve: VibraMotion.enter).transform(value);
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - v)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _FeaturedCarousel extends StatefulWidget {
  const _FeaturedCarousel({required this.events, required this.onOpen});

  final List<Event> events;
  final ValueChanged<Event> onOpen;

  @override
  State<_FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<_FeaturedCarousel> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final width = MediaQuery.sizeOf(context).width;
    final single = widget.events.length == 1;
    final cardWidth = single
        ? width - VibraSpacing.pagePadding * 2
        : (width - VibraSpacing.pagePadding * 2) * .9;
    final height = (cardWidth * 1.3).clamp(360.0, 460.0);
    return Column(
      children: [
        SizedBox(
          height: height,
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.axis == Axis.horizontal) {
                final page = (n.metrics.pixels / (cardWidth + VibraSpacing.md))
                    .round()
                    .clamp(0, widget.events.length - 1);
                if (page != _page) setState(() => _page = page);
              }
              return false;
            },
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: VibraSpacing.pageHorizontal,
              itemCount: widget.events.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: VibraSpacing.md),
              itemBuilder: (context, index) => SizedBox(
                width: cardWidth,
                child: VibraEventFeature(
                  event: widget.events[index],
                  height: height,
                  onTap: () => widget.onOpen(widget.events[index]),
                ),
              ),
            ),
          ),
        ),
        if (!single) ...[
          const SizedBox(height: VibraSpacing.md),
          ExcludeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.events.length; i++)
                  AnimatedContainer(
                    duration: VibraMotion.durationFor(
                      context,
                      VibraMotion.medium,
                    ),
                    curve: VibraMotion.signalCurve,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 18 : 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: i == _page ? t.textPrimary : t.borderStrong,
                      borderRadius: VibraSpacing.borderFull,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SpotifyConnectedStrip extends StatelessWidget {
  const _SpotifyConnectedStrip();

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: t.success, shape: BoxShape.circle),
        ),
        const SizedBox(width: VibraSpacing.sm),
        Expanded(
          child: Text(
            l10n.homeSpotifySynced,
            maxLines: 2,
            style: VibraTextStyles.bodySmall.copyWith(color: t.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _ArtistStrip extends StatelessWidget {
  const _ArtistStrip({required this.artists});

  final List<MusicArtistPreference> artists;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: VibraSpacing.pageHorizontal,
        itemCount: artists.length,
        separatorBuilder: (_, _) => const SizedBox(width: VibraSpacing.md),
        itemBuilder: (context, index) {
          final artist = artists[index];
          return SizedBox(
            width: 112,
            child: VibraSurface(
              padding: const EdgeInsets.all(VibraSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (index + 1).toString().padLeft(2, '0'),
                    style: VibraTextStyles.scoreMedium.copyWith(
                      color: index == 0 ? t.accentPrimary : t.textMuted,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    artist.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: VibraTextStyles.titleSmall.copyWith(
                      color: t.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.body,
    this.semanticLabel,
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String? body;
  final String? semanticLabel;
  final VoidCallback onTap;

  /// Violet-tinted variant for the single most important nudge.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return VibraSurface(
      onTap: onTap,
      semanticLabel: semanticLabel ?? title,
      color: highlighted ? t.accentSoft : null,
      borderColor: highlighted ? t.accentPrimary.withValues(alpha: .35) : null,
      padding: const EdgeInsets.all(VibraSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: t.surfaceMuted,
              borderRadius: VibraSpacing.borderSmall,
            ),
            child: Icon(
              icon,
              color: t.accentPrimary,
              size: VibraSpacing.iconMd,
            ),
          ),
          const SizedBox(width: VibraSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: VibraTextStyles.titleSmall.copyWith(
                    color: t.textPrimary,
                  ),
                ),
                if (body != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    body!,
                    style: VibraTextStyles.bodySmall.copyWith(
                      color: t.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: VibraSpacing.sm),
          Icon(
            Icons.chevron_right_rounded,
            size: VibraSpacing.iconMd,
            color: t.textMuted,
          ),
        ],
      ),
    );
  }
}

class _HomeEmptyEvents extends StatelessWidget {
  const _HomeEmptyEvents({
    required this.onTap,
    required this.hasError,
    required this.onRetry,
  });

  final bool hasError;
  final VoidCallback onRetry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final accent = hasError ? t.error : t.accentPrimary;
    return VibraSurface(
      padding: const EdgeInsets.all(VibraSpacing.xl),
      onTap: hasError ? null : onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .14),
              borderRadius: VibraSpacing.borderMedium,
            ),
            child: Icon(
              hasError ? Icons.wifi_off_rounded : Icons.map_outlined,
              color: accent,
            ),
          ),
          const SizedBox(height: VibraSpacing.lg),
          Text(
            hasError ? l10n.homeFeedError : l10n.homeFeedEmpty,
            style: VibraTextStyles.titleLarge.copyWith(color: t.textPrimary),
          ),
          const SizedBox(height: VibraSpacing.xs),
          Text(
            hasError ? l10n.homeFeedErrorBody : l10n.homeFeedEmptyBody,
            style: VibraTextStyles.bodySmall.copyWith(color: t.textSecondary),
          ),
          const SizedBox(height: VibraSpacing.lg),
          if (hasError)
            VibraButton(
              label: l10n.commonRetry,
              onPressed: onRetry,
              tone: VibraButtonTone.outline,
              size: VibraButtonSize.compact,
              leadingIcon: Icons.refresh_rounded,
            )
          else
            VibraButton(
              label: l10n.homeNearYouAction,
              onPressed: onTap,
              tone: VibraButtonTone.secondary,
              size: VibraButtonSize.compact,
              leadingIcon: Icons.map_outlined,
            ),
        ],
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    Widget block(double? w, double h, [double r = 8]) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: t.surfaceElevated,
        borderRadius: BorderRadius.circular(r),
      ),
    );
    return VibraPageScaffold(
      useGradient: false,
      child: Semantics(
        label: AppLocalizations.of(context)!.commonLoading,
        child: Shimmer.fromColors(
          baseColor: t.shimmerBase,
          highlightColor: t.shimmerHighlight,
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              VibraSpacing.pagePadding,
              VibraSpacing.lg,
              VibraSpacing.pagePadding,
              VibraSpacing.navBarClearance,
            ),
            children: [
              Row(children: [block(96, 20), const Spacer(), block(36, 36, 18)]),
              const SizedBox(height: VibraSpacing.xxl),
              block(110, 11),
              const SizedBox(height: VibraSpacing.sm),
              block(260, 30),
              const SizedBox(height: VibraSpacing.sectionGap),
              block(150, 24),
              const SizedBox(height: VibraSpacing.lg),
              block(null, 420, VibraSpacing.radiusXL),
            ],
          ),
        ),
      ),
    );
  }
}
