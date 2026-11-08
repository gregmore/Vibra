import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/entities/music_story.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/core_providers.dart';
import '../../providers/music_story_providers.dart';
import '../../providers/profile_photo_provider.dart';
import '../../widgets/common/vibra_button.dart';
import '../../widgets/common/vibra_image.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/music_story_widgets.dart';

void _snack(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

/// MUSIC STORIES composer (docs/music-stories.md): pick what to share, see
/// it as your audience will, choose who sees it, post. Every story
/// disappears after 24 hours.
class StoryComposerScreen extends ConsumerStatefulWidget {
  const StoryComposerScreen({this.initialKind, super.key});
  final StoryKind? initialKind;

  @override
  ConsumerState<StoryComposerScreen> createState() =>
      _StoryComposerScreenState();
}

class _StoryComposerScreenState extends ConsumerState<StoryComposerScreen> {
  late StoryKind _kind = widget.initialKind ?? StoryKind.nowPlaying;
  bool _link = false;
  final _query = TextEditingController();
  final _url = TextEditingController();
  final _title = TextEditingController();
  final _subtitle = TextEditingController();
  final _body = TextEditingController();
  List<StoryItem>? _results;
  StoryItem? _picked;
  Uint8List? _photo;
  String? _eventId;
  String _background = 'aurora';
  bool? _everyone;
  bool? _replies;
  bool _searching = false;
  bool _posting = false;
  String? _searchError;

  @override
  void dispose() {
    for (final c in [_query, _url, _title, _subtitle, _body]) {
      c.dispose();
    }
    super.dispose();
  }

  void _setKind(StoryKind k) => setState(() {
    _kind = k;
    _results = null;
    _picked = null;
    _searchError = null;
  });

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
          .read(supabaseMusicStoriesDatasourceProvider)
          .search(_kind, q);
      if (mounted) setState(() => _results = results);
    } catch (e) {
      if (mounted) {
        setState(
          () => _searchError = '$e'.contains('music_provider_unavailable')
              ? l10n.vibeProviderUnavailable
              : l10n.storyError,
        );
      }
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _pickPhoto() async {
    final file = await ref
        .read(profileImagePickerProvider)
        .pickImage(
          source: ImageSource.gallery,
          maxWidth: 2048,
          maxHeight: 2048,
          imageQuality: 90,
        );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (mounted) setState(() => _photo = bytes);
  }

  String? get _text => _body.text.trim().isEmpty ? null : _body.text.trim();

  StoryItem? get _previewItem => _kind.isMusic
      ? (_link
            ? (_title.text.trim().isEmpty
                  ? null
                  : StoryItem(
                      provider: 'link',
                      title: _title.text.trim(),
                      subtitle: _subtitle.text.trim().isEmpty
                          ? null
                          : _subtitle.text.trim(),
                      externalUrl: _url.text.trim(),
                    ))
            : _picked)
      : null;

  bool get _valid => switch (_kind) {
    StoryKind.opinion => _text != null,
    StoryKind.concertPhoto => _photo != null,
    _ =>
      _link
          ? _url.text.trim().startsWith('https://') &&
                _title.text.trim().isNotEmpty
          : _picked?.itemId != null,
  };

  Future<void> _post(StorySettings defaults) async {
    final l10n = AppLocalizations.of(context)!;
    final source = ref.read(supabaseMusicStoriesDatasourceProvider);
    setState(() => _posting = true);
    try {
      final media = _kind == StoryKind.concertPhoto
          ? await source.uploadPhoto(_photo!)
          : null;
      await source.post(
        kind: _kind,
        spotifyItem: _kind.isMusic && !_link ? _picked : null,
        linkUrl: _kind.isMusic && _link ? _url.text.trim() : null,
        linkTitle: _kind.isMusic && _link ? _title.text.trim() : null,
        linkSubtitle: _kind.isMusic && _link && _subtitle.text.trim().isNotEmpty
            ? _subtitle.text.trim()
            : null,
        mediaPath: media,
        eventId: _kind == StoryKind.concertPhoto ? _eventId : null,
        body: _text,
        background: _background,
        everyone: _everyone ?? defaults.everyone,
        allowReplies: _replies ?? defaults.allowReplies,
      );
      ref.invalidate(storyRingProvider);
      final me = source.currentUserId;
      if (me != null) ref.invalidate(userStoriesProvider(me));
      if (!mounted) return;
      _snack(context, l10n.storyPosted);
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _posting = false);
      final m = '$e';
      _snack(
        context,
        m.contains('rate_limited')
            ? l10n.storyRateLimited
            : m.contains('spam_detected')
            ? l10n.storySpam
            : m.contains('image_too_large') || m.contains('invalid_image')
            ? l10n.storyPhotoError
            : l10n.storyError,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    final defaults =
        ref.watch(storySettingsProvider).valueOrNull ?? const StorySettings();
    final everyone = _everyone ?? defaults.everyone;
    final replies = _replies ?? defaults.allowReplies;
    void rebuild(String _) => setState(() {});
    final events = [
      ...ref.watch(myEventsProvider).going,
      ...ref.watch(myEventsProvider).saved,
    ].where((e) => RegExp(r'^[0-9a-f-]{36}$').hasMatch(e.id)).toList();
    final eventName = events
        .where((e) => e.id == _eventId)
        .map((e) => e.name)
        .firstOrNull;

    return VibraPageScaffold(
      appBar: AppBar(
        title: Text(l10n.storyNew),
        actions: [
          IconButton(
            tooltip: l10n.storySettingsTitle,
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => context.push('/story-settings'),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          VibraSpacing.pagePadding,
          VibraSpacing.sm,
          VibraSpacing.pagePadding,
          VibraSpacing.colossal,
        ),
        children: [
          // What to share.
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final k in StoryKind.values)
                  Padding(
                    padding: const EdgeInsets.only(right: VibraSpacing.xs),
                    child: ChoiceChip(
                      avatar: Icon(storyKindIcon(k), size: 18),
                      label: Text(storyKindLabel(l10n, k)),
                      selected: _kind == k,
                      showCheckmark: false,
                      onSelected: (_) => _setKind(k),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: VibraSpacing.lg),

          // Live preview, as viewers will see it.
          Center(
            child: Semantics(
              label: l10n.storyPreview,
              child: SizedBox(
                width: 200,
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      VibraSpacing.radiusLarge,
                    ),
                    child: StoryCanvas(
                      kind: _kind,
                      item: _previewItem,
                      body: _text,
                      background: _background,
                      photoBytes: _photo,
                      eventName: eventName,
                      compact: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: VibraSpacing.lg),

          if (_kind.isMusic) ...[
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
                  hintText: switch (_kind) {
                    StoryKind.artist => l10n.storySearchArtist,
                    StoryKind.album => l10n.storySearchAlbum,
                    StoryKind.playlist => l10n.storySearchPlaylist,
                    _ => l10n.vibeSearchHint,
                  },
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
                  child: Text(l10n.storySearchEmpty),
                ),
              if (_results != null)
                for (final item in _results!)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    selected: _picked?.itemId == item.itemId,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        _kind == StoryKind.artist ? 22 : 6,
                      ),
                      child: SizedBox.square(
                        dimension: 44,
                        child: VibraNetworkImage(
                          url: item.artworkUrl,
                          cacheWidth: 120,
                          fallbackIcon: storyKindIcon(_kind),
                        ),
                      ),
                    ),
                    title: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: item.subtitle == null
                        ? null
                        : Text(
                            item.subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    trailing: _picked?.itemId == item.itemId
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: t.accentPrimary,
                          )
                        : null,
                    onTap: () => setState(() => _picked = item),
                  ),
              if (_results != null && _results!.isNotEmpty)
                Text(
                  l10n.storyAttribution,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: t.textMuted,
                  ),
                ),
            ] else ...[
              TextField(
                controller: _url,
                keyboardType: TextInputType.url,
                onChanged: rebuild,
                decoration: InputDecoration(hintText: l10n.vibeLinkHint),
              ),
              const SizedBox(height: VibraSpacing.sm),
              TextField(
                controller: _title,
                onChanged: rebuild,
                maxLength: 200,
                decoration: InputDecoration(
                  hintText: switch (_kind) {
                    StoryKind.artist => l10n.storyArtistNameHint,
                    StoryKind.album => l10n.storyAlbumTitleHint,
                    StoryKind.playlist => l10n.storyPlaylistTitleHint,
                    _ => l10n.vibeTitleHint,
                  },
                ),
              ),
              if (_kind != StoryKind.artist)
                TextField(
                  controller: _subtitle,
                  onChanged: rebuild,
                  maxLength: 200,
                  decoration: InputDecoration(
                    hintText: _kind == StoryKind.playlist
                        ? l10n.storyPlaylistOwnerHint
                        : l10n.vibeArtistHint,
                  ),
                ),
            ],
          ],

          if (_kind == StoryKind.concertPhoto) ...[
            VibraButton(
              label: _photo == null
                  ? l10n.storyPickPhoto
                  : l10n.storyChangePhoto,
              tone: VibraButtonTone.outline,
              leadingIcon: Icons.photo_library_outlined,
              expanded: true,
              onPressed: _pickPhoto,
            ),
            const SizedBox(height: VibraSpacing.xs),
            Text(
              l10n.storyPhotoPrivacy,
              style: theme.textTheme.bodySmall?.copyWith(color: t.textMuted),
            ),
            if (events.isNotEmpty) ...[
              const SizedBox(height: VibraSpacing.md),
              DropdownButtonFormField<String?>(
                initialValue: _eventId,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.storyTagConcert),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(l10n.storyNoConcert),
                  ),
                  for (final Event e in events.take(30))
                    DropdownMenuItem(
                      value: e.id,
                      child: Text(e.name, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (v) => setState(() => _eventId = v),
              ),
            ],
          ],

          const SizedBox(height: VibraSpacing.md),
          TextField(
            controller: _body,
            onChanged: rebuild,
            maxLength: 300,
            minLines: _kind == StoryKind.opinion ? 3 : 1,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: _kind == StoryKind.opinion
                  ? l10n.storyOpinionHint
                  : l10n.vibeCaptionHint,
            ),
          ),

          if (_kind == StoryKind.opinion || _kind.isMusic) ...[
            Text(l10n.storyBackground, style: theme.textTheme.labelLarge),
            const SizedBox(height: VibraSpacing.sm),
            Row(
              children: [
                for (final b in storyBackgrounds)
                  Padding(
                    padding: const EdgeInsets.only(right: VibraSpacing.sm),
                    child: Semantics(
                      button: true,
                      selected: _background == b,
                      label: b,
                      child: InkResponse(
                        onTap: () => setState(() => _background = b),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: storyGradient(b),
                            border: Border.all(
                              color: _background == b
                                  ? t.textPrimary
                                  : t.borderDefault,
                              width: _background == b ? 2.5 : 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],

          // Who sees it.
          const SizedBox(height: VibraSpacing.xl),
          Text(l10n.storyAudience, style: theme.textTheme.titleSmall),
          const SizedBox(height: VibraSpacing.sm),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: false,
                icon: const Icon(Icons.group_rounded),
                label: Text(l10n.storyAudienceConnections),
              ),
              ButtonSegment(
                value: true,
                icon: const Icon(Icons.public_rounded),
                label: Text(l10n.storyAudienceEveryone),
              ),
            ],
            selected: {everyone},
            onSelectionChanged: (s) => setState(() => _everyone = s.first),
          ),
          const SizedBox(height: VibraSpacing.xs),
          Text(
            everyone
                ? l10n.storyAudienceEveryoneBody
                : l10n.storyAudienceConnectionsBody,
            style: theme.textTheme.bodySmall?.copyWith(color: t.textSecondary),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.storyAllowReplies),
            value: replies,
            onChanged: (v) => setState(() => _replies = v),
          ),
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 18, color: t.textSecondary),
              const SizedBox(width: VibraSpacing.xs),
              Expanded(
                child: Text(
                  l10n.storyExpires,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: t.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: VibraSpacing.lg),
          VibraButton(
            label: l10n.storyShare,
            tone: VibraButtonTone.signal,
            leadingIcon: Icons.auto_awesome_rounded,
            expanded: true,
            loading: _posting,
            onPressed: _valid && !_posting ? () => _post(defaults) : null,
          ),
        ],
      ),
    );
  }
}
