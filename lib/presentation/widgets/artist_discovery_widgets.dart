import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/vibra_colors.dart';
import '../../core/theme/vibra_spacing.dart';
import '../../core/theme/vibra_theme_tokens.dart';
import '../../domain/entities/artist_recommendation.dart';
import '../../l10n/app_localizations.dart';
import '../providers/artist_discovery_providers.dart';
import 'common/vibra_image.dart';
import 'common/vibra_surface.dart';

Future<void> openArtistOnSpotify(String url) async {
  final uri = Uri.tryParse(url);
  if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
}

String bucketLabel(AppLocalizations l10n, DiscoveryBucket b) => switch (b) {
  DiscoveryBucket.similar => l10n.discoverSimilar,
  DiscoveryBucket.collaboration => l10n.discoverCollaborations,
  DiscoveryBucket.emerging => l10n.discoverEmerging,
  DiscoveryBucket.underground => l10n.discoverUnderground,
  DiscoveryBucket.exploration => l10n.discoverExploration,
};

IconData bucketIcon(DiscoveryBucket b) => switch (b) {
  DiscoveryBucket.similar => Icons.graphic_eq_rounded,
  DiscoveryBucket.collaboration => Icons.handshake_outlined,
  DiscoveryBucket.emerging => Icons.trending_up_rounded,
  DiscoveryBucket.underground => Icons.diamond_outlined,
  DiscoveryBucket.exploration => Icons.explore_outlined,
};

class ArtistRecommendationCard extends ConsumerWidget {
  const ArtistRecommendationCard({required this.artist, super.key});
  final ArtistRecommendation artist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    final controller = ref.read(artistDiscoveryProvider.notifier);
    final reason = artist.seedArtist != null
        ? l10n.discoverReasonCollab(artist.seedArtist!)
        : artist.exploredGenre != null
        ? l10n.discoverReasonExplore(artist.exploredGenre!)
        : artist.sharedGenres.isNotEmpty
        ? l10n.discoverReasonGenres(artist.sharedGenres.join(', '))
        : null;

    Future<void> send({
      ArtistReaction? reaction,
      bool clear = false,
      bool? saved,
      required String done,
    }) async {
      final ok = await controller.feedback(
        artist,
        reaction: reaction,
        clearReaction: clear,
        saved: saved,
      );
      if (context.mounted) _snack(context, ok ? done : l10n.discoverError);
    }

    final liked = artist.reaction == ArtistReaction.like;
    return Padding(
      padding: const EdgeInsets.only(bottom: VibraSpacing.md),
      child: VibraSurface(
        padding: const EdgeInsets.all(VibraSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: SizedBox.square(
                    dimension: 64,
                    child: VibraNetworkImage(
                      url: artist.imageUrl,
                      cacheWidth: 200,
                      fallbackIcon: Icons.mic_external_on_rounded,
                    ),
                  ),
                ),
                const SizedBox(width: VibraSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            bucketIcon(artist.bucket),
                            size: 14,
                            color: t.accentPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            bucketLabel(l10n, artist.bucket).toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: t.accentPrimary,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        artist.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                      if (artist.genres.isNotEmpty)
                        Text(
                          artist.genres.take(3).join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: t.textSecondary,
                          ),
                        ),
                      if (reason != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            reason,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: t.textMuted,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: VibraSpacing.sm),
            Wrap(
              spacing: VibraSpacing.xs,
              runSpacing: VibraSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilterChip(
                  avatar: Icon(
                    liked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                    size: 18,
                  ),
                  label: Text(l10n.discoverLike),
                  selected: liked,
                  showCheckmark: false,
                  onSelected: (_) => liked
                      ? send(clear: true, done: l10n.discoverUndone)
                      : send(
                          reaction: ArtistReaction.like,
                          done: l10n.discoverLiked,
                        ),
                ),
                FilterChip(
                  avatar: Icon(
                    artist.saved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 18,
                  ),
                  label: Text(l10n.discoverSave),
                  selected: artist.saved,
                  showCheckmark: false,
                  onSelected: (_) => send(
                    saved: !artist.saved,
                    done: artist.saved
                        ? l10n.discoverUnsaved
                        : l10n.discoverSaved,
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.how_to_reg_outlined, size: 18),
                  label: Text(l10n.discoverKnown),
                  onPressed: () => send(
                    reaction: ArtistReaction.known,
                    done: l10n.discoverKnownDone,
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.not_interested_rounded, size: 18),
                  label: Text(l10n.discoverNotInterested),
                  onPressed: () => send(
                    reaction: ArtistReaction.notInterested,
                    done: l10n.discoverNotInterestedDone,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => openArtistOnSpotify(artist.spotifyUrl),
                  style: TextButton.styleFrom(
                    foregroundColor: VibraPalette.spotifyGreen,
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: Text(l10n.vibeListen),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _snack(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
