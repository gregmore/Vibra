import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/event_recommendation.dart';
import '../../../l10n/app_localizations.dart';
import '../../localization/music_affinity_text.dart';
import '../../providers/concert_providers.dart';
import '../../providers/musical_dna_providers.dart';
import '../../widgets/common/vibra_editorial_event.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/common/vibra_surface.dart';

/// Smart Concert Finder (docs/concert-intelligence.md): upcoming events
/// ranked by the user's musical identity, each with the reasons it was
/// recommended, and filters for genre, artist, date, distance and price.
class ConcertFinderScreen extends ConsumerWidget {
  const ConcertFinderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final filters = ref.watch(concertFiltersProvider);
    final results = ref.watch(concertRecommendationsProvider(filters));
    return VibraPageScaffold(
      appBar: AppBar(title: Text(l10n.concertTitle)),
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(concertRecommendationsProvider(filters));
          await ref.read(concertRecommendationsProvider(filters).future);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            VibraSpacing.pagePadding,
            VibraSpacing.sm,
            VibraSpacing.pagePadding,
            VibraSpacing.colossal,
          ),
          children: [
            Text(
              l10n.concertHeadline,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: VibraSpacing.lg),
            const _Filters(),
            const SizedBox(height: VibraSpacing.lg),
            ...results.when(
              loading: () => [const VibraLoadingIndicator()],
              error: (e, _) => [
                VibraErrorView(
                  error: e,
                  compact: true,
                  title: l10n.concertTitle,
                  message: l10n.concertLoadError,
                  retryLabel: l10n.commonRetry,
                  onRetry: () =>
                      ref.invalidate(concertRecommendationsProvider(filters)),
                ),
              ],
              data: (r) => [
                if (r.needsMusicProfile)
                  VibraEmptyView(
                    compact: true,
                    title: l10n.concertNoProfileTitle,
                    message: l10n.concertNoProfileBody,
                    icon: Icons.graphic_eq_rounded,
                    actionLabel: l10n.musicalDnaPickGenres,
                    onActionTap: () => context.push('/music-genres'),
                  )
                else ...[
                  if (r.origin == RecommendationOrigin.none)
                    Padding(
                      padding: const EdgeInsets.only(bottom: VibraSpacing.md),
                      child: Text(
                        l10n.concertLocationNote,
                        style: TextStyle(color: context.vibraTokens.textMuted),
                      ),
                    ),
                  if (r.events.isEmpty)
                    VibraEmptyView(
                      compact: true,
                      title: l10n.concertEmpty,
                      message: l10n.concertEmptyBody,
                      icon: Icons.event_busy_outlined,
                    )
                  else
                    for (final e in r.events)
                      Padding(
                        padding: const EdgeInsets.only(bottom: VibraSpacing.lg),
                        child: RecommendedEventCard(item: e),
                      ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Human sentences for the server's reasons.
List<String> eventReasonTexts(AppLocalizations l10n, RecommendedEvent e) => [
  for (final r in e.reasons)
    switch (r) {
      TopArtistEventReason(:final artist, :final rank) =>
        l10n.concertReasonTopArtist(artist, rank),
      TrackArtistEventReason(:final artist) => l10n.concertReasonTrackArtist(
        artist,
      ),
      SavedArtistEventReason(:final artist) => l10n.concertReasonSavedArtist(
        artist,
      ),
      GenreEventReason(:final genre, :final percent) => l10n.concertReasonGenre(
        genreLabel(l10n, genre),
        percent,
      ),
      SimilarToSavedEventReason(:final family) =>
        l10n.concertReasonSimilarToSaved(genreFamilyLabel(l10n, family)),
      DistanceEventReason(:final km) => l10n.concertReasonDistance(km),
      SoonEventReason(:final days) => l10n.concertReasonSoon(days),
    },
];

class RecommendedEventCard extends StatelessWidget {
  const RecommendedEventCard({required this.item, super.key});

  final RecommendedEvent item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    final reasons = eventReasonTexts(l10n, item);
    final genres = [for (final f in item.families) genreFamilyLabel(l10n, f)];
    return VibraSurface(
      padding: const EdgeInsets.all(VibraSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VibraEventRow(
            event: item.event,
            matchScore: item.relevance,
            onTap: () => context.push('/event-detail', extra: item.event),
          ),
          if (genres.isNotEmpty || item.saved)
            Padding(
              padding: const EdgeInsets.only(top: VibraSpacing.sm),
              child: Wrap(
                spacing: VibraSpacing.xs,
                runSpacing: VibraSpacing.xs,
                children: [
                  for (final g in genres) _Tag(g),
                  if (item.saved) _Tag(l10n.concertSaved, accent: true),
                ],
              ),
            ),
          if (reasons.isNotEmpty) ...[
            const SizedBox(height: VibraSpacing.md),
            Text(
              l10n.concertWhy.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: t.textMuted,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: VibraSpacing.xs),
            for (final line in reasons.take(4))
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: t.accentPrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: VibraSpacing.sm),
                    Expanded(
                      child: Text(
                        line,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: t.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, {this.accent = false});
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: accent ? t.accentSoft : t.surfaceElevated,
        borderRadius: BorderRadius.circular(VibraSpacing.radiusFull),
        border: Border.all(color: accent ? t.accentPrimary : t.borderDefault),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: accent ? t.accentPrimary : t.textSecondary,
        ),
      ),
    );
  }
}

class _Filters extends ConsumerStatefulWidget {
  const _Filters();

  @override
  ConsumerState<_Filters> createState() => _FiltersState();
}

class _FiltersState extends ConsumerState<_Filters> {
  final _artist = TextEditingController();

  @override
  void dispose() {
    _artist.dispose();
    super.dispose();
  }

  void _set(ConcertFilters Function(ConcertFilters) f) {
    final n = ref.read(concertFiltersProvider.notifier);
    n.state = f(n.state);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final f = ref.watch(concertFiltersProvider);
    final dna = ref.watch(myMusicalDnaHistoryProvider).valueOrNull;
    final families = [
      for (final fam
          in (dna?.isNotEmpty ?? false ? dna!.first.families : const []).take(
            6,
          ))
        fam.key,
    ];
    final now = DateTime.now();
    final euro = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toString(),
      name: 'EUR',
      decimalDigits: 0,
    );
    Widget row(String label, List<Widget> chips) => Padding(
      padding: const EdgeInsets.only(bottom: VibraSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.vibraTokens.textMuted,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: VibraSpacing.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final c in chips)
                  Padding(
                    padding: const EdgeInsets.only(right: VibraSpacing.xs),
                    child: c,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    ChoiceChip chip(String label, bool selected, VoidCallback onTap) =>
        ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
        );
    DateTime days(int n) => DateTime(now.year, now.month, now.day + n, 23, 59);
    final dateOptions = <(String, DateTime?)>[
      (l10n.concertDateAny, null),
      (l10n.concertDateWeek, days(7)),
      (l10n.concertDateMonth, days(30)),
      (l10n.concertDate3Months, days(90)),
    ];
    bool sameDay(DateTime? a, DateTime? b) =>
        a == null || b == null ? a == b : a.difference(b).inHours.abs() < 24;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _artist,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.concertArtistHint,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: f.artist == null
                ? null
                : IconButton(
                    tooltip: AppLocalizations.of(context)!.exploreClearSearch,
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _artist.clear();
                      _set((x) => x.copyWith(artist: () => null));
                    },
                  ),
          ),
          onSubmitted: (v) => _set(
            (x) => x.copyWith(artist: () => v.trim().isEmpty ? null : v.trim()),
          ),
        ),
        const SizedBox(height: VibraSpacing.md),
        if (families.isNotEmpty)
          row(l10n.concertFilterGenre, [
            chip(
              l10n.concertFilterAll,
              f.family == null,
              () => _set((x) => x.copyWith(family: () => null)),
            ),
            for (final fam in families)
              chip(
                genreFamilyLabel(l10n, fam),
                f.family == fam,
                () => _set((x) => x.copyWith(family: () => fam)),
              ),
          ]),
        row(l10n.concertFilterDate, [
          for (final (label, to) in dateOptions)
            chip(
              label,
              sameDay(f.dateTo, to),
              () => _set((x) => x.copyWith(dateTo: () => to)),
            ),
        ]),
        row(l10n.concertFilterDistance, [
          chip(
            l10n.concertDistanceAny,
            f.radiusKm == null,
            () => _set((x) => x.copyWith(radiusKm: () => null)),
          ),
          for (final km in const [10, 25, 50, 100, 250])
            chip(
              l10n.concertDistanceValue(km),
              f.radiusKm == km,
              () => _set((x) => x.copyWith(radiusKm: () => km)),
            ),
        ]),
        row(l10n.concertFilterPrice, [
          chip(
            l10n.concertPriceAny,
            f.priceMax == null,
            () => _set((x) => x.copyWith(priceMax: () => null)),
          ),
          for (final p in const [30, 60, 100])
            chip(
              l10n.concertPriceUpTo(euro.format(p)),
              f.priceMax == p,
              () => _set((x) => x.copyWith(priceMax: () => p)),
            ),
        ]),
        if (f.priceMax != null)
          Text(
            l10n.concertPriceNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.vibraTokens.textMuted,
            ),
          ),
      ],
    );
  }
}
