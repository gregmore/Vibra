import '../../../core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../providers/app_state_providers.dart';
import '../../widgets/common/vibra_editorial_event.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_surface.dart';
import '../../widgets/vibra_signal_wave.dart';

/// La home mette un momento musicale davanti all'interfaccia, non una griglia.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<void> _refresh() => ref.read(allEventsProvider.notifier).refresh();

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final l10n = AppLocalizations.of(context)!;
    if (hour < 12) return l10n.homeGreetingMorning;
    if (hour < 18) return l10n.homeGreetingAfternoon;
    return l10n.homeGreetingEvening;
  }

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
    final needsProfile =
        (AppConstants.spotifyEnabled && !hasSpotify) ||
        profile.avatarUrl == null ||
        profile.avatarUrl!.isEmpty;

    final feedStatus = ref.watch(eventsFeedStatusProvider);
    if (feedStatus.isLoading && featured.isEmpty) return _HomeSkeleton();

    return VibraPageScaffold(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.spotifyEnabled
                          ? AppLocalizations.of(context)!.homeYourSoundToday
                          : l10n.launchExploreTitle.toUpperCase(),
                      style: VibraTextStyles.labelSmall.copyWith(
                        color: t.textSecondary,
                        letterSpacing: 1.25,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      [_getGreeting(context), displayName].join(', '),
                      style: VibraTextStyles.displayMedium,
                    ),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        SizedBox(
                          width: 54,
                          child: VibraSignalWave(
                            height: 16,
                            amplitude: 3,
                            color: t.accentPrimary,
                            secondaryColor: t.textPrimary,
                            animate: true,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            !AppConstants.spotifyEnabled
                                ? l10n.launchExploreBody
                                : hasSpotify
                                ? AppLocalizations.of(
                                    context,
                                  )!.homeSpotifySynced
                                : AppLocalizations.of(
                                    context,
                                  )!.homeSpotifyPersonalize,
                            style: VibraTextStyles.bodySmall,
                          ),
                        ),
                        if (AppConstants.spotifyEnabled && !hasSpotify)
                          TextButton(
                            onPressed: () => context.push('/spotify-connect'),
                            child: Text(
                              AppLocalizations.of(context)!.commonConnect,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 320.ms).slideY(begin: -0.04, end: 0),
            ),
            if (needsProfile)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                  child: VibraSurface(
                    color: t.accentSoft,
                    borderColor: t.accentPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    onTap: () => context.push('/profile'),
                    semanticLabel: AppLocalizations.of(
                      context,
                    )!.homeCompleteProfile,
                    child: Row(
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          color: t.textPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.homeShapeVibra,
                            style: TextStyle(
                              color: t.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_outward_rounded,
                          color: t.textPrimary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 80.ms, duration: 300.ms),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  needsProfile ? 28 : 30,
                  20,
                  12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.homeNextEvent,
                            style: VibraTextStyles.labelSmall.copyWith(
                              color: t.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppConstants.spotifyEnabled
                                ? l10n.homeForYouTitle
                                : l10n.navEvents,
                            style: VibraTextStyles.headlineLarge,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/explore'),
                      child: Text(AppLocalizations.of(context)!.commonAll),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 130.ms, duration: 320.ms),
            ),
            if (featured.isNotEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 420,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: featured.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, index) =>
                        SizedBox(
                          width: 304,
                          child: VibraEventFeature(
                            event: featured[index],
                            onTap: () => context.push(
                              '/event-detail',
                              extra: featured[index],
                            ),
                          ),
                        ).animate().fadeIn(
                          delay: Duration(milliseconds: 130 + index * 70),
                          duration: 380.ms,
                        ),
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _HomeEmptyEvents(
                    onTap: () => context.go('/explore'),
                    hasError: feedStatus.hasError,
                    onRetry: _refresh,
                  ),
                ),
              ),
            if (!AppConstants.spotifyEnabled)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    children: [
                      _LaunchDestination(
                        icon: Icons.people_outline_rounded,
                        title: l10n.launchCommunityTitle,
                        body: l10n.launchCommunityBody,
                        onTap: () => context.go('/social-match'),
                      ),
                      const SizedBox(height: 12),
                      _LaunchDestination(
                        icon: Icons.bookmark_outline_rounded,
                        title: l10n.launchSavedTitle,
                        body: l10n.launchSavedBody,
                        onTap: () => context.push('/my-events'),
                      ),
                    ],
                  ),
                ),
              ),
            if (nearby.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _EditorialSectionTitle(
                  eyebrow: AppLocalizations.of(context)!.homeNearbyEyebrow,
                  title: l10n.homeNearYouTitle,
                  action: l10n.homeNearYouAction,
                  onActionTap: () => context.go('/explore'),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.builder(
                  itemCount: nearby.length,
                  itemBuilder: (context, index) =>
                      VibraEventRow(
                        event: nearby[index],
                        onTap: () =>
                            context.push('/event-detail', extra: nearby[index]),
                        showDivider: index != nearby.length - 1,
                      ).animate().fadeIn(
                        delay: Duration(milliseconds: 100 + index * 45),
                        duration: 260.ms,
                      ),
                ),
              ),
            ],
            if (trending.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _EditorialSectionTitle(
                  eyebrow: AppLocalizations.of(context)!.homeTrendingEyebrow,
                  title: l10n.homeTrendingTitle,
                  action: l10n.homeTrendingAction,
                  onActionTap: () => context.go('/explore'),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 148),
                sliver: SliverList.builder(
                  itemCount: trending.length,
                  itemBuilder: (context, index) =>
                      VibraEventRow(
                        event: trending[index],
                        onTap: () => context.push(
                          '/event-detail',
                          extra: trending[index],
                        ),
                        showDivider: index != trending.length - 1,
                      ).animate().fadeIn(
                        delay: Duration(milliseconds: 100 + index * 45),
                        duration: 260.ms,
                      ),
                ),
              ),
            ] else
              const SliverPadding(padding: EdgeInsets.only(bottom: 148)),
          ],
        ),
      ),
    );
  }
}

