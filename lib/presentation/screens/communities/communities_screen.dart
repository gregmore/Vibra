import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/music/genre_catalog.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/community.dart';
import '../../../l10n/app_localizations.dart';
import '../../localization/music_affinity_text.dart';
import '../../providers/community_providers.dart';
import '../../providers/core_providers.dart';
import '../../widgets/common/vibra_bottom_sheet.dart';
import '../../widgets/common/vibra_button.dart';
import '../../widgets/common/vibra_input.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_section_header.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/common/vibra_surface.dart';
import '../../widgets/community_widgets.dart';

/// Communities hub (docs/communities.md): recommendations from the Musical
/// DNA, the user's communities, and everything else to explore.
class CommunitiesScreen extends ConsumerStatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  ConsumerState<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends ConsumerState<CommunitiesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VibraPageScaffold(
      appBar: AppBar(
        title: Text(l10n.communitiesTitle),
        actions: [
          IconButton(
            tooltip: l10n.communitiesCreate,
            icon: const Icon(Icons.add_rounded),
            onPressed: () => showCreateCommunity(context, ref),
          ),
        ],
      ),
      child: ref
          .watch(communitiesProvider)
          .when(
            loading: () => const VibraLoadingView(),
            error: (e, _) => VibraErrorView(
              error: e,
              title: l10n.communitiesTitle,
              message: l10n.communitiesLoadError,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(communitiesProvider),
            ),
            data: (all) {
              final q = _query.trim().toLowerCase();
              final matches = q.isEmpty
                  ? const <Community>[]
                  : all
                        .where(
                          (c) =>
                              c.name.toLowerCase().contains(q) ||
                              (c.artistName?.toLowerCase().contains(q) ??
                                  false),
                        )
                        .toList();
              final mine = all.where((c) => c.isMember).toList();
              final others = all.where((c) => !c.isMember).toList();
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(communitiesProvider);
                  await ref.read(communitiesProvider.future);
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    VibraSpacing.pagePadding,
                    VibraSpacing.sm,
                    VibraSpacing.pagePadding,
                    VibraSpacing.colossal,
                  ),
                  children: [
                    VibraInput(
                      hintText: l10n.communitiesSearchHint,
                      prefixIcon: Icons.search_rounded,
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    if (q.isNotEmpty) ...[
                      const SizedBox(height: VibraSpacing.lg),
                      if (matches.isEmpty)
                        Text(l10n.communitiesEmptySearch)
                      else
                        for (final c in matches) CommunityCard(community: c),
                    ] else ...[
                      const _ForYou(),
                      if (mine.isNotEmpty) ...[
                        _Header(l10n.communitiesMine),
                        for (final c in mine) CommunityCard(community: c),
                      ],
                      _Header(l10n.communitiesExplore),
                      for (final c in others) CommunityCard(community: c),
                    ],
                  ],
                ),
              );
            },
          ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.title, {this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => VibraSectionHeader(
    title: title,
    subtitle: subtitle,
    padding: const EdgeInsets.only(
      top: VibraSpacing.sectionGap,
      bottom: VibraSpacing.md,
    ),
  );
}

