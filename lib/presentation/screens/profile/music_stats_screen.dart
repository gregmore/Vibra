import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/vibra_colors.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/spotify_auth_provider.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_section_header.dart';
import 'package:vibra/l10n/app_localizations.dart';

class MusicStatsScreen extends ConsumerWidget {
  const MusicStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicProfile = ref.watch(myMusicProfileProvider);
    final hasSpotify = musicProfile.lastSyncedAt != null;
    
    final artists = ref.watch(topArtistsStatsProvider);
    final heatmap = ref.watch(listeningHeatmapProvider);
    final theme = Theme.of(context);

    return VibraPageScaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.musicStatsTitle),
        actions: [
          if (hasSpotify)
            IconButton(
              icon: const Icon(Icons.sync_rounded),
              tooltip: AppLocalizations.of(context)!.musicStatsSyncSpotify,
              onPressed: () async {
                try {
                  await ref.read(spotifyAuthProvider.notifier).syncSpotify();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.musicStatsSyncError(e.toString()))),
                    );
                  }
                }
              },
            ),
        ],
      ),
      child: !hasSpotify
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.graphic_eq_rounded, size: 64, color: VibraColors.textSecondary.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text('Collega Spotify', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Scopri i tuoi artisti più ascoltati e la tua heatmap musicale collegando il tuo account Spotify.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: VibraColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/spotify-connect'),
                      icon: const Icon(Icons.graphic_eq_rounded),
                      label: const Text('Connetti Spotify'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1DB954),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms)
          : ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const SizedBox(height: 8),
          VibraSectionHeader(
            title: AppLocalizations.of(context)!.musicStatsTopArtists,
            subtitle: AppLocalizations.of(context)!.musicStatsTopArtistsSub,
          ).animate().fadeIn(duration: 400.ms),
          ...artists.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final artist = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 54,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: VibraColors.surfaceVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: VibraColors.glassBorder,
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: artist.score / 100.0,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: VibraColors.primaryGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: VibraColors.primary.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '#${index + 1}  ${artist.name}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (80 * index).ms, duration: 400.ms).slideX(begin: -0.05, end: 0);
            },
          ),
          const SizedBox(height: 16),

          const SizedBox(height: 24),
          VibraSectionHeader(
            title: AppLocalizations.of(context)!.musicStatsHeatmap,
            subtitle: AppLocalizations.of(context)!.musicStatsHeatmapSub,
          ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: heatmap.asMap().entries
                  .map(
                    (entry) {
                      final index = entry.key;
                      final point = entry.value;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            children: [
                              Container(
                                height: 120 * point.value,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      VibraColors.primary,
                                      VibraColors.accent,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: VibraColors.accent.withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(delay: (400 + index * 50).ms, duration: 600.ms).scaleY(begin: 0.0, end: 1.0, alignment: Alignment.bottomCenter),
                              const SizedBox(height: 8),
                              Text(point.label, style: theme.textTheme.labelMedium),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
