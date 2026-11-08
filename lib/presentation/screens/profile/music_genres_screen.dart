import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../core/music/genre_catalog.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../localization/music_affinity_text.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/core_providers.dart';
import '../../providers/music_affinity_providers.dart';
import '../../widgets/common/vibra_button.dart';
import '../../widgets/common/vibra_input.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_settings.dart';
import '../../widgets/common/vibra_state_views.dart';

/// Preference strength the user can pick for a genre (stored 1–100).
enum GenreIntensity {
  like(40),
  much(70),
  love(100);

  const GenreIntensity(this.value);
  final int value;

  static GenreIntensity fromValue(int value) => value >= 85
      ? love
      : value >= 55
      ? much
      : like;

  GenreIntensity get next => values[(index + 1) % values.length];
}

const int maxPickedGenres = 30;

/// Optional, editable genre picker: works without Spotify, never blocks the
/// app. Saving rebuilds the user's affinities on the server.
class MusicGenresScreen extends ConsumerStatefulWidget {
  const MusicGenresScreen({super.key});

  @override
  ConsumerState<MusicGenresScreen> createState() => _MusicGenresScreenState();
}

class _MusicGenresScreenState extends ConsumerState<MusicGenresScreen> {
  final _search = TextEditingController();
  final Map<String, GenreIntensity> _picked = {};
  bool _loading = true;
  bool _loadFailed = false;
  bool _saving = false;
  bool _matching = false;
  bool _initialMatching = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final social = ref.read(supabaseSocialDatasourceProvider);
      final saved = await social.getMyGenrePreferences();
      bool matching = false;
      try {
        final client = ref.read(supabaseDatasourceProvider).client;
        final userId = client.auth.currentUser?.id;
        if (userId != null) {
          final row = await client
              .from('privacy_preferences')
              .select('spotify_matching')
              .eq('user_id', userId)
              .maybeSingle();
          matching = row?['spotify_matching'] as bool? ?? false;
        }
      } catch (_) {
        // Consent unknown: keep it off; the user can still opt in here.
      }
      if (!mounted) return;
      setState(() {
        _picked
          ..clear()
          ..addAll({
            for (final entry in saved.entries)
              if (GenreCatalog.isKnown(entry.key))
                entry.key: GenreIntensity.fromValue(entry.value),
          });
        _matching = matching;
        _initialMatching = matching;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailed = true;
      });
    }
  }

  void _toggle(String key) {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      if (_picked.containsKey(key)) {
        _picked.remove(key);
      } else if (_picked.length >= maxPickedGenres) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.musicGenresLimit)));
      } else {
        _picked[key] = GenreIntensity.much;
      }
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      final social = ref.read(supabaseSocialDatasourceProvider);
      await social.saveMyGenrePreferences({
        for (final entry in _picked.entries) entry.key: entry.value.value,
      });
      if (_matching != _initialMatching) {
        final client = ref.read(supabaseDatasourceProvider).client;
        final userId = client.auth.currentUser?.id;
        if (userId != null) {
          await client.from('privacy_preferences').upsert({
            'user_id': userId,
            'spotify_matching': _matching,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          });
          _initialMatching = _matching;
        }
      }
      // The score is rebuilt server-side; a failure here only delays it
      // until the next sync, the saved genres are already stored.
      try {
        await social.recomputeAffinity();
      } catch (_) {}
      ref.invalidate(matchedUsersProvider);
      ref.invalidate(myGenrePreferencesProvider);
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.musicGenresSaved)));
      if (context.canPop()) context.pop();
    } catch (_) {
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.musicGenresSaveError)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _levelLabel(AppLocalizations l10n, GenreIntensity level) =>
      switch (level) {
        GenreIntensity.like => l10n.musicGenresLevelLike,
        GenreIntensity.much => l10n.musicGenresLevelMuch,
        GenreIntensity.love => l10n.musicGenresLevelLove,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final spotifyConnected =
        (ref.watch(myProfileProvider).spotifyId ?? '').isNotEmpty;
    final query = _search.text.trim();
    final results = query.isEmpty
        ? const <SubgenreInfo>[]
        : GenreCatalog.search(
            query,
            familyLabel: (key) => genreFamilyLabel(l10n, key),
          );

    return VibraPageScaffold(
      useGradient: false,
      appBar: AppBar(titleSpacing: 0, title: Text(l10n.musicGenresTitle)),
      bottomNavigationBar: _loading || _loadFailed
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(
                VibraSpacing.pagePadding,
                VibraSpacing.sm,
                VibraSpacing.pagePadding,
                VibraSpacing.md,
              ),
              child: VibraButton(
                label: l10n.musicGenresSave,
                tone: VibraButtonTone.signal,
                loading: _saving,
                onPressed: _saving ? null : _save,
              ),
            ),
      child: _loading
          ? const Center(child: VibraLoadingIndicator())
          : _loadFailed
          ? VibraErrorView(
              compact: true,
              kind: VibraErrorKind.network,
              title: l10n.commonConnectionError,
              message: l10n.musicGenresLoadError,
              onRetry: _load,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                VibraSpacing.pagePadding,
                VibraSpacing.sm,
                VibraSpacing.pagePadding,
                VibraSpacing.xxl,
              ),
              children: [
                Text(
                  l10n.musicGenresSubtitle,
                  style: VibraTextStyles.bodyMedium.copyWith(
                    color: t.textSecondary,
                  ),
                ),
                if (spotifyConnected) ...[
                  const SizedBox(height: VibraSpacing.sm),
                  Text(
                    l10n.musicGenresSpotifyNote,
                    style: VibraTextStyles.caption.copyWith(color: t.textMuted),
                  ),
                ],
                const SizedBox(height: VibraSpacing.lg),
                VibraInput(
                  controller: _search,
                  hintText: l10n.musicGenresSearchHint,
                  prefixIcon: Icons.search_rounded,
                  textInputAction: TextInputAction.search,
                  maxLength: 40,
                  onChanged: (_) => setState(() {}),
                  suffix: query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: l10n.myEventsClearSearch,
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => setState(_search.clear),
                        ),
                ),
                const SizedBox(height: VibraSpacing.lg),
                _SectionLabel(
                  l10n.musicGenresYourPicks,
                  trailing: l10n.musicGenresSelected(_picked.length),
                ),
                if (_picked.isNotEmpty) ...[
                  Wrap(
                    spacing: VibraSpacing.sm,
                    runSpacing: VibraSpacing.sm,
                    children: [
                      for (final entry in _picked.entries)
                        InputChip(
                          key: ValueKey('picked-${entry.key}'),
                          selected: true,
                          showCheckmark: false,
                          label: Text(
                            '${genreLabel(l10n, entry.key)} · '
                            '${_levelLabel(l10n, entry.value)}',
                          ),
                          onPressed: () => setState(
                            () => _picked[entry.key] = entry.value.next,
                          ),
                          onDeleted: () =>
                              setState(() => _picked.remove(entry.key)),
                          deleteButtonTooltipMessage: l10n.musicGenresRemove(
                            genreLabel(l10n, entry.key),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: VibraSpacing.sm),
                  Text(
                    l10n.musicGenresIntensityHint,
                    style: VibraTextStyles.caption.copyWith(color: t.textMuted),
                  ),
                ],
                const SizedBox(height: VibraSpacing.xl),
                if (query.isNotEmpty) ...[
                  if (results.isEmpty)
                    Text(
                      l10n.musicGenresNoResults,
                      style: VibraTextStyles.bodyMedium.copyWith(
                        color: t.textSecondary,
                      ),
                    )
                  else
                    _GenreChips(
                      genres: results,
                      picked: _picked.keys.toSet(),
                      onToggle: _toggle,
                    ),
                ] else
                  for (final family in GenreCatalog.families) ...[
                    _SectionLabel(genreFamilyLabel(l10n, family.key)),
                    _GenreChips(
                      genres: GenreCatalog.subgenresOf(family.key),
                      picked: _picked.keys.toSet(),
                      onToggle: _toggle,
                    ),
                    const SizedBox(height: VibraSpacing.xl),
                  ],
                VibraSettingsSection(
                  footer: l10n.musicGenresMatchingBody,
                  children: [
                    VibraSettingsSwitch(
                      icon: Icons.graphic_eq_rounded,
                      title: l10n.musicGenresMatching,
                      value: _matching,
                      onChanged: _saving
                          ? null
                          : (value) => setState(() => _matching = value),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label, {this.trailing});

  final String label;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: VibraSpacing.sm + 2),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                label.toUpperCase(),
                style: VibraTextStyles.labelSmall.copyWith(
                  color: t.textSecondary,
                ),
              ),
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: VibraTextStyles.caption.copyWith(color: t.textMuted),
            ),
        ],
      ),
    );
  }
}

class _GenreChips extends StatelessWidget {
  const _GenreChips({
    required this.genres,
    required this.picked,
    required this.onToggle,
  });

  final List<SubgenreInfo> genres;
  final Set<String> picked;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: VibraSpacing.sm,
      runSpacing: VibraSpacing.sm,
      children: [
        for (final genre in genres)
          FilterChip(
            key: ValueKey('genre-${genre.key}'),
            label: Text(genreLabel(l10n, genre.key)),
            selected: picked.contains(genre.key),
            onSelected: (_) => onToggle(genre.key),
          ),
      ],
    );
  }
}
