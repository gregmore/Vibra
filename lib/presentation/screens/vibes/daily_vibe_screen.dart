import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../data/datasources/supabase_daily_vibe_datasource.dart'
    show discoveryPageSize;
import '../../../domain/entities/daily_vibe.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/core_providers.dart';
import '../../providers/daily_vibe_providers.dart';
import '../../widgets/common/vibra_bottom_sheet.dart';
import '../../widgets/common/vibra_button.dart';
import '../../widgets/common/vibra_image.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_paged_list.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/daily_vibe_widgets.dart';

void _snack(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

/// DAILY VIBE (docs/daily-vibe.md): one song a day from each person.
class DailyVibeScreen extends ConsumerWidget {
  const DailyVibeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final me = ref.read(supabaseDailyVibeDatasourceProvider).currentUserId;
    return VibraPageScaffold(
      appBar: AppBar(
        title: Text(l10n.vibeTitle),
        actions: [
          IconButton(
            tooltip: l10n.discoveriesTitle,
            icon: const Icon(Icons.library_music_outlined),
            onPressed: () => context.push('/discoveries'),
          ),
        ],
      ),
      child: ref
          .watch(dailyVibeFeedProvider)
          .when(
            loading: () => const VibraLoadingView(),
            error: (e, _) => VibraErrorView(
              error: e,
              title: l10n.vibeTitle,
              message: l10n.vibeLoadError,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(dailyVibeFeedProvider),
            ),
            data: (vibes) {
              final mine = vibes.where((v) => v.userId == me).firstOrNull;
              final others = vibes.where((v) => v.userId != me).toList();
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(dailyVibeFeedProvider);
                  await ref.read(dailyVibeFeedProvider.future);
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
                      l10n.vibeQuestion,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: VibraSpacing.md),
                    if (mine != null) DailyVibeCard(vibe: mine, mine: true),
                    VibraButton(
                      label: mine == null ? l10n.vibeShare : l10n.vibeChange,
                      tone: mine == null
                          ? VibraButtonTone.signal
                          : VibraButtonTone.outline,
                      leadingIcon: Icons.graphic_eq_rounded,
                      expanded: true,
                      onPressed: () => showVibeComposer(context, ref),
                    ),
                    const SizedBox(height: VibraSpacing.xl),
                    if (others.isEmpty)
                      VibraEmptyView(
                        compact: true,
                        title: l10n.vibeEmptyTitle,
                        message: l10n.vibeEmptyBody,
                        icon: Icons.queue_music_rounded,
                      )
                    else
                      for (final v in others) DailyVibeCard(vibe: v),
                  ],
                ),
              );
            },
          ),
    );
  }
}

// ── Composer ───────────────────────────────────────────────────────────────
Future<void> showVibeComposer(BuildContext context, WidgetRef ref) async {
  final posted = await VibraBottomSheet.show<bool>(
    context,
    builder: (_) => const _Composer(),
  );
  if (posted == true && context.mounted) {
    ref.invalidate(dailyVibeFeedProvider);
    _snack(context, AppLocalizations.of(context)!.vibePosted);
  }
}

class _Composer extends ConsumerStatefulWidget {
  const _Composer();

  @override
  ConsumerState<_Composer> createState() => _ComposerState();
}

class _ComposerState extends ConsumerState<_Composer> {
  bool _link = false;
  final _query = TextEditingController();
  final _url = TextEditingController();
  final _title = TextEditingController();
  final _artist = TextEditingController();
  final _caption = TextEditingController();
  List<VibeTrack>? _results;
  VibeTrack? _picked;
  bool _searching = false;
  bool _posting = false;
  bool _expires = true;
  bool _everyone = false;
  String? _searchError;