class _ForYou extends ConsumerWidget {
  const _ForYou();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final recs = ref.watch(communityRecommendationsProvider).valueOrNull;
    if (recs == null || (recs.items.isEmpty && recs.startArtists.isEmpty)) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(l10n.communitiesForYou, subtitle: l10n.communitiesForYouSub),
        for (final r in recs.items)
          Padding(
            padding: const EdgeInsets.only(bottom: VibraSpacing.sm),
            child: CommunityCard(
              community: r.community,
              headline: l10n.communitiesRecommendation(r.community.name),
              reason: communityReasonText(l10n, r.reason),
            ),
          ),
        for (final artist in recs.startArtists)
          Padding(
            padding: const EdgeInsets.only(bottom: VibraSpacing.sm),
            child: VibraSurface(
              onTap: () => showCreateCommunity(
                context,
                ref,
                kind: CommunityKind.artist,
                artist: artist,
              ),
              padding: const EdgeInsets.all(VibraSpacing.lg),
              child: Row(
                children: [
                  Icon(
                    Icons.add_circle_outline_rounded,
                    color: t.accentPrimary,
                  ),
                  const SizedBox(width: VibraSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.communitiesStartArtist(artist),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          l10n.communitiesStartArtistBody,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: t.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Create a community; the creator becomes its owner.
Future<void> showCreateCommunity(
  BuildContext context,
  WidgetRef ref, {
  CommunityKind kind = CommunityKind.interest,
  String? artist,
}) async {
  final id = await VibraBottomSheet.show<String>(
    context,
    builder: (_) => _CreateCommunitySheet(kind: kind, artist: artist),
  );
  if (id != null && context.mounted) {
    ref.invalidate(communitiesProvider);
    context.push('/community', extra: id);
  }
}

class _CreateCommunitySheet extends ConsumerStatefulWidget {
  const _CreateCommunitySheet({required this.kind, this.artist});
  final CommunityKind kind;
  final String? artist;

  @override
  ConsumerState<_CreateCommunitySheet> createState() =>
      _CreateCommunitySheetState();
}

class _CreateCommunitySheetState extends ConsumerState<_CreateCommunitySheet> {
  late CommunityKind _kind = widget.kind;
  late final _name = TextEditingController(
    text: widget.artist == null ? '' : '${widget.artist} Fans',
  );
  late final _artist = TextEditingController(text: widget.artist ?? '');
  final _description = TextEditingController();
  String _family = GenreCatalog.families.first.key;
  String? _subgenre;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _artist.dispose();
    _description.dispose();
    super.dispose();
  }

  bool get _valid =>
      _name.text.trim().length >= 3 &&
      (_kind != CommunityKind.artist || _artist.text.trim().isNotEmpty);

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final id = await ref
          .read(supabaseCommunitiesDatasourceProvider)
          .create(
            name: _name.text.trim(),
            description: _description.text.trim(),
            kind: _kind,
            genreKey: _kind == CommunityKind.genre
                ? (_subgenre ?? _family)
                : null,
            genreFamily: _kind == CommunityKind.genre ? _family : null,
            artistName: _kind == CommunityKind.artist
                ? _artist.text.trim()
                : null,
          );
      if (mounted) Navigator.of(context).pop(id);
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        communitySnack(context, communityErrorText(l10n, e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VibraBottomSheet(
      title: l10n.communitiesCreate,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<CommunityKind>(
            showSelectedIcon: false,
            segments: [
              for (final k in CommunityKind.values)
                ButtonSegment(
                  value: k,
                  label: Text(communityKindLabel(l10n, k)),
                ),
            ],
            selected: {_kind},
            onSelectionChanged: (s) => setState(() => _kind = s.first),
          ),
          const SizedBox(height: VibraSpacing.lg),
          if (_kind == CommunityKind.artist) ...[
            TextField(
              controller: _artist,
              maxLength: 80,
              decoration: InputDecoration(
                labelText: l10n.communitiesCreateArtist,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: VibraSpacing.sm),
          ],
          if (_kind == CommunityKind.genre) ...[
            DropdownButtonFormField<String>(
              initialValue: _family,
              decoration: InputDecoration(
                labelText: l10n.communitiesCreateGenre,
              ),
              items: [
                for (final f in GenreCatalog.families)
                  DropdownMenuItem(
                    value: f.key,
                    child: Text(genreFamilyLabel(l10n, f.key)),
                  ),
              ],
              onChanged: (v) => setState(() {
                _family = v ?? _family;
                _subgenre = null;
              }),
            ),
            const SizedBox(height: VibraSpacing.sm),
            DropdownButtonFormField<String?>(
              initialValue: _subgenre,
              decoration: const InputDecoration(),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(genreFamilyLabel(l10n, _family)),
                ),
                for (final s in GenreCatalog.subgenresOf(_family))
                  if (!s.isGeneric)
                    DropdownMenuItem<String?>(
                      value: s.key,
                      child: Text(s.label),
                    ),
              ],
              onChanged: (v) => setState(() => _subgenre = v),
            ),
            const SizedBox(height: VibraSpacing.sm),
          ],
          TextField(
            controller: _name,
            maxLength: 60,
            decoration: InputDecoration(labelText: l10n.communitiesCreateName),
            onChanged: (_) => setState(() {}),
          ),
          TextField(
            controller: _description,
            maxLength: 500,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              labelText: l10n.communitiesCreateDescription,
            ),
          ),
          const SizedBox(height: VibraSpacing.md),
          VibraButton(
            label: l10n.communitiesCreateAction,
            tone: VibraButtonTone.signal,
            expanded: true,
            loading: _busy,
            onPressed: _valid && !_busy ? _create : null,
          ),
        ],
      ),
    );
  }
}
