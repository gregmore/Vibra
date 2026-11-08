import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/music/genre_catalog.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/taste_evolution.dart';
import '../../../l10n/app_localizations.dart';
import '../../localization/music_affinity_text.dart';
import '../../providers/core_providers.dart';
import '../../providers/musical_dna_providers.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/common/vibra_surface.dart';
import '../../widgets/taste_evolution_widgets.dart';

String _date(BuildContext context, DateTime? d) => d == null
    ? ''
    : DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(d);

String _subgenre(String key) => GenreCatalog.subgenre(key)?.label ?? key;

String _periodLabel(AppLocalizations l10n, TastePeriod p) => switch (p) {
  TastePeriod.month => l10n.tastePeriodMonth,
  TastePeriod.threeMonths => l10n.tastePeriodThreeMonths,
  TastePeriod.sixMonths => l10n.tastePeriodSixMonths,
  TastePeriod.year => l10n.tastePeriodYear,
};

/// TASTE EVOLUTION (docs/taste-evolution.md): how the user's Musical DNA
/// changed between two real snapshots. Dates are always shown; nothing is
/// estimated.
class TasteEvolutionScreen extends ConsumerStatefulWidget {
  const TasteEvolutionScreen({super.key});

  @override
  ConsumerState<TasteEvolutionScreen> createState() =>
      _TasteEvolutionScreenState();
}