class _LaunchDestination extends StatelessWidget {
  const _LaunchDestination({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => VibraSurface(
    onTap: onTap,
    semanticLabel: title,
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Icon(icon, color: context.vibraTokens.accentPrimary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: VibraTextStyles.titleMedium),
              const SizedBox(height: 4),
              Text(body, style: VibraTextStyles.bodySmall),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_outward_rounded, size: 18),
      ],
    ),
  );
}

class _EditorialSectionTitle extends StatelessWidget {
  const _EditorialSectionTitle({
    required this.eyebrow,
    required this.title,
    required this.action,
    required this.onActionTap,
  });

  final String eyebrow;
  final String title;
  final String action;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 38, 20, 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: VibraTextStyles.labelSmall.copyWith(
                    color: t.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(title, style: VibraTextStyles.headlineMedium),
              ],
            ),
          ),
          TextButton(onPressed: onActionTap, child: Text(action)),
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
    return VibraSurface(
      padding: const EdgeInsets.all(20),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: VibraSignalWave(
              height: 32,
              color: t.accentPrimary,
              secondaryColor: t.textPrimary,
              amplitude: 7,
              animate: true,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            hasError
                ? AppLocalizations.of(context)!.homeFeedError
                : AppLocalizations.of(context)!.homeFeedEmpty,
            style: VibraTextStyles.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            hasError
                ? AppLocalizations.of(context)!.homeFeedErrorBody
                : AppLocalizations.of(context)!.homeFeedEmptyBody,
            style: VibraTextStyles.bodySmall,
          ),
          if (hasError) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppLocalizations.of(context)!.commonRetry),
            ),
          ],
        ],
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return VibraPageScaffold(
      child: Shimmer.fromColors(
        baseColor: t.shimmerBase,
        highlightColor: t.shimmerHighlight,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 148),
          children: [
            Container(width: 110, height: 12, color: t.surfaceElevated),
            const SizedBox(height: 10),
            Container(width: 260, height: 38, color: t.surfaceElevated),
            const SizedBox(height: 40),
            Container(width: 150, height: 24, color: t.surfaceElevated),
            const SizedBox(height: 14),
            Container(height: 420, color: t.surfaceElevated),
          ],
        ),
      ),
    );
  }
}
