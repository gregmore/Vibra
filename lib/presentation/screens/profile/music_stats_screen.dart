import 'package:intl/intl.dart';
import 'package:vibra/presentation/localization/user_facing_error.dart';
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
import '../../providers/spotify_auth_provider.dart';
import '../../widgets/common/vibra_button.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_surface.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/vibra_signal_wave.dart';

class MusicStatsScreen extends ConsumerStatefulWidget {
  const MusicStatsScreen({super.key});

  @override
  ConsumerState<MusicStatsScreen> createState() => _MusicStatsScreenState();
}

class _MusicStatsScreenState extends ConsumerState<MusicStatsScreen> {
  bool _refreshing = false;
  bool _requiresReconnect = false;

  @override
  void initState() {
    super.initState();
    if (AppConstants.spotifyEnabled) Future.microtask(_loadAndSync);
  }

  Future<void> _loadAndSync() async {
    if (!AppConstants.spotifyEnabled || !mounted) return;
    await ref.read(myMusicProfileProvider.notifier).refresh();
    if (!mounted || ref.read(myMusicProfileProvider).lastSyncedAt == null) {
      return;
    }
    await _syncSpotify(showSuccess: false);
  }

  Future<void> _reconnectSpotify() async {
    if (!AppConstants.spotifyEnabled) return;
    await context.push('/spotify-connect');
    if (mounted) await _loadAndSync();
  }

  Future<void> _syncSpotify({bool showSuccess = true}) async {
    if (!AppConstants.spotifyEnabled ||
        _refreshing ||
        ref.read(spotifyAuthProvider).status ==
            SpotifyAuthStatus.syncingProfile) {
      return;
    }
    setState(() => _refreshing = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(spotifyAuthProvider.notifier).syncSpotify();
      if (!mounted) return;
      final result = ref.read(spotifyAuthProvider);
      if (result.status == SpotifyAuthStatus.error) {
        _requiresReconnect =
            result.errorMessage?.contains('spotify_not_connected') ?? false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _requiresReconnect
                  ? AppLocalizations.of(context)!.musicReconnectBody
                  : l10n.musicStatsSyncError(
                      userFacingError(l10n, result.errorMessage),
                    ),
            ),
            action: _requiresReconnect
                ? SnackBarAction(
                    label: AppLocalizations.of(context)!.musicReconnect,
                    onPressed: _reconnectSpotify,
                  )
                : null,
          ),
        );
      } else if (result.status == SpotifyAuthStatus.success) {
        _requiresReconnect = false;
        if (!showSuccess) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.musicStatsUpdated),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userFacingError(l10n, error))));
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!AppConstants.spotifyEnabled) {
      return VibraPageScaffold(
        appBar: AppBar(title: Text(l10n.spotifyUnavailableTitle)),
        child: VibraEmptyView(
          title: l10n.spotifyUnavailableTitle,
          message: l10n.spotifyUnavailableBody,
          icon: Icons.event_available_rounded,
          actionLabel: l10n.navEvents,
          onActionTap: () => context.go('/explore'),
        ),
      );
    }
    final musicProfile = ref.watch(myMusicProfileProvider);
    final hasSpotify = musicProfile.lastSyncedAt != null;
    final isSyncing =
        _refreshing ||
        ref.watch(spotifyAuthProvider).status ==
            SpotifyAuthStatus.syncingProfile;
    final artists = ref.watch(topArtistsStatsProvider);
    final heatmap = ref.watch(listeningHeatmapProvider);
    return VibraPageScaffold(
      appBar: AppBar(
        title: Text(l10n.musicStatsTitle),
        actions: [
          if (hasSpotify)
            IconButton(
              icon: isSyncing
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        semanticsLabel: AppLocalizations.of(
                          context,
                        )!.musicStatsRefreshing,
                        color: context.vibraTokens.accentPrimary,
                      ),
                    )
                  : const Icon(Icons.sync_rounded),
              tooltip: l10n.musicStatsSyncSpotify,
              onPressed: isSyncing ? null : () => _syncSpotify(),
            ),
        ],
      ),
      child: hasSpotify
          ? ListView(
              padding: const EdgeInsets.only(bottom: 48),
              children: [
                Padding(
                      padding: const EdgeInsets.fromLTRB(
                        VibraSpacing.pagePadding,
                        12,
                        VibraSpacing.pagePadding,
                        0,
                      ),
                      child: _ListeningHero(artistsCount: artists.length),
                    )
                    .animate()
                    .fadeIn(duration: 320.ms)
                    .slideY(begin: 0.03, end: 0),
                const SizedBox(height: 32),
                Padding(
                  padding: VibraSpacing.pageHorizontal,
                  child: _SectionLead(
                    eyebrow: AppLocalizations.of(context)!.musicStatsArtists,
                    title: l10n.musicStatsTopArtists,
                    subtitle: l10n.musicStatsTopArtistsSub,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: VibraSpacing.pageHorizontal,
                  child: artists.isEmpty
                      ? _NoMusicData(
                          label: AppLocalizations.of(
                            context,
                          )!.musicStatsNoArtists,
                        )
                      : _ArtistList(artists: artists),
                ).animate().fadeIn(delay: 80.ms, duration: 360.ms),
                const SizedBox(height: 32),
                Padding(
                  padding: VibraSpacing.pageHorizontal,
                  child: _SectionLead(
                    eyebrow: AppLocalizations.of(context)!.musicStatsRhythm,
                    title: l10n.musicStatsHeatmap,
                    subtitle: l10n.musicStatsHeatmapSub,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: VibraSpacing.pageHorizontal,
                  child: _ListeningHeatmap(points: heatmap),
                ).animate().fadeIn(delay: 190.ms, duration: 420.ms),
              ],
            )
          : _SpotifyEmptyState(
              onConnect: () => context.push('/spotify-connect'),
            ),
    );
  }
}

