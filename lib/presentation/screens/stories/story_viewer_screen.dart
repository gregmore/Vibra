import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/vibra_colors.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/music_reaction.dart';
import '../../../domain/entities/music_story.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/core_providers.dart';
import '../../providers/music_story_providers.dart';
import '../../widgets/common/vibra_avatar.dart';
import '../../widgets/common/vibra_bottom_sheet.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/community_widgets.dart';
import '../../widgets/music_reactions.dart';
import '../../widgets/music_story_widgets.dart';
import '../../widgets/daily_vibe_widgets.dart' show pickReportReason;

void _snack(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

/// How long each story stays on screen.
const storyDuration = Duration(seconds: 6);

String storyAge(AppLocalizations l10n, DateTime createdAt) {
  final d = DateTime.now().difference(createdAt);
  if (d.inMinutes < 1) return l10n.storyJustNow;
  if (d.inHours < 1) return l10n.storyMinutesAgo(d.inMinutes);
  return l10n.storyHoursAgo(d.inHours);
}

/// MUSIC STORIES viewer (docs/music-stories.md): one page per person, their
/// stories in order. Tap right/left to move, hold to pause, swipe down to
/// close.
class StoryViewerScreen extends ConsumerStatefulWidget {
  const StoryViewerScreen({
    required this.userIds,
    this.initialIndex = 0,
    this.openRepliesFor,
    super.key,
  });

  final List<String> userIds;
  final int initialIndex;

  /// Opens the replies of this story (from a reply notification).
  final String? openRepliesFor;

  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen> {
  late final PageController _pages = PageController(
    initialPage: widget.initialIndex.clamp(0, widget.userIds.length - 1),
  );

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _go(int delta) {
    final page = (_pages.page ?? widget.initialIndex.toDouble()).round();
    final next = page + delta;
    if (next < 0) return;
    if (next >= widget.userIds.length) return _close();
    _pages.animateToPage(
      next,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Seen rings update when the viewer closes.
    return PopScope(
      onPopInvokedWithResult: (_, _) => ref.invalidate(storyRingProvider),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: VibraPalette.ink950,
          body: GestureDetector(
            onVerticalDragEnd: (d) {
              if ((d.primaryVelocity ?? 0) > 400) _close();
            },
            child: PageView.builder(
              controller: _pages,
              itemCount: widget.userIds.length,
              itemBuilder: (_, i) => _PersonStories(
                key: ValueKey(widget.userIds[i]),
                userId: widget.userIds[i],
                openRepliesFor: widget.openRepliesFor,
                onNextPerson: () => _go(1),
                onPreviousPerson: () => _go(-1),
                onClose: _close,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonStories extends ConsumerStatefulWidget {
  const _PersonStories({
    required this.userId,
    required this.onNextPerson,
    required this.onPreviousPerson,
    required this.onClose,
    this.openRepliesFor,
    super.key,
  });

  final String userId;
  final String? openRepliesFor;
  final VoidCallback onNextPerson;
  final VoidCallback onPreviousPerson;
  final VoidCallback onClose;

  @override
  ConsumerState<_PersonStories> createState() => _PersonStoriesState();
}

class _PersonStoriesState extends ConsumerState<_PersonStories>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: storyDuration,
  )..addStatusListener(_onStatus);
  final _reply = TextEditingController();
  final _replyFocus = FocusNode();
  final _viewed = <String>{};
  List<MusicStory>? _stories;
  int _index = 0;
  bool _held = false;
  bool _openedReplies = false;

  @override
  void initState() {
    super.initState();
    _replyFocus.addListener(_sync);
  }

  @override
  void dispose() {
    _progress.dispose();
    _reply.dispose();
    _replyFocus.dispose();
    super.dispose();
  }

  bool get _mine =>
      widget.userId ==
      ref.read(supabaseMusicStoriesDatasourceProvider).currentUserId;

  void _onStatus(AnimationStatus s) {
    if (s == AnimationStatus.completed) _next();
  }

  /// Plays unless held, typing, or behind a sheet/route.
  void _sync() {
    final route = ModalRoute.of(context);
    final paused = _held || _replyFocus.hasFocus || !(route?.isCurrent ?? true);
    if (paused) {
      _progress.stop();
    } else if (_stories?.isNotEmpty == true && !_progress.isAnimating) {
      _progress.forward();
    }
  }

  void _show(int i) {
    final stories = _stories!;
    setState(() => _index = i);
    _progress.forward(from: 0);
    _sync();
    final s = stories[i];
    if (!_mine && !s.seen && _viewed.add(s.id)) {
      ref
          .read(supabaseMusicStoriesDatasourceProvider)
          .markViewed(s.id)
          .catchError((_) {});
    }
  }

  void _next() {
    final stories = _stories;
    if (stories == null || _index >= stories.length - 1) {
      widget.onNextPerson();
    } else {
      _show(_index + 1);
    }
  }

  void _previous() {
    if (_index == 0) {
      widget.onPreviousPerson();
    } else {
      _show(_index - 1);
    }
  }

  void _start(List<MusicStory> stories) {
    _stories = stories;
    if (stories.isEmpty) return;
    // Mine start at the first; others' at the first unseen.
    final first = _mine ? 0 : stories.indexWhere((s) => !s.seen);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final open = widget.openRepliesFor;
      final target = open == null
          ? (first < 0 ? 0 : first)
          : stories.indexWhere((s) => s.id == open).clamp(0, stories.length);
      _show(target.clamp(0, stories.length - 1));
      if (open != null && !_openedReplies && _mine) {
        _openedReplies = true;
        _insights(stories[_index], replies: true);
      }
    });
  }

  void _replace(MusicStory s) {
    final list = _stories;
    if (list == null) return;
    setState(() => _stories = [for (final x in list) x.id == s.id ? s : x]);
  }

  Future<T?> _paused<T>(Future<T?> Function() open) async {
    _progress.stop();
    final result = await open();
    if (mounted) _sync();
    return result;
  }

  Future<void> _react(MusicStory s, String r) async {
    final on = !s.myReactions.contains(r);
    _replace(s.withReaction(r, on: on));
    try {
      await ref
          .read(supabaseMusicStoriesDatasourceProvider)
          .toggleReaction(s.id, r);
      if (mounted && s.kind == StoryKind.nowPlaying && s.item != null) {
        offerToSaveDiscovery(
          context,
          ref,
          reaction: r,
          turnedOn: on,
          source: DiscoverySource.story,
          id: s.id,
          externalUrl: s.item!.externalUrl,
        );
      }
    } catch (_) {
      _replace(s);
      if (mounted) _snack(context, AppLocalizations.of(context)!.storyError);
    }
  }

  Future<void> _sendReply(MusicStory s) async {
    final l10n = AppLocalizations.of(context)!;
    final text = _reply.text.trim();
    if (text.isEmpty) return;
    try {
      await ref.read(supabaseMusicStoriesDatasourceProvider).reply(s.id, text);
      _reply.clear();
      _replyFocus.unfocus();
      if (mounted) _snack(context, l10n.storyReplySent);
    } catch (_) {
      if (mounted) _snack(context, l10n.storyError);
    }
  }

  Future<void> _insights(MusicStory s, {bool replies = false}) => _paused(
    () => VibraBottomSheet.show<void>(
      context,
      builder: (_) => StoryInsightsSheet(story: s, startOnReplies: replies),
    ),
  );

  Future<void> _menu(MusicStory s) async {
    final l10n = AppLocalizations.of(context)!;
    final source = ref.read(supabaseMusicStoriesDatasourceProvider);
    final action = await _paused(
      () => VibraBottomSheet.show<String>(
        context,
        builder: (sheet) => VibraBottomSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (value, icon, label)
                  in _mine
                      ? [
                          (
                            'visibility',
                            Icons.public_rounded,
                            s.everyone
                                ? l10n.storyMakeConnectionsOnly
                                : l10n.storyMakeEveryone,
                          ),
                          (
                            'replies',
                            Icons.reply_rounded,
                            s.allowReplies
                                ? l10n.storyTurnRepliesOff
                                : l10n.storyTurnRepliesOn,
                          ),
                          (
                            'settings',
                            Icons.tune_rounded,
                            l10n.storySettingsTitle,
                          ),
                          (
                            'delete',
                            Icons.delete_outline_rounded,
                            l10n.storyDelete,
                          ),
                        ]
                      : [
                          (
                            'mute',
                            Icons.volume_off_outlined,
                            l10n.storyMute(s.name),
                          ),
                          (
                            'report',
                            Icons.flag_outlined,
                            l10n.socialReportAction,
                          ),
                          ('block', Icons.block_rounded, l10n.socialBlockUser),
                        ])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(icon),
                  title: Text(label),
                  onTap: () => Navigator.of(sheet).pop(value),
                ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || action == null) return;
    try {
      switch (action) {
        case 'visibility':
          await source.updateMine(s.id, everyone: !s.everyone);
          _replace(s.copyWith(everyone: !s.everyone));
          if (mounted) {
            _snack(
              context,
              !s.everyone ? l10n.storyNowEveryone : l10n.storyNowConnections,
            );
          }
        case 'replies':
          await source.updateMine(s.id, replies: !s.allowReplies);
          _replace(s.copyWith(allowReplies: !s.allowReplies));
        case 'settings':
          await _paused(() => context.push<void>('/story-settings'));
        case 'delete':
          await source.deleteMine(s.id);
          ref.invalidate(userStoriesProvider(widget.userId));
          ref.invalidate(storyRingProvider);
          final rest = [..._stories!]..removeWhere((x) => x.id == s.id);
          if (rest.isEmpty) {
            widget.onNextPerson();
          } else {
            _stories = rest;
            _show(_index.clamp(0, rest.length - 1));
          }
          if (mounted) _snack(context, l10n.storyDeleted);
        case 'mute':
          await source.setMuted(s.userId, true);
          ref.invalidate(storyRingProvider);
          if (mounted) _snack(context, l10n.storyMuted(s.name));
          widget.onNextPerson();
        case 'report':
          final reason = await _paused(() => pickReportReason(context));
          if (reason == null) return;
          await source.report(
            reportedId: s.userId,
            reason: reason,
            storyId: s.id,
          );
          if (mounted) _snack(context, l10n.communitiesReported);
        case 'block':
          final blocked = await _paused(
            () => blockCommunityAuthor(context, ref, s.userId),
          );
          if (blocked == true) {
            ref.invalidate(storyRingProvider);
            widget.onNextPerson();
          }
      }
    } catch (_) {
      if (mounted) _snack(context, l10n.storyError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(userStoriesProvider(widget.userId));
    return async.when(
      loading: () => const VibraLoadingView(),
      error: (_, _) => _Message(
        text: l10n.storyLoadError,
        onClose: widget.onClose,
        onRetry: () => ref.invalidate(userStoriesProvider(widget.userId)),
      ),
      data: (stories) {
        if (!identical(stories, _lastLoaded)) {
          _lastLoaded = stories;
          _start(stories);
        }
        final list = _stories ?? stories;
        if (list.isEmpty) {
          return _Message(text: l10n.storyGone, onClose: widget.onClose);
        }
        final s = list[_index.clamp(0, list.length - 1)];
        return SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(VibraSpacing.radiusLarge),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      StoryCanvas.of(s, key: ValueKey(s.id), showAction: false),
                      // Tap zones (left third: back, rest: next) under the
                      // header and buttons; hold anywhere to pause.
                      Positioned.fill(
                        child: Row(
                          children: [
                            Expanded(
                              child: _TapZone(
                                label: l10n.storyPrevious,
                                onTap: _previous,
                                onHold: (h) {
                                  _held = h;
                                  _sync();
                                },
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: _TapZone(
                                label: l10n.storyNext,
                                onTap: _next,
                                onHold: (h) {
                                  _held = h;
                                  _sync();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (s.item != null)
                        // Above the tap zones so it stays tappable.
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: VibraSpacing.xl,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              StoryItemAction(
                                item: s.item!,
                                onOpen: () =>
                                    _paused(() => openStoryItem(s.item!)),
                              ),
                              if (!_mine && s.kind == StoryKind.nowPlaying)
                                SaveSongButton(
                                  source: DiscoverySource.story,
                                  id: s.id,
                                  externalUrl: s.item!.externalUrl,
                                  onDark: true,
                                ),
                            ],
                          ),
                        ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: _Header(
                          story: s,
                          count: list.length,
                          index: _index,
                          progress: _progress,
                          mine: _mine,
                          onMenu: () => _menu(s),
                          onClose: widget.onClose,
                          onProfile: () => _paused(
                            () => context.push<void>(
                              '/user-profile',
                              extra: s.userId,
                            ),
                          ),
                        ),
                      ),
                      if (s.heldForReview)
                        Positioned(
                          left: VibraSpacing.lg,
                          right: VibraSpacing.lg,
                          top: 88,
                          child: _Banner(text: l10n.storyHeld),
                        ),
                    ],
                  ),
                ),
              ),
              _mine
                  ? _OwnerBar(story: s, onOpen: () => _insights(s))
                  : _ViewerBar(
                      story: s,
                      reply: _reply,
                      focus: _replyFocus,
                      onReact: (r) => _react(s, r),
                      onSend: () => _sendReply(s),
                    ),
            ],
          ),
        );
      },
    );
  }

  List<MusicStory>? _lastLoaded;
}

class _TapZone extends StatelessWidget {
  const _TapZone({
    required this.label,
    required this.onTap,
    required this.onHold,
  });
  final String label;
  final VoidCallback onTap;
  final ValueChanged<bool> onHold;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      onLongPressStart: (_) => onHold(true),
      onLongPressEnd: (_) => onHold(false),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({
    required this.story,
    required this.count,
    required this.index,
    required this.progress,
    required this.mine,
    required this.onMenu,
    required this.onClose,
    required this.onProfile,
  });

  final MusicStory story;
  final int count;
  final int index;
  final Animation<double> progress;
  final bool mine;
  final VoidCallback onMenu;
  final VoidCallback onClose;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const white = VibraPalette.textOnDark;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x99000000), Color(0x00000000)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          VibraSpacing.md,
          VibraSpacing.sm,
          VibraSpacing.xs,
          VibraSpacing.lg,
        ),
        child: Column(
          children: [
            Row(
              children: [
                for (var i = 0; i < count; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: AnimatedBuilder(
                          animation: progress,
                          builder: (_, _) => LinearProgressIndicator(
                            minHeight: 2.5,
                            value: i < index
                                ? 1
                                : i == index
                                ? progress.value
                                : 0,
                            backgroundColor: const Color(0x4DFFFFFF),
                            valueColor: const AlwaysStoppedAnimation(white),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: VibraSpacing.sm),
            Row(
              children: [
                GestureDetector(
                  onTap: onProfile,
                  child: VibraAvatar(
                    imageUrl: story.avatarUrl,
                    name: story.name,
                    radius: 16,
                  ),
                ),
                const SizedBox(width: VibraSpacing.sm),
                Expanded(
                  child: GestureDetector(
                    onTap: onProfile,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: mine ? l10n.storyYours : story.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: '  ${storyAge(l10n, story.createdAt)}',
                            style: const TextStyle(
                              color: VibraPalette.textOnDarkSecondary,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: white),
                    ),
                  ),
                ),
                if (mine)
                  Tooltip(
                    message: story.everyone
                        ? l10n.storyAudienceEveryone
                        : l10n.storyAudienceConnections,
                    child: Icon(
                      story.everyone
                          ? Icons.public_rounded
                          : Icons.group_rounded,
                      size: 18,
                      color: VibraPalette.textOnDarkSecondary,
                    ),
                  ),
                IconButton(
                  tooltip: l10n.storyMore,
                  onPressed: onMenu,
                  color: white,
                  icon: const Icon(Icons.more_horiz_rounded),
                ),
                IconButton(
                  tooltip: l10n.commonClose,
                  onPressed: onClose,
                  color: white,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(VibraSpacing.md),
    decoration: BoxDecoration(
      color: const Color(0xCC000000),
      borderRadius: BorderRadius.circular(VibraSpacing.radiusSmall),
      border: Border.all(color: VibraPalette.warning),
    ),
    child: Text(text, style: const TextStyle(color: VibraPalette.textOnDark)),
  );
}

/// Reactions and a private reply, for viewers.
class _ViewerBar extends StatelessWidget {
  const _ViewerBar({
    required this.story,
    required this.reply,
    required this.focus,
    required this.onReact,
    required this.onSend,
  });

  final MusicStory story;
  final TextEditingController reply;
  final FocusNode focus;
  final ValueChanged<String> onReact;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        VibraSpacing.md,
        VibraSpacing.sm,
        VibraSpacing.md,
        VibraSpacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Musical reactions on "Now listening" (docs/track-reactions.md).
          ReactionButtonRow(
            options: MusicReactions.forContent(
              song: story.kind == StoryKind.nowPlaying,
            ),
            mine: story.myReactions,
            onToggle: onReact,
          ),
          const SizedBox(height: VibraSpacing.sm),
          if (story.allowReplies)
            TextField(
              controller: reply,
              focusNode: focus,
              maxLength: 500,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: VibraPalette.textOnDark,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: l10n.storyReplyHint(story.name),
                hintStyle: const TextStyle(
                  color: VibraPalette.textOnDarkSecondary,
                ),
                filled: true,
                fillColor: VibraPalette.ink850,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: VibraPalette.ink600),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: VibraPalette.ink600),
                ),
                suffixIcon: IconButton(
                  tooltip: l10n.storySendReply,
                  onPressed: onSend,
                  color: VibraPalette.textOnDark,
                  icon: const Icon(Icons.send_rounded),
                ),
              ),
            )
          else
            Text(
              l10n.storyRepliesOff,
              style: theme.textTheme.bodySmall?.copyWith(
                color: VibraPalette.textOnDarkMuted,
              ),
            ),
        ],
      ),
    );
  }
}

/// For the author: views and replies.
class _OwnerBar extends StatelessWidget {
  const _OwnerBar({required this.story, required this.onOpen});
  final MusicStory story;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reactions = story.reactions.values.fold<int>(0, (a, b) => a + b);
    return Padding(
      padding: const EdgeInsets.all(VibraSpacing.sm),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: onOpen,
            style: TextButton.styleFrom(
              foregroundColor: VibraPalette.textOnDark,
            ),
            icon: const Icon(Icons.visibility_outlined),
            label: Text(l10n.storyViews(story.viewCount ?? 0)),
          ),
          if (reactions > 0)
            Text(
              l10n.storyReactionCount(reactions),
              style: const TextStyle(color: VibraPalette.textOnDarkSecondary),
            ),
          const Spacer(),
          TextButton.icon(
            onPressed: onOpen,
            style: TextButton.styleFrom(
              foregroundColor: VibraPalette.textOnDark,
            ),
            icon: const Icon(Icons.mode_comment_outlined),
            label: Text(l10n.storyReplies(story.replyCount ?? 0)),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.onClose, this.onRetry});
  final String text;
  final VoidCallback onClose;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(VibraSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: VibraPalette.textOnDark),
              ),
              const SizedBox(height: VibraSpacing.lg),
              Wrap(
                spacing: VibraSpacing.sm,
                children: [
                  if (onRetry != null)
                    FilledButton(
                      onPressed: onRetry,
                      child: Text(l10n.commonRetry),
                    ),
                  OutlinedButton(
                    onPressed: onClose,
                    child: Text(l10n.commonClose),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Who viewed a story and the private reply threads (author only).
class StoryInsightsSheet extends ConsumerStatefulWidget {
  const StoryInsightsSheet({
    required this.story,
    this.startOnReplies = false,
    super.key,
  });
  final MusicStory story;
  final bool startOnReplies;

  @override
  ConsumerState<StoryInsightsSheet> createState() => _InsightsState();
}

class _InsightsState extends ConsumerState<StoryInsightsSheet> {
  late bool _replies = widget.startOnReplies;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final s = widget.story;
    return VibraBottomSheet(
      title: storyKindLabel(l10n, s.kind),
      subtitle: l10n.storyInsightsPrivate,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: false,
                label: Text(l10n.storyViews(s.viewCount ?? 0)),
              ),
              ButtonSegment(
                value: true,
                label: Text(l10n.storyReplies(s.replyCount ?? 0)),
              ),
            ],
            selected: {_replies},
            onSelectionChanged: (v) => setState(() => _replies = v.first),
          ),
          const SizedBox(height: VibraSpacing.md),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.5,
            ),
            child: _replies
                ? _Threads(story: s)
                : ref
                      .watch(storyViewersProvider(s.id))
                      .when(
                        loading: () => const VibraLoadingIndicator(),
                        error: (_, _) => Text(l10n.storyError),
                        data: (viewers) => viewers.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(VibraSpacing.lg),
                                child: Text(
                                  l10n.storyNoViewers,
                                  style: TextStyle(color: t.textSecondary),
                                ),
                              )
                            : ListView(
                                shrinkWrap: true,
                                children: [
                                  for (final v in viewers)
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: VibraAvatar(
                                        imageUrl: v.avatarUrl,
                                        name: v.name,
                                        radius: 18,
                                      ),
                                      title: Text(v.name),
                                      trailing: Text(
                                        v.reactions
                                            .map(reactionEmoji)
                                            .join(' '),
                                      ),
                                    ),
                                ],
                              ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _Threads extends ConsumerWidget {
  const _Threads({required this.story});
  final MusicStory story;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    return ref
        .watch(storyRepliesProvider(story.id))
        .when(
          loading: () => const VibraLoadingIndicator(),
          error: (_, _) => Text(l10n.storyError),
          data: (replies) {
            final threads = storyThreads(replies, story.userId);
            if (threads.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(VibraSpacing.lg),
                child: Text(
                  story.allowReplies
                      ? l10n.storyNoReplies
                      : l10n.storyRepliesOffMine,
                  style: TextStyle(color: t.textSecondary),
                ),
              );
            }
            return ListView(
              shrinkWrap: true,
              children: [
                for (final MapEntry(key: viewer, value: thread)
                    in threads.entries)
                  _Thread(story: story, viewerId: viewer, replies: thread),
              ],
            );
          },
        );
  }
}

