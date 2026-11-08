import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/entities/feed_post.dart';
import '../../../domain/entities/music_story.dart' show StoryItem;
import '../../../l10n/app_localizations.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/core_providers.dart';
import '../../providers/feed_providers.dart';
import '../../providers/profile_photo_provider.dart';
import '../../widgets/common/vibra_button.dart';
import '../../widgets/common/vibra_image.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/feed_widgets.dart';

void _snack(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

/// VIBRA Feed composer (docs/vibra-feed.md): recommendation, song, album,
/// playlist, review, discovery, opinion or concert photo.
class FeedComposerScreen extends ConsumerStatefulWidget {
  const FeedComposerScreen({this.initialKind, super.key});
  final FeedKind? initialKind;

  @override
  ConsumerState<FeedComposerScreen> createState() => _FeedComposerScreenState();
}

class _FeedComposerScreenState extends ConsumerState<FeedComposerScreen> {
  late FeedKind _kind = widget.initialKind ?? FeedKind.recommendation;
  late FeedItemType? _type = _kind.itemTypes.firstOrNull;
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
  int _rating = 0;
  bool _everyone = true;
  bool _comments = true;
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

  void _setKind(FeedKind k) => setState(() {
    _kind = k;
    if (!k.itemTypes.contains(_type)) _type = k.itemTypes.firstOrNull;
    _results = null;
    _picked = null;
    _searchError = null;
  });

  void _setType(FeedItemType t) => setState(() {
    _type = t;
    _results = null;
    _picked = null;
  });

  Future<void> _search() async {
    final l10n = AppLocalizations.of(context)!;
    final q = _query.text.trim();
    if (q.isEmpty || _type == null) return;
    setState(() {
      _searching = true;
      _searchError = null;
    });
    try {
      final results = await ref
          .read(supabaseFeedDatasourceProvider)
          .search(_type!, q);
      if (mounted) setState(() => _results = results);
    } catch (e) {
      if (mounted) {
        setState(
          () => _searchError = '$e'.contains('music_provider_unavailable')
              ? l10n.vibeProviderUnavailable
              : l10n.feedError,
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

  bool get _valid {
    final itemOk =
        !_kind.hasItem ||
        (_link
            ? _url.text.trim().startsWith('https://') &&
                  _title.text.trim().isNotEmpty
            : _picked?.itemId != null);
    return itemOk &&
        switch (_kind) {
          FeedKind.opinion => _text != null,
          FeedKind.review => _text != null && _rating > 0,
          FeedKind.concertPhoto => _photo != null,
          _ => true,
        };
  }

  Future<void> _post() async {
    final l10n = AppLocalizations.of(context)!;
    final source = ref.read(supabaseFeedDatasourceProvider);
    setState(() => _posting = true);
    try {
      final media = _kind == FeedKind.concertPhoto
          ? await source.uploadPhoto(_photo!)
          : null;
      final item = _kind.hasItem;
      await source.post(
        kind: _kind,
        itemType: item ? _type : null,
        spotifyItem: item && !_link ? _picked : null,
        linkUrl: item && _link ? _url.text.trim() : null,
        linkTitle: item && _link ? _title.text.trim() : null,
        linkSubtitle: item && _link && _subtitle.text.trim().isNotEmpty
            ? _subtitle.text.trim()
            : null,
        mediaPath: media,
        eventId: _kind == FeedKind.concertPhoto ? _eventId : null,
        body: _text,
        rating: _kind == FeedKind.review ? _rating : null,
        everyone: _everyone,
        commentsEnabled: _comments,
      );
      final me = source.currentUserId;
      if (me != null) ref.invalidate(userFeedPostsProvider(me));
      if (!mounted) return;
      _snack(context, l10n.feedPosted);
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _posting = false);
      final m = '$e';
      _snack(
        context,
        m.contains('rate_limited')
            ? l10n.storyRateLimited
            : m.contains('duplicate_post')
            ? l10n.feedDuplicatePost
            : m.contains('spam_detected')
            ? l10n.storySpam
            : m.contains('image_too_large') || m.contains('invalid_image')
            ? l10n.storyPhotoError
            : l10n.feedError,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    void rebuild(String _) => setState(() {});
    final events = [
      ...ref.watch(myEventsProvider).going,
      ...ref.watch(myEventsProvider).saved,
    ].where((e) => RegExp(r'^[0-9a-f-]{36}$').hasMatch(e.id)).toList();

    return VibraPageScaffold(
      appBar: AppBar(title: Text(l10n.feedNewPost)),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          VibraSpacing.pagePadding,
          VibraSpacing.sm,
          VibraSpacing.pagePadding,
          VibraSpacing.colossal,
        ),
        children: [
          Wrap(
            spacing: VibraSpacing.xs,
            runSpacing: VibraSpacing.xs,
            children: [
              for (final k in FeedKind.composable)
                ChoiceChip(
                  avatar: Icon(feedKindIcon(k), size: 18),
                  label: Text(feedKindLabel(l10n, k)),
                  selected: _kind == k,
                  showCheckmark: false,
                  onSelected: (_) => _setKind(k),
                ),
            ],
          ),
          const SizedBox(height: VibraSpacing.lg),

          if (_kind.hasItem) ...[
            if (_kind.itemTypes.length > 1) ...[
              Text(l10n.feedWhatAbout, style: theme.textTheme.labelLarge),
              const SizedBox(height: VibraSpacing.xs),
              Wrap(
                spacing: VibraSpacing.xs,
                children: [
                  for (final it in _kind.itemTypes)
                    ChoiceChip(
                      label: Text(feedItemTypeLabel(l10n, it)),
                      selected: _type == it,
                      onSelected: (_) => _setType(it),
                    ),
                ],
              ),
              const SizedBox(height: VibraSpacing.md),
            ],
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
                  hintText: switch (_type) {
                    FeedItemType.artist => l10n.storySearchArtist,
                    FeedItemType.album => l10n.storySearchAlbum,
                    FeedItemType.playlist => l10n.storySearchPlaylist,
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
                        _type == FeedItemType.artist ? 22 : 6,
                      ),
                      child: SizedBox.square(
                        dimension: 44,
                        child: VibraNetworkImage(
                          url: item.artworkUrl,
                          cacheWidth: 120,
                          fallbackIcon: feedKindIcon(_kind),
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
                  hintText: switch (_type) {
                    FeedItemType.artist => l10n.storyArtistNameHint,
                    FeedItemType.album => l10n.storyAlbumTitleHint,
                    FeedItemType.playlist => l10n.storyPlaylistTitleHint,
                    _ => l10n.vibeTitleHint,
                  },
                ),
              ),
              if (_type != FeedItemType.artist)
                TextField(
                  controller: _subtitle,
                  onChanged: rebuild,
                  maxLength: 200,
                  decoration: InputDecoration(
                    hintText: _type == FeedItemType.playlist
                        ? l10n.storyPlaylistOwnerHint
                        : l10n.vibeArtistHint,
                  ),
                ),
            ],
            const SizedBox(height: VibraSpacing.md),
          ],

          if (_kind == FeedKind.concertPhoto) ...[
            if (_photo != null)
              Padding(
                padding: const EdgeInsets.only(bottom: VibraSpacing.sm),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    VibraSpacing.radiusMedium,
                  ),
                  child: AspectRatio(
                    aspectRatio: 4 / 5,
                    child: Image.memory(_photo!, fit: BoxFit.cover),
                  ),
                ),
              ),
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
            const SizedBox(height: VibraSpacing.md),
          ],

          if (_kind == FeedKind.review) ...[
            Text(l10n.feedYourRating, style: theme.textTheme.labelLarge),
            RatingStars(
              rating: _rating,
              size: 32,
              onChanged: (r) => setState(() => _rating = r),
            ),
            const SizedBox(height: VibraSpacing.sm),
          ],

          TextField(
            controller: _body,
            onChanged: rebuild,
            maxLength: 2000,
            minLines: _kind == FeedKind.opinion || _kind == FeedKind.review
                ? 4
                : 2,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: switch (_kind) {
                FeedKind.opinion => l10n.storyOpinionHint,
                FeedKind.review => l10n.feedReviewHint,
                FeedKind.discovery => l10n.feedDiscoveryHint,
                FeedKind.recommendation => l10n.feedRecommendationHint,
                _ => l10n.feedBodyHint,
              },
            ),
          ),

          const SizedBox(height: VibraSpacing.md),
          Text(l10n.storyAudience, style: theme.textTheme.titleSmall),
          const SizedBox(height: VibraSpacing.sm),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: true,
                icon: const Icon(Icons.public_rounded),
                label: Text(l10n.storyAudienceEveryone),
              ),
              ButtonSegment(
                value: false,
                icon: const Icon(Icons.group_rounded),
                label: Text(l10n.storyAudienceConnections),
              ),
            ],
            selected: {_everyone},
            onSelectionChanged: (s) => setState(() => _everyone = s.first),
          ),
          const SizedBox(height: VibraSpacing.xs),
          Text(
            _everyone
                ? l10n.feedAudienceEveryoneBody
                : l10n.storyAudienceConnectionsBody,
            style: theme.textTheme.bodySmall?.copyWith(color: t.textSecondary),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.feedAllowComments),
            value: _comments,
            onChanged: (v) => setState(() => _comments = v),
          ),
          const SizedBox(height: VibraSpacing.md),
          VibraButton(
            label: l10n.feedPublish,
            tone: VibraButtonTone.signal,
            leadingIcon: Icons.send_rounded,
            expanded: true,
            loading: _posting,
            onPressed: _valid && !_posting ? _post : null,
          ),
        ],
      ),
    );
  }
}
