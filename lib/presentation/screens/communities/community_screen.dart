import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/community.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/community_providers.dart';
import '../../providers/core_providers.dart';
import '../../widgets/common/vibra_avatar.dart';
import '../../widgets/common/vibra_bottom_sheet.dart';
import '../../widgets/common/vibra_button.dart';
import '../../widgets/common/vibra_editorial_event.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/community_widgets.dart';

/// Runs a post/comment menu action and refreshes what it affects.
Future<void> handleContentAction(
  BuildContext context,
  WidgetRef ref,
  ContentAction action, {
  required String communityId,
  required String authorId,
  required String authorName,
  String? postId,
  String? commentId,
  VoidCallback? onGone,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final source = ref.read(supabaseCommunitiesDatasourceProvider);
  try {
    switch (action) {
      case ContentAction.report:
        await showCommunityReport(
          context,
          ref,
          reportedId: authorId,
          postId: commentId == null ? postId : null,
          commentId: commentId,
        );
        return;
      case ContentAction.block:
        if (await blockCommunityAuthor(context, ref, authorId)) onGone?.call();
        return;
      case ContentAction.delete:
        await source.deleteOwn(
          postId: commentId == null ? postId : null,
          commentId: commentId,
        );
        onGone?.call();
      case ContentAction.remove:
      case ContentAction.restore:
        await source.moderate(
          remove: action == ContentAction.remove,
          postId: commentId == null ? postId : null,
          commentId: commentId,
        );
        if (action == ContentAction.remove) onGone?.call();
        ref.invalidate(moderationQueueProvider(communityId));
      case ContentAction.ban:
        final ok = await showDialog<bool>(
          context: context,
          builder: (d) => AlertDialog(
            content: Text(l10n.communitiesBanConfirm(authorName)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(d).pop(false),
                child: Text(l10n.commonCancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(d).pop(true),
                child: Text(l10n.communitiesBan),
              ),
            ],
          ),
        );
        if (ok != true) return;
        await source.setBan(communityId, authorId, banned: true);
        ref.invalidate(communityMembersProvider(communityId));
    }
  } catch (e) {
    if (context.mounted) communitySnack(context, communityErrorText(l10n, e));
  }
}

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({required this.communityId, super.key});

  final String communityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final list = ref.watch(communitiesProvider);
    final community = ref.watch(communityByIdProvider(communityId));
    if (community == null) {
      return VibraPageScaffold(
        appBar: AppBar(),
        child: list.isLoading
            ? const VibraLoadingView()
            : VibraErrorView(
                error: list.error,
                title: l10n.communitiesTitle,
                message: l10n.communitiesLoadError,
                retryLabel: l10n.commonRetry,
                onRetry: () => ref.invalidate(communitiesProvider),
              ),
      );
    }
    final canModerate = community.myRole?.canModerate ?? false;
    return DefaultTabController(
      length: 4,
      child: VibraPageScaffold(
        appBar: AppBar(
          title: Text(community.name),
          actions: [
            if (canModerate)
              IconButton(
                tooltip: l10n.communitiesModeration,
                icon: const Icon(Icons.shield_outlined),
                onPressed: () =>
                    context.push('/community-moderation', extra: communityId),
              ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: l10n.communitiesTabPosts),
              Tab(text: l10n.communitiesTabDiscussions),
              Tab(text: l10n.communitiesTabEvents),
              Tab(text: l10n.communitiesTabMembers),
            ],
          ),
        ),
        floatingActionButton: community.isMember
            ? FloatingActionButton.extended(
                onPressed: () => showComposer(context, ref, community),
                icon: const Icon(Icons.edit_rounded),
                label: Text(l10n.communitiesNewPost),
              )
            : null,
        child: Column(
          children: [
            _Header(community: community),
            Expanded(
              child: TabBarView(
                children: [
                  _Feed(community: community, kind: CommunityPostKind.post),
                  _Feed(
                    community: community,
                    kind: CommunityPostKind.discussion,
                  ),
                  _Events(communityId: communityId),
                  _Members(community: community),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends ConsumerStatefulWidget {
  const _Header({required this.community});
  final Community community;

  @override
  ConsumerState<_Header> createState() => _HeaderState();
}

class _HeaderState extends ConsumerState<_Header> {
  bool _busy = false;

  Future<void> _toggle() async {
    final l10n = AppLocalizations.of(context)!;
    final c = widget.community;
    if (c.isMember) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (d) => AlertDialog(
          content: Text(l10n.communitiesLeaveConfirm(c.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(d).pop(false),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(d).pop(true),
              child: Text(l10n.communitiesLeave),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    setState(() => _busy = true);
    try {
      final notifier = ref.read(communitiesProvider.notifier);
      c.isMember ? await notifier.leave(c) : await notifier.join(c);
    } catch (e) {
      if (mounted) communitySnack(context, communityErrorText(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.community;
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        VibraSpacing.pagePadding,
        VibraSpacing.md,
        VibraSpacing.pagePadding,
        VibraSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [
              if (c.isOfficial) l10n.communitiesOfficial,
              communityKindLabel(l10n, c.kind),
              l10n.communitiesMembers(c.memberCount),
            ].join(' · ').toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: t.accentPrimary,
              letterSpacing: 1.2,
            ),
          ),
          if (c.description.isNotEmpty) ...[
            const SizedBox(height: VibraSpacing.xs),
            Text(
              c.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: t.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: VibraSpacing.md),
          Row(
            children: [
              VibraButton(
                label: c.isMember
                    ? l10n.communitiesLeave
                    : l10n.communitiesJoin,
                tone: c.isMember
                    ? VibraButtonTone.outline
                    : VibraButtonTone.signal,
                size: VibraButtonSize.compact,
                loading: _busy,
                onPressed: _busy || c.myRole == CommunityRole.owner
                    ? null
                    : _toggle,
              ),
              if (!c.isMember) ...[
                const SizedBox(width: VibraSpacing.md),
                Expanded(
                  child: Text(
                    l10n.communitiesJoinToPost,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: t.textMuted,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Feed extends ConsumerWidget {
  const _Feed({required this.community, required this.kind});
  final Community community;
  final CommunityPostKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final key = (communityId: community.id, kind: kind);
    final me = ref.read(supabaseCommunitiesDatasourceProvider).currentUserId;
    final canModerate = community.myRole?.canModerate ?? false;
    return ref
        .watch(communityFeedProvider(key))
        .when(
          loading: () => const VibraLoadingView(),
          error: (e, _) => VibraErrorView(
            error: e,
            title: l10n.communitiesTitle,
            message: l10n.communitiesLoadError,
            retryLabel: l10n.commonRetry,
            onRetry: () => ref.invalidate(communityFeedProvider(key)),
          ),
          data: (posts) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(communityFeedProvider(key));
              await ref.read(communityFeedProvider(key).future);
            },
            child: posts.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(VibraSpacing.pagePadding),
                    children: [
                      VibraEmptyView(
                        compact: true,
                        title: kind == CommunityPostKind.discussion
                            ? l10n.communitiesEmptyDiscussions
                            : l10n.communitiesEmptyFeed,
                        message: community.isMember
                            ? ''
                            : l10n.communitiesJoinToPost,
                        icon: Icons.forum_outlined,
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      VibraSpacing.pagePadding,
                      VibraSpacing.sm,
                      VibraSpacing.pagePadding,
                      VibraSpacing.navBarClearance,
                    ),
                    itemCount: posts.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: VibraSpacing.md),
                    itemBuilder: (context, i) {
                      final post = posts[i];
                      final feed = ref.read(
                        communityFeedProvider(key).notifier,
                      );
                      return CommunityPostCard(
                        post: post,
                        isMine: post.author.id == me,
                        canModerate: canModerate,
                        canInteract: community.isMember,
                        onOpen: () => context.push(
                          '/community-post',
                          extra: {'post': post, 'communityId': community.id},
                        ),
                        onReact: (r) async {
                          if (!await feed.toggleReaction(post, r) &&
                              context.mounted) {
                            communitySnack(context, l10n.communitiesError);
                          }
                        },
                        onAction: (a) => handleContentAction(
                          context,
                          ref,
                          a,
                          communityId: community.id,
                          authorId: post.author.id,
                          authorName: post.author.name,
                          postId: post.id,
                          onGone: () => feed.remove(post.id),
                        ),
                      );
                    },
                  ),
          ),
        );
  }
}

class _Events extends ConsumerWidget {
  const _Events({required this.communityId});
  final String communityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ref
        .watch(communityEventsProvider(communityId))
        .when(
          loading: () => const VibraLoadingView(),
          error: (e, _) => VibraErrorView(
            error: e,
            title: l10n.communitiesTabEvents,
            message: l10n.communitiesLoadError,
          ),
          data: (events) => events.isEmpty
              ? VibraEmptyView(
                  compact: true,
                  title: l10n.communitiesEmptyEvents,
                  message: '',
                  icon: Icons.event_outlined,
                )
              : ListView(
                  padding: const EdgeInsets.all(VibraSpacing.pagePadding),
                  children: [
                    for (final e in events)
                      VibraEventRow(
                        event: e,
                        onTap: () => context.push('/event-detail', extra: e),
                      ),
                  ],
                ),
        );
  }
}

class _Members extends ConsumerWidget {
  const _Members({required this.community});
  final Community community;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final me = ref.read(supabaseCommunitiesDatasourceProvider).currentUserId;
    final myRole = community.myRole;
    return ref
        .watch(communityMembersProvider(community.id))
        .when(
          loading: () => const VibraLoadingView(),
          error: (e, _) => VibraErrorView(
            error: e,
            title: l10n.communitiesTabMembers,
            message: l10n.communitiesLoadError,
          ),
          data: (members) => ListView(
            padding: const EdgeInsets.fromLTRB(
              VibraSpacing.pagePadding,
              VibraSpacing.sm,
              VibraSpacing.pagePadding,
              VibraSpacing.navBarClearance,
            ),
            children: [
              for (final m in members)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () =>
                      context.push('/user-profile', extra: m.author.id),
                  leading: VibraAvatar(
                    imageUrl: m.author.avatarUrl,
                    name: m.author.name,
                  ),
                  title: Text(m.author.name),
                  subtitle: switch (m.role) {
                    CommunityRole.owner => Text(
                      l10n.communitiesRoleOwner,
                      style: TextStyle(color: t.accentPrimary),
                    ),
                    CommunityRole.moderator => Text(
                      l10n.communitiesRoleModerator,
                      style: TextStyle(color: t.textSecondary),
                    ),
                    CommunityRole.member => null,
                  },
                  trailing:
                      m.author.id == me ||
                          m.role == CommunityRole.owner ||
                          !(myRole?.canModerate ?? false) ||
                          (m.role == CommunityRole.moderator &&
                              myRole != CommunityRole.owner)
                      ? null
                      : _MemberMenu(community: community, member: m),
                ),
            ],
          ),
        );
  }
}

class _MemberMenu extends ConsumerWidget {
  const _MemberMenu({required this.community, required this.member});
  final Community community;
  final CommunityMember member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isOwner = community.myRole == CommunityRole.owner;
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: (value) async {
        final source = ref.read(supabaseCommunitiesDatasourceProvider);
        try {
          switch (value) {
            case 'mod':
              await source.setRole(
                community.id,
                member.author.id,
                CommunityRole.moderator,
              );
            case 'unmod':
              await source.setRole(
                community.id,
                member.author.id,
                CommunityRole.member,
              );
            case 'ban':
              if (!context.mounted) return;
              await handleContentAction(
                context,
                ref,
                ContentAction.ban,
                communityId: community.id,
                authorId: member.author.id,
                authorName: member.author.name,
              );
              return;
          }
          ref.invalidate(communityMembersProvider(community.id));
        } catch (e) {
          if (context.mounted) {
            communitySnack(context, communityErrorText(l10n, e));
          }
        }
      },
      itemBuilder: (_) => [
        if (isOwner && member.role == CommunityRole.member)
          PopupMenuItem(
            value: 'mod',
            child: Text(l10n.communitiesMakeModerator),
          ),
        if (isOwner && member.role == CommunityRole.moderator)
          PopupMenuItem(
            value: 'unmod',
            child: Text(l10n.communitiesRemoveModerator),
          ),
        PopupMenuItem(value: 'ban', child: Text(l10n.communitiesBan)),
      ],
    );
  }
}

/// Post / discussion / shared-music composer.
Future<void> showComposer(
  BuildContext context,
  WidgetRef ref,
  Community community,
) async {
  final created = await VibraBottomSheet.show<CommunityPostKind>(
    context,
    builder: (_) => _Composer(communityId: community.id),
  );
  if (created != null) {
    ref.invalidate(
      communityFeedProvider((
        communityId: community.id,
        kind: created == CommunityPostKind.discussion
            ? CommunityPostKind.discussion
            : CommunityPostKind.post,
      )),
    );
  }
}

class _Composer extends ConsumerStatefulWidget {
  const _Composer({required this.communityId});
  final String communityId;

  @override
  ConsumerState<_Composer> createState() => _ComposerState();
}

class _ComposerState extends ConsumerState<_Composer> {
  CommunityPostKind _kind = CommunityPostKind.post;
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _link = TextEditingController();
  final _track = TextEditingController();
  final _artist = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_title, _body, _link, _track, _artist]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _valid => switch (_kind) {
    CommunityPostKind.post => _body.text.trim().isNotEmpty,
    CommunityPostKind.discussion => _title.text.trim().isNotEmpty,
    CommunityPostKind.music => _link.text.trim().startsWith('https://'),
    CommunityPostKind.event => false,
  };

  Future<void> _publish() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await ref
          .read(supabaseCommunitiesDatasourceProvider)
          .createPost(
            communityId: widget.communityId,
            kind: _kind,
            title: _kind == CommunityPostKind.discussion
                ? _title.text.trim()
                : null,
            body: _body.text.trim(),
            music: _kind == CommunityPostKind.music
                ? SharedMusic(
                    url: _link.text.trim(),
                    title: _track.text.trim().isEmpty
                        ? null
                        : _track.text.trim(),
                    artist: _artist.text.trim().isEmpty
                        ? null
                        : _artist.text.trim(),
                  )
                : null,
          );
      if (mounted) Navigator.of(context).pop(_kind);
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
    void rebuild(String _) => setState(() {});
    return VibraBottomSheet(
      title: l10n.communitiesNewPost,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<CommunityPostKind>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: CommunityPostKind.post,
                label: Text(l10n.communitiesComposerPost),
              ),
              ButtonSegment(
                value: CommunityPostKind.discussion,
                label: Text(l10n.communitiesComposerDiscussion),
              ),
              ButtonSegment(
                value: CommunityPostKind.music,
                label: Text(l10n.communitiesComposerMusic),
              ),
            ],
            selected: {_kind},
            onSelectionChanged: (s) => setState(() => _kind = s.first),
          ),
          const SizedBox(height: VibraSpacing.md),
          if (_kind == CommunityPostKind.discussion)
            TextField(
              controller: _title,
              maxLength: 120,
              decoration: InputDecoration(
                hintText: l10n.communitiesComposerTitleHint,
              ),
              onChanged: rebuild,
            ),
          if (_kind == CommunityPostKind.music) ...[
            TextField(
              controller: _link,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                hintText: l10n.communitiesComposerLinkHint,
              ),
              onChanged: rebuild,
            ),
            TextField(
              controller: _track,
              maxLength: 120,
              decoration: InputDecoration(
                hintText: l10n.communitiesComposerTrackHint,
              ),
            ),
            TextField(
              controller: _artist,
              maxLength: 80,
              decoration: InputDecoration(
                hintText: l10n.communitiesComposerArtistHint,
              ),
            ),
          ],
          TextField(
            controller: _body,
            maxLength: 4000,
            minLines: 3,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: l10n.communitiesComposerBodyHint,
            ),
            onChanged: rebuild,
          ),
          const SizedBox(height: VibraSpacing.sm),
          VibraButton(
            label: l10n.communitiesPublish,
            tone: VibraButtonTone.signal,
            expanded: true,
            loading: _busy,
            onPressed: _valid && !_busy ? _publish : null,
          ),
        ],
      ),
    );
  }
}