class _Thread extends ConsumerStatefulWidget {
  const _Thread({
    required this.story,
    required this.viewerId,
    required this.replies,
  });
  final MusicStory story;
  final String viewerId;
  final List<StoryReply> replies;

  @override
  ConsumerState<_Thread> createState() => _ThreadState();
}

class _ThreadState extends ConsumerState<_Thread> {
  final _answer = TextEditingController();

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    final text = _answer.text.trim();
    if (text.isEmpty) return;
    try {
      await ref
          .read(supabaseMusicStoriesDatasourceProvider)
          .reply(widget.story.id, text, recipientId: widget.viewerId);
      _answer.clear();
      ref.invalidate(storyRepliesProvider(widget.story.id));
    } catch (_) {
      if (mounted) _snack(context, l10n.storyError);
    }
  }

  Future<void> _report(StoryReply r) async {
    final l10n = AppLocalizations.of(context)!;
    final reason = await pickReportReason(context);
    if (reason == null) return;
    try {
      await ref
          .read(supabaseMusicStoriesDatasourceProvider)
          .report(reportedId: r.senderId, reason: reason, replyId: r.id);
      ref.invalidate(storyRepliesProvider(widget.story.id));
      if (mounted) _snack(context, l10n.communitiesReported);
    } catch (_) {
      if (mounted) _snack(context, l10n.socialReportFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    final viewer = widget.replies.firstWhere(
      (r) => r.senderId == widget.viewerId,
      orElse: () => widget.replies.first,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: VibraSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              VibraAvatar(
                imageUrl: viewer.avatarUrl,
                name: viewer.name,
                radius: 14,
              ),
              const SizedBox(width: VibraSpacing.sm),
              Expanded(
                child: Text(viewer.name, style: theme.textTheme.titleSmall),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz_rounded, size: 20),
                onSelected: (a) async {
                  if (a == 'report') await _report(viewer);
                  if (a == 'block' && context.mounted) {
                    if (await blockCommunityAuthor(
                      context,
                      ref,
                      widget.viewerId,
                    )) {
                      ref.invalidate(storyRepliesProvider(widget.story.id));
                    }
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'report',
                    child: Text(l10n.socialReportAction),
                  ),
                  PopupMenuItem(
                    value: 'block',
                    child: Text(l10n.socialBlockUser),
                  ),
                ],
              ),
            ],
          ),
          for (final r in widget.replies)
            Align(
              alignment: r.senderId == widget.viewerId
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.only(top: VibraSpacing.xs),
                padding: const EdgeInsets.symmetric(
                  horizontal: VibraSpacing.md,
                  vertical: VibraSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: r.senderId == widget.viewerId
                      ? t.surfaceMuted
                      : t.accentFill,
                  borderRadius: BorderRadius.circular(
                    VibraSpacing.radiusMedium,
                  ),
                ),
                child: Text(
                  r.body,
                  style: TextStyle(
                    color: r.senderId == widget.viewerId
                        ? t.textPrimary
                        : t.onAccent,
                  ),
                ),
              ),
            ),
          const SizedBox(height: VibraSpacing.xs),
          TextField(
            controller: _answer,
            maxLength: 500,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _send(),
            decoration: InputDecoration(
              counterText: '',
              isDense: true,
              hintText: l10n.storyAnswerHint(viewer.name),
              suffixIcon: IconButton(
                tooltip: l10n.storySendReply,
                onPressed: _send,
                icon: const Icon(Icons.send_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