class _TasteEvolutionScreenState extends ConsumerState<TasteEvolutionScreen> {
  TastePeriod _period = TastePeriod.threeMonths;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(tasteEvolutionProvider(_period));
    return VibraPageScaffold(
      appBar: AppBar(title: Text(l10n.tasteTitle)),
      child: async.when(
        loading: () => const VibraLoadingView(),
        error: (e, _) => VibraErrorView(
          error: e,
          title: l10n.tasteTitle,
          message: l10n.tasteError,
          retryLabel: l10n.commonRetry,
          onRetry: () => ref.invalidate(tasteEvolutionProvider(_period)),
        ),
        data: (e) => ListView(
          padding: const EdgeInsets.fromLTRB(
            VibraSpacing.pagePadding,
            VibraSpacing.sm,
            VibraSpacing.pagePadding,
            VibraSpacing.colossal,
          ),
          children: [
            if (e.tracking) ...[
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<TastePeriod>(
                  showSelectedIcon: false,
                  segments: [
                    for (final p in TastePeriod.values)
                      ButtonSegment(
                        value: p,
                        label: Text(_periodLabel(l10n, p)),
                      ),
                  ],
                  selected: {_period},
                  onSelectionChanged: (s) => setState(() => _period = s.first),
                ),
              ),
              const SizedBox(height: VibraSpacing.lg),
            ],
            ..._body(context, e),
            const SizedBox(height: VibraSpacing.xl),
            _HistorySetting(enabled: e.tracking),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(BuildContext context, TasteEvolution e) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    if (e.current == null) {
      return [
        VibraEmptyView(
          compact: true,
          title: l10n.tasteNoDnaTitle,
          message: l10n.tasteNoDnaBody,
          icon: Icons.donut_large_rounded,
          actionLabel: l10n.musicalDnaProfileTile,
          onActionTap: () => context.push('/musical-dna'),
        ),
      ];
    }
    if (!e.tracking) {
      return [
        VibraEmptyView(
          compact: true,
          title: l10n.tasteOffTitle,
          message: l10n.tasteOffBody,
          icon: Icons.history_toggle_off_rounded,
        ),
      ];
    }
    if (!e.canCompare) {
      return [
        VibraEmptyView(
          compact: true,
          title: l10n.tasteTooEarlyTitle,
          message: l10n.tasteTooEarlyBody(
            _date(context, e.oldestOn ?? e.current!.capturedOn),
          ),
          icon: Icons.hourglass_top_rounded,
        ),
      ];
    }
    final base = e.baseline!, now = e.current!;
    final months = switch (_period) {
      TastePeriod.month => 'month',
      TastePeriod.threeMonths => 'three',
      TastePeriod.sixMonths => 'six',
      TastePeriod.year => 'year',
    };
    return [
      // Headline: only what the two snapshots show.
      Text(
        e.evolved ? l10n.tasteEvolved(months) : l10n.tasteSteady(months),
        style: theme.textTheme.headlineSmall,
      ),
      const SizedBox(height: VibraSpacing.xs),
      Text(
        e.fullPeriod
            ? l10n.tasteComparing(
                _date(context, base.capturedOn),
                _date(context, now.capturedOn),
              )
            : l10n.tasteShortHistory(
                _date(context, base.capturedOn),
                _date(context, now.capturedOn),
              ),
        style: theme.textTheme.bodySmall?.copyWith(color: t.textSecondary),
      ),
      if (e.changePoints > 0)
        Padding(
          padding: const EdgeInsets.only(top: VibraSpacing.xs),
          child: Text(
            l10n.tasteChangePoints(e.changePoints),
            style: theme.textTheme.bodySmall?.copyWith(color: t.textMuted),
          ),
        ),
      const SizedBox(height: VibraSpacing.lg),
      TasteEvolutionChart(evolution: e),
      const SizedBox(height: VibraSpacing.lg),
      _Card(
        title: l10n.tasteNewGenres,
        empty: l10n.tasteNoNewGenres,
        children: [
          if (e.newGenres.isNotEmpty)
            Wrap(
              spacing: VibraSpacing.xs,
              runSpacing: VibraSpacing.xs,
              children: [
                for (final g in e.newGenres)
                  Chip(
                    avatar: Icon(
                      Icons.fiber_new_rounded,
                      size: 18,
                      color: t.accentPrimary,
                    ),
                    label: Text('${_subgenre(g.key)} · ${g.percent}%'),
                  ),
              ],
            ),
        ],
      ),
      _Card(
        title: l10n.tasteEmergingArtists,
        empty: now.artists.isEmpty
            ? l10n.tasteNoArtistData
            : l10n.tasteNoEmergingArtists,
        children: [
          for (final a in e.emergingArtists)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: CircleAvatar(
                radius: 14,
                child: Text('${a.rank}', style: theme.textTheme.labelSmall),
              ),
              title: Text(a.name),
              trailing: Text(
                a.isNew
                    ? l10n.tasteArtistNew
                    : l10n.tasteArtistRose(a.previousRank!, a.rank),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: t.accentPrimary,
                ),
              ),
            ),
        ],
      ),
      _Card(
        title: l10n.tastePrevious,
        empty: l10n.tasteNoPrevious,
        children: [
          for (final f in e.previousGenres)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Icon(Icons.trending_down_rounded, color: t.textMuted),
              title: Text(genreFamilyLabel(l10n, f.key)),
              trailing: Text('${f.before}% → ${f.now}%'),
            ),
          for (final a in e.previousArtists)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Icon(Icons.history_rounded, color: t.textMuted),
              title: Text(a),
              subtitle: Text(l10n.tasteFormerTopArtist),
            ),
        ],
      ),
      _Card(
        title: l10n.tasteCommunities,
        empty: l10n.tasteNoCommunities,
        children: [
          for (final c in e.communities)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Icon(Icons.groups_2_outlined, color: t.accentPrimary),
              title: Text(c.name),
              subtitle: Text(l10n.tasteJoinedOn(_date(context, c.joinedAt))),
              onTap: () => context.push('/community', extra: c.id),
            ),
        ],
      ),
    ];
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.title,
    required this.empty,
    required this.children,
  });
  final String title;
  final String empty;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: VibraSpacing.md),
      child: VibraSurface(
        padding: const EdgeInsets.all(VibraSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleSmall),
            const SizedBox(height: VibraSpacing.sm),
            if (children.isEmpty)
              Text(
                empty,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                ),
              )
            else
              ...children,
          ],
        ),
      ),
    );
  }
}

class _HistorySetting extends ConsumerStatefulWidget {
  const _HistorySetting({required this.enabled});
  final bool enabled;

  @override
  ConsumerState<_HistorySetting> createState() => _HistorySettingState();
}

class _HistorySettingState extends ConsumerState<_HistorySetting> {
  bool _saving = false;

  Future<void> _set(bool value) async {
    final l10n = AppLocalizations.of(context)!;
    if (!value) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (d) => AlertDialog(
          title: Text(l10n.tasteTurnOffTitle),
          content: Text(l10n.tasteTurnOffBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(d).pop(false),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(d).pop(true),
              child: Text(l10n.tasteTurnOffConfirm),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(supabaseMusicalDnaDatasourceProvider)
          .setTasteHistory(value);
      for (final p in TastePeriod.values) {
        ref.invalidate(tasteEvolutionProvider(p));
      }
      ref.invalidate(myMusicalDnaHistoryProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.tasteError)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(l10n.tasteKeepHistory),
      subtitle: Text(l10n.tasteKeepHistoryBody),
      value: widget.enabled,
      onChanged: _saving ? null : _set,
    );
  }
}