  @override
  void dispose() {
    for (final c in [_query, _url, _title, _artist, _caption]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _search() async {
    final l10n = AppLocalizations.of(context)!;
    final q = _query.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _searching = true;
      _searchError = null;
    });
    try {
      final results = await ref
          .read(supabaseDailyVibeDatasourceProvider)
          .search(q);
      if (mounted) setState(() => _results = results);
    } catch (e) {
      if (mounted) {
        setState(
          () => _searchError = '$e'.contains('music_provider_unavailable')
              ? l10n.vibeProviderUnavailable
              : l10n.vibeError,
        );
      }
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  bool get _valid => _link
      ? _url.text.trim().startsWith('https://') &&
            _title.text.trim().isNotEmpty &&
            _artist.text.trim().isNotEmpty
      : _picked?.trackId != null;

  Future<void> _post() async {
    final l10n = AppLocalizations.of(context)!;
    final source = ref.read(supabaseDailyVibeDatasourceProvider);
    final caption = _caption.text.trim().isEmpty ? null : _caption.text.trim();
    setState(() => _posting = true);
    try {
      if (_link) {
        await source.postLink(
          url: _url.text.trim(),
          title: _title.text.trim(),
          artist: _artist.text.trim(),
          caption: caption,
          expires: _expires,
          everyone: _everyone,
        );
      } else {
        await source.postSpotify(
          _picked!.trackId!,
          caption: caption,
          expires: _expires,
          everyone: _everyone,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() => _posting = false);
        _snack(context, l10n.vibeError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    void rebuild(String _) => setState(() {});
    return VibraBottomSheet(
      title: l10n.vibeQuestion,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: false, label: Text(l10n.vibeTabSpotify)),
              ButtonSegment(value: true, label: Text(l10n.vibeTabLink)),
            ],
            selected: {_link},
            onSelectionChanged: (s) => setState(() => _link = s.first),
          ),
          const SizedBox(height: VibraSpacing.md),
          if (!_link) ...[
            TextField(
              controller: _query,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: l10n.vibeSearchHint,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ),
            if (_searching) const VibraLoadingIndicator(),
            if (_searchError != null)
              Padding(
                padding: const EdgeInsets.only(top: VibraSpacing.sm),
                child: Text(_searchError!, style: TextStyle(color: t.error)),
              ),
            if (_results != null && _results!.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: VibraSpacing.sm),
                child: Text(l10n.vibeSearchEmpty),
              ),
            if (_results != null && _results!.isNotEmpty)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final track in _results!)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        selected: _picked?.trackId == track.trackId,
                        leading: SizedBox.square(
                          dimension: 44,
                          child: VibraNetworkImage(
                            url: track.artworkUrl,
                            cacheWidth: 120,
                          ),
                        ),
                        title: Text(track.title, maxLines: 1),
                        subtitle: Text(track.artist, maxLines: 1),
                        onTap: () => setState(() => _picked = track),
                      ),
                  ],
                ),
              ),
            if (_results != null)
              Text(
                l10n.vibeAttribution,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: t.textMuted),
              ),
          ] else ...[
            TextField(
              controller: _url,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(hintText: l10n.vibeLinkHint),
              onChanged: rebuild,
            ),
            TextField(
              controller: _title,
              maxLength: 200,
              decoration: InputDecoration(hintText: l10n.vibeTitleHint),
              onChanged: rebuild,
            ),
            TextField(
              controller: _artist,
              maxLength: 100,
              decoration: InputDecoration(hintText: l10n.vibeArtistHint),
              onChanged: rebuild,
            ),
          ],
          TextField(
            controller: _caption,
            maxLength: 200,
            decoration: InputDecoration(hintText: l10n.vibeCaptionHint),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.vibeExpires),
            value: _expires,
            onChanged: (v) => setState(() => _expires = v),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.vibeEveryone),
            subtitle: Text(l10n.vibeVisibilityBody),
            value: _everyone,
            onChanged: (v) => setState(() => _everyone = v),
          ),
          VibraButton(
            label: l10n.vibePost,
            tone: VibraButtonTone.signal,
            expanded: true,
            loading: _posting,
            onPressed: _valid && !_posting ? _post : null,
          ),
        ],
      ),
    );
  }
}

// ── Discoveries ────────────────────────────────────────────────────────────
class DiscoveriesScreen extends ConsumerWidget {
  const DiscoveriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return VibraPageScaffold(
      appBar: AppBar(title: Text(l10n.discoveriesTitle)),
      child: ref
          .watch(discoveriesProvider)
          .when(
            loading: () => const VibraLoadingView(),
            error: (e, _) => VibraErrorView(
              error: e,
              title: l10n.discoveriesTitle,
              message: l10n.vibeLoadError,
            ),
            data: (items) => items.isEmpty
                ? VibraEmptyView(
                    title: l10n.discoveriesTitle,
                    message: l10n.discoveriesEmpty,
                    icon: Icons.library_music_outlined,
                  )
                : VibraPagedList<Discovery>(
                    first: items,
                    pageSize: discoveryPageSize,
                    itemKey: (d) => d.id,
                    loadMore: (last) => ref
                        .read(supabaseDailyVibeDatasourceProvider)
                        .discoveries(before: last.savedAt),
                    onRefresh: () async {
                      ref.invalidate(discoveriesProvider);
                      await ref.read(discoveriesProvider.future);
                    },
                    itemBuilder: (context, d) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: SizedBox.square(
                        dimension: 48,
                        child: VibraNetworkImage(
                          url: d.track.artworkUrl,
                          cacheWidth: 120,
                          fallbackIcon: Icons.music_note_rounded,
                        ),
                      ),
                      title: Text(d.track.title),
                      subtitle: Text(
                        [
                          d.track.artist,
                          if (d.viaName != null)
                            l10n.discoveryFoundVia(d.viaName!),
                        ].join(' · '),
                      ),
                      onTap: () => openOnProvider(d.track),
                      trailing: IconButton(
                        tooltip: l10n.circlesRemove,
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () async {
                          await ref
                              .read(supabaseDailyVibeDatasourceProvider)
                              .removeDiscovery(d.id);
                          ref.invalidate(discoveriesProvider);
                          ref.invalidate(discoveredUrlsSourceProvider);
                        },
                      ),
                    ),
                  ),
          ),
    );
  }
}
