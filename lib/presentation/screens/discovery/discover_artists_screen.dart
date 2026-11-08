import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/artist_recommendation.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/artist_discovery_providers.dart';
import '../../providers/core_providers.dart';
import '../../widgets/common/vibra_image.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/artist_discovery_widgets.dart';

void _snack(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

/// "Discover my next artist" (docs/artist-discovery.md): similar artists,
/// collaborators, emerging and underground artists and new genres, with
/// feedback that shapes the next recommendations.
class DiscoverArtistsScreen extends ConsumerStatefulWidget {
  const DiscoverArtistsScreen({super.key});

  @override
  ConsumerState<DiscoverArtistsScreen> createState() =>
      _DiscoverArtistsScreenState();
}

class _DiscoverArtistsScreenState extends ConsumerState<DiscoverArtistsScreen> {
  DiscoveryBucket? _filter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final async = ref.watch(artistDiscoveryProvider);
    final controller = ref.read(artistDiscoveryProvider.notifier);
    return VibraPageScaffold(
      appBar: AppBar(
        title: Text(l10n.discoverTitle),
        actions: [
          IconButton(
            tooltip: l10n.discoverSavedTitle,
            icon: const Icon(Icons.bookmarks_outlined),
            onPressed: () => context.push('/saved-artists'),
          ),
          IconButton(
            tooltip: l10n.discoverRefresh,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: async.isLoading
                ? null
                : () async {
                    await controller.refresh();
                    if (!context.mounted) return;
                    if (ref.read(artistDiscoveryProvider).hasError) {
                      _snack(context, l10n.discoverRefreshLimited);
                    }
                  },
          ),
        ],
      ),
      child: async.when(
        skipLoadingOnRefresh: false,
        loading: () => const VibraLoadingView(),
        error: (e, _) => VibraErrorView(
          error: e,
          title: l10n.discoverTitle,
          message: l10n.discoverError,
          retryLabel: l10n.commonRetry,
          onRetry: () => ref.invalidate(artistDiscoveryProvider),
        ),
        data: (result) {
          if (result.artists.isEmpty) {
            return VibraEmptyView(
              title: l10n.discoverEmptyTitle,
              message: result.emptyReason == 'no_profile'
                  ? l10n.discoverNoProfile
                  : result.providerUnavailable
                  ? l10n.vibeProviderUnavailable
                  : l10n.discoverEmptyBody,
              icon: Icons.person_search_rounded,
              actionLabel: result.emptyReason == 'no_profile'
                  ? l10n.discoverPickGenres
                  : null,
              onActionTap: result.emptyReason == 'no_profile'
                  ? () => context.push('/music-genres')
                  : null,
            );
          }
          final present = {for (final a in result.artists) a.bucket};
          final shown = [
            for (final a in result.artists)
              if (_filter == null || a.bucket == _filter) a,
          ];
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              VibraSpacing.pagePadding,
              VibraSpacing.xs,
              VibraSpacing.pagePadding,
              VibraSpacing.colossal,
            ),
            children: [
              Text(
                l10n.discoverIntro,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
              ),
              const SizedBox(height: VibraSpacing.sm),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: VibraSpacing.xs),
                      child: ChoiceChip(
                        label: Text(l10n.discoverAll),
                        selected: _filter == null,
                        onSelected: (_) => setState(() => _filter = null),
                      ),
                    ),
                    for (final b in DiscoveryBucket.values)
                      if (present.contains(b))
                        Padding(
                          padding: const EdgeInsets.only(
                            right: VibraSpacing.xs,
                          ),
                          child: ChoiceChip(
                            avatar: Icon(bucketIcon(b), size: 18),
                            label: Text(bucketLabel(l10n, b)),
                            selected: _filter == b,
                            onSelected: (_) => setState(() => _filter = b),
                          ),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: VibraSpacing.md),
              for (final a in shown)
                ArtistRecommendationCard(key: ValueKey(a.artistId), artist: a),
              Text(
                l10n.storyAttribution,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: t.textMuted),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Artists saved for later.
class SavedArtistsScreen extends ConsumerWidget {
  const SavedArtistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return VibraPageScaffold(
      appBar: AppBar(title: Text(l10n.discoverSavedTitle)),
      child: ref
          .watch(savedArtistsProvider)
          .when(
            loading: () => const VibraLoadingView(),
            error: (e, _) => VibraErrorView(
              error: e,
              title: l10n.discoverSavedTitle,
              message: l10n.discoverError,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(savedArtistsProvider),
            ),
            data: (list) => list.isEmpty
                ? VibraEmptyView(
                    title: l10n.discoverSavedEmpty,
                    message: l10n.discoverSavedEmptyBody,
                    icon: Icons.bookmark_border_rounded,
                  )
                : ListView(
                    padding: const EdgeInsets.all(VibraSpacing.pagePadding),
                    children: [
                      for (final a in list)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: ClipOval(
                            child: SizedBox.square(
                              dimension: 48,
                              child: VibraNetworkImage(
                                url: a.imageUrl,
                                cacheWidth: 120,
                                fallbackIcon: Icons.mic_external_on_rounded,
                              ),
                            ),
                          ),
                          title: Text(a.name),
                          subtitle: a.liked ? Text(l10n.discoverLike) : null,
                          onTap: () => openArtistOnSpotify(a.spotifyUrl),
                          trailing: IconButton(
                            tooltip: l10n.discoverUnsaved,
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () async {
                              try {
                                await ref
                                    .read(
                                      supabaseArtistDiscoveryDatasourceProvider,
                                    )
                                    .feedback(
                                      a.artistId,
                                      reaction: a.liked
                                          ? ArtistReaction.like
                                          : null,
                                      saved: false,
                                    );
                                ref.invalidate(savedArtistsProvider);
                              } catch (_) {
                                if (context.mounted) {
                                  _snack(context, l10n.discoverError);
                                }
                              }
                            },
                          ),
                        ),
                    ],
                  ),
          ),
    );
  }
}
