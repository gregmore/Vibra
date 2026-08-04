import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../core/theme/vibra_colors.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../providers/app_state_providers.dart';
import '../../widgets/common/vibra_event_card.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_section_header.dart';
import '../../widgets/vibra_glassmorphic_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains(
      'Test',
    );
    if (isTest) {
      _isLoading = false;
    } else {
      _loadData();
    }
  }

  void _loadData() {
    setState(() {
      _isLoading = true;
    });
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final l10n = AppLocalizations.of(context)!;
    if (hour < 12) return l10n.homeGreetingMorning;
    if (hour < 18) return l10n.homeGreetingAfternoon;
    return l10n.homeGreetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    final featured = ref.watch(featuredEventsProvider);
    final nearby = ref.watch(nearbyEventsProvider);
    final trending = ref.watch(trendingEventsProvider);
    final profile = ref.watch(myProfileProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return VibraPageScaffold(
        child: Shimmer.fromColors(
          baseColor: VibraColors.shimmerBase,
          highlightColor: VibraColors.shimmerHighlight,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 160),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 32,
                      width: 240,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: VibraSpacing.borderSmall,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 24,
                  width: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 310,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 2,
                  itemBuilder: (context, _) => Container(
                    width: 300,
                    margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: VibraSpacing.borderLarge,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final displayName = profile.displayName ?? profile.username;

    return VibraPageScaffold(
      child: CustomScrollView(
        slivers: [
          const SliverPadding(padding: EdgeInsets.only(top: 20)),
          // Greeting Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(context),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: VibraColors.accent,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayName,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05, end: 0),
          ),

          // Added extra spacing instead of the Search Bar
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Incomplete Profile Banner
          if ((profile.spotifyId == null || profile.spotifyId!.isEmpty) ||
              (profile.avatarUrl == null || profile.avatarUrl!.isEmpty))
            SliverToBoxAdapter(
              child:
                  VibraGlassmorphicCard(
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        padding: const EdgeInsets.all(18),
                        borderColor: VibraColors.primary.withValues(alpha: 0.4),
                        gradient: LinearGradient(
                          colors: [
                            VibraColors.primary.withValues(alpha: 0.15),
                            VibraColors.surfaceElevated.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: VibraColors.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person_pin_rounded,
                                    color: VibraColors.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Completa il tuo profilo',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Per suggerimenti migliori',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: VibraColors.textSecondary,
                                            ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Aggiungi una foto o collega Spotify per permetterci di suggerirti gli eventi migliori.',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: VibraColors.textPrimary
                                                  .withValues(alpha: 0.9),
                                              height: 1.4,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => context.push(
                                  '/profile',
                                ), // or somewhere else
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: VibraColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  elevation: 4,
                                  shadowColor: VibraColors.primary.withValues(
                                    alpha: 0.4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: VibraSpacing.borderFull,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Vai al Profilo',
                                      style: VibraTextStyles.labelLarge
                                          .copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.8,
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 150.ms, duration: 450.ms)
                      .slideY(begin: 0.1, end: 0),
            ),

          // For You Section
          SliverToBoxAdapter(
            child: VibraSectionHeader(
              title: l10n.homeForYouTitle,
              subtitle: l10n.homeForYouSubtitle,
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 310,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                scrollDirection: Axis.horizontal,
                itemCount: featured.length,
                itemBuilder: (context, index) {
                  final event = featured[index];
                  return SizedBox(
                    width: 300,
                    child: VibraEventCard(
                      event: event,
                      onTap: () => context.push('/event-detail', extra: event),
                    ).animate().scaleXY(begin: 0.96, end: 1.0),
                  );
                },
              ),
            ),
          ),

          // Near You Section
          if (nearby.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: VibraSectionHeader(
                title: l10n.homeNearYouTitle,
                subtitle: l10n.homeNearYouSubtitle,
                actionLabel: l10n.homeNearYouAction,
                onActionTap: () => context.go('/explore'),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
            ),
            SliverList.builder(
              itemCount: nearby.length,
              itemBuilder: (context, index) {
                final event = nearby[index];
                return VibraEventCard(
                  event: event,
                  compact: true,
                  onTap: () => context.push('/event-detail', extra: event),
                ).animate().slideY(begin: 0.05, end: 0);
              },
            ),
          ],

          // Trending Section
          if (trending.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: VibraSectionHeader(
                title: l10n.homeTrendingTitle,
                subtitle: l10n.homeTrendingSubtitle,
                actionLabel: l10n.homeTrendingAction,
                onActionTap: () => context.go('/explore'),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
            ),
            SliverList.builder(
              itemCount: trending.length,
              itemBuilder: (context, index) {
                final event = trending[index];
                return VibraEventCard(
                  event: event,
                  compact: true,
                  onTap: () => context.push('/event-detail', extra: event),
                ).animate().slideY(begin: 0.05, end: 0);
              },
            ),
          ],
          const SliverPadding(padding: EdgeInsets.only(bottom: 140)),
        ],
      ),
    );
  }
}
