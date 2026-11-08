import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/community.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/community_providers.dart';
import '../../providers/core_providers.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/community_widgets.dart';
import 'community_screen.dart';

/// One post with its comments and a comment composer (members only).
class CommunityPostScreen extends ConsumerStatefulWidget {
  const CommunityPostScreen({
    required this.post,
    required this.communityId,
    super.key,
  });

  final CommunityPost post;
  final String communityId;

  @override
  ConsumerState<CommunityPostScreen> createState() =>
      _CommunityPostScreenState();
}

class _CommunityPostScreenState extends ConsumerState<CommunityPostScreen> {
  late CommunityPost _post = widget.post;
  final _comment = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    final text = _comment.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(supabaseCommunitiesDatasourceProvider)
          .comment(_post.id, text);
      _comment.clear();
      ref.invalidate(communityCommentsProvider(_post.id));
    } catch (e) {
      if (mounted) communitySnack(context, communityErrorText(l10n, e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _react(String reaction) async {
    final before = _post;
    setState(
      () => _post = _post.withReaction(
        reaction,
        on: !_post.myReactions.contains(reaction),
      ),
    );
    try {
      await ref
          .read(supabaseCommunitiesDatasourceProvider)
          .toggleReaction(_post.id, reaction);
    } catch (_) {
      if (mounted) setState(() => _post = before);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final community = ref.watch(communityByIdProvider(widget.communityId));
    final isMember = community?.isMember ?? false;
    final canModerate = community?.myRole?.canModerate ?? false;
    final me = ref.read(supabaseCommunitiesDatasourceProvider).currentUserId;
    final comments = ref.watch(communityCommentsProvider(_post.id));
    void close() {
      if (mounted) Navigator.of(context).maybePop();
    }

    return VibraPageScaffold(
      appBar: AppBar(title: Text(community?.name ?? '')),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(VibraSpacing.pagePadding),
              children: [
                CommunityPostCard(
                  post: _post,
                  expanded: true,
                  isMine: _post.author.id == me,
                  canModerate: canModerate,
                  canInteract: isMember,
                  onReact: _react,
                  onAction: (a) => handleContentAction(
                    context,
                    ref,
                    a,
                    communityId: widget.communityId,
                    authorId: _post.author.id,
                    authorName: _post.author.name,
                    postId: _post.id,
                    onGone: close,
                  ),
                ),
                const SizedBox(height: VibraSpacing.lg),
                ...comments.when(
                  loading: () => [const VibraLoadingIndicator()],
                  error: (e, _) => [
                    VibraErrorView(
                      error: e,
                      compact: true,
                      title: l10n.communitiesTitle,
                      message: l10n.communitiesLoadError,
                      onRetry: () =>
                          ref.invalidate(communityCommentsProvider(_post.id)),
                    ),
                  ],
                  data: (list) => list.isEmpty
                      ? [
                          Text(
                            l10n.communitiesEmptyComments,
                            style: TextStyle(color: t.textSecondary),
                          ),
                        ]
                      : [
                          for (final c in list)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: VibraSpacing.md,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CommunityAuthorLine(
                                    author: c.author,
                                    createdAt: c.createdAt,
                                    trailing: ContentMenu(
                                      isMine: c.author.id == me,
                                      canModerate: canModerate,
                                      isRemovedOrHeld: c.heldForReview,
                                      onSelected: (a) => handleContentAction(
                                        context,
                                        ref,
                                        a,
                                        communityId: widget.communityId,
                                        authorId: c.author.id,
                                        authorName: c.author.name,
                                        postId: _post.id,
                                        commentId: c.id,
                                        onGone: () => ref.invalidate(
                                          communityCommentsProvider(_post.id),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 40),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (c.heldForReview)
                                          Text(
                                            l10n.communitiesHeld,
                                            style: TextStyle(color: t.warning),
                                          ),
                                        Text(c.body),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                ),
              ],
            ),
          ),
          if (isMember)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  VibraSpacing.pagePadding,
                  VibraSpacing.sm,
                  VibraSpacing.sm,
                  VibraSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _comment,
                        maxLength: 1000,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: l10n.communitiesCommentHint,
                          counterText: '',
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.communitiesCommentHint,
                      onPressed: _sending ? null : _send,
                      icon: Icon(Icons.send_rounded, color: t.accentPrimary),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(VibraSpacing.lg),
              child: Text(
                l10n.communitiesJoinToPost,
                style: TextStyle(color: t.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}