class _SpotifyEmptyState extends StatelessWidget {
  const _SpotifyEmptyState({required this.onConnect});

  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.vibraTokens;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(VibraSpacing.pagePadding),
        child: VibraSurface(
          color: t.surfaceMuted,
          padding: const EdgeInsets.all(VibraSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 74,
                child: VibraSignalWave(
                  height: 74,
                  color: t.textPrimary,
                  secondaryColor: t.accentPrimary,
                  amplitude: 18,
                  animate: true,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.musicStatsEmptyTitle,
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.musicStatsEmptyBody,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: t.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              VibraButton(
                label: AppLocalizations.of(context)!.spotifyConnectTitle,
                leadingIcon: Icons.link_rounded,
                onPressed: onConnect,
                expanded: true,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 360.ms);
  }
}

class _ListeningHero extends StatelessWidget {
  const _ListeningHero({required this.artistsCount});

  final int artistsCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.vibraTokens;

    return VibraSurface(
      color: t.imageOverlay,
      borderColor: t.borderStrong,
      padding: EdgeInsets.zero,
      radius: VibraSpacing.radiusLarge,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(VibraSpacing.radiusLarge),
        child: SizedBox(
          height: 182,
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: VibraSignalWave(
                      height: 120,
                      color: t.accentPrimary,
                      secondaryColor: t.onImage,
                      amplitude: 28,
                      strokeWidth: 2.3,
                      opacity: 0.88,
                      animate: true,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(VibraSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.musicStatsYourSound,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: t.onImageMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.musicStatsHeroTitle,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: t.onImage,
                        height: 1.02,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _HeroMetric(
                          value: artistsCount.toString(),
                          label: AppLocalizations.of(
                            context,
                          )!.musicStatsArtists,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.vibraTokens;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: value,
            style: theme.textTheme.titleLarge?.copyWith(color: t.onImage),
          ),
          TextSpan(
            text: '  $label',
            style: theme.textTheme.labelMedium?.copyWith(color: t.onImageMuted),
          ),
        ],
      ),
    );
  }
}

class _SectionLead extends StatelessWidget {
  const _SectionLead({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.vibraTokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: theme.textTheme.labelSmall?.copyWith(
            color: t.textSecondary,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 5),
        Text(title, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(color: t.textSecondary),
        ),
      ],
    );
  }
}

class _ArtistList extends StatelessWidget {
  const _ArtistList({required this.artists});

  final List<MusicArtistPreference> artists;

  @override
  Widget build(BuildContext context) {
    return VibraSurface(
      padding: EdgeInsets.zero,
      child: Column(
        children: List.generate(artists.length, (index) {
          final artist = artists[index];
          return _ArtistRank(
            rank: index + 1,
            name: artist.name,
            score: artist.score,
            showDivider: index != artists.length - 1,
          );
        }),
      ),
    );
  }
}

class _ArtistRank extends StatelessWidget {
  const _ArtistRank({
    required this.rank,
    required this.name,
    required this.score,
    required this.showDivider,
  });

  final int rank;
  final String name;
  final int score;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.vibraTokens;
    final progress = score.clamp(0, 100).toDouble() / 100;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              SizedBox(
                width: 42,
                child: Text(
                  rank < 10 ? '0$rank' : '$rank',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: t.accentPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            Container(
                              height: 4,
                              width: double.infinity,
                              color: t.surfaceMuted,
                            ),
                            Container(
                              height: 4,
                              width: constraints.maxWidth * progress,
                              color: t.accentPrimary,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
            color: t.borderDefault,
          ),
      ],
    );
  }
}

class _ListeningHeatmap extends StatelessWidget {
  const _ListeningHeatmap({required this.points});

  final List<MusicStatPoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.vibraTokens;

    return VibraSurface(
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 14),
      child: SizedBox(
        height: 168,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(points.length, (index) {
            final point = points[index];
            final value = point.value.clamp(0.0, 1.0).toDouble();
            final active = value > 0;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 112 * value + (active ? 4 : 0),
                          decoration: BoxDecoration(
                            color: active ? t.accentPrimary : t.surfaceMuted,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      DateFormat.E(
                        Localizations.localeOf(context).toString(),
                      ).format(DateTime(2026, 1, 5 + index)),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: t.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NoMusicData extends StatelessWidget {
  const _NoMusicData({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return VibraSurface(
      color: t.surfaceMuted,
      child: Row(
        children: [
          Icon(Icons.graphic_eq_rounded, color: t.accentPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
