import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/usecase_providers.dart';
import '../../widgets/common/vibra_avatar.dart';
import '../../widgets/common/vibra_button.dart';
import '../../widgets/common/vibra_input.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_surface.dart';
import '../../widgets/vibra_signal_wave.dart';

/// Inbox tipografica: il messaggio e la persona precedono i controlli.
class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  ConsumerState<ConversationsScreen> createState() =>
      _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _unreadOnly = false;
  final Set<String> _deleting = {};

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _unreadOnly = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final now = DateTime.now();
    final locale = Localizations.localeOf(context).toString();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    if (day == today) return DateFormat.Hm(locale).format(local);
    if (day.isBefore(today) && today.difference(day).inDays < 7) {
      return DateFormat.E(locale).format(local);
    }
    return (local.year == now.year
            ? DateFormat.MMMd(locale)
            : DateFormat.yMMMd(locale))
        .format(local);
  }

  Future<void> _deleteConversation(ConversationSummary conversation) async {
    if (_deleting.contains(conversation.otherUserId)) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: Text(l10n.inboxDeleteTitle),
        content: Text(
          '${conversation.effectiveDisplayName}\n\n${l10n.inboxDeleteBody}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.inboxDeleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true ||
        !mounted ||
        _deleting.contains(conversation.otherUserId)) {
      return;
    }
    setState(() => _deleting.add(conversation.otherUserId));
    try {
      await ref
          .read(softDeleteChatUseCaseProvider)
          .call(conversation.otherUserId);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.inboxDeleteSuccess)));
      await ref.read(conversationsProvider.notifier).refresh();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.inboxDeleteError)));
    } finally {
      if (mounted) setState(() => _deleting.remove(conversation.otherUserId));
    }
  }

  void _showConversationActions(ConversationSummary conversation) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                conversation.effectiveDisplayName,
                style: VibraTextStyles.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.of(context)!.inboxDeleteBody,
                style: VibraTextStyles.bodySmall,
              ),
              const SizedBox(height: 18),
              VibraButton(
                label: AppLocalizations.of(context)!.inboxDeleteAction,
                tone: VibraButtonTone.outline,
                leadingIcon: Icons.delete_outline_rounded,
                expanded: true,
                onPressed: () async {
                  Navigator.pop(sheetContext);
                  await _deleteConversation(conversation);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _conversationRow(ConversationSummary conversation) {
    final t = context.vibraTokens;
    final unread = conversation.unreadCount > 0;
    return Semantics(
      button: true,
      label: [
        AppLocalizations.of(
          context,
        )!.inboxOpenConversation(conversation.effectiveDisplayName),
        if (unread)
          AppLocalizations.of(
            context,
          )!.inboxUnreadCount(conversation.unreadCount),
      ].join(', '),
      liveRegion: unread,
      onLongPress: () => _showConversationActions(conversation),
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(
            '/chat',
            extra: {
              'otherUserId': conversation.otherUserId,
              'otherDisplayName': conversation.effectiveDisplayName,
            },
          ),
          onLongPress: () => _showConversationActions(conversation),
          splashColor: t.accentPrimary.withValues(alpha: 0.18),
          hoverColor: t.accentPrimary.withValues(alpha: 0.08),
          focusColor: t.accentPrimary.withValues(alpha: 0.12),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: t.borderDefault)),
            ),
            child: Row(
              children: [
                VibraAvatar(
                  imageUrl: conversation.otherAvatarUrl,
                  name: conversation.effectiveDisplayName,
                  radius: 26,
                  signalRing: unread,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.effectiveDisplayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: VibraTextStyles.titleLarge.copyWith(
                                fontWeight: unread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _formatDate(conversation.lastMessageCreatedAt),
                            style: VibraTextStyles.bodySmall.copyWith(
                              color: unread ? t.textPrimary : t.textSecondary,
                              fontWeight: unread
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.lastMessageContent,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: VibraTextStyles.bodyMedium.copyWith(
                                color: unread ? t.textPrimary : t.textSecondary,
                                fontWeight: unread
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (unread) ...[
                            const SizedBox(width: 10),
                            const _UnreadDot(),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (_deleting.contains(conversation.otherUserId)) ...[
                  const SizedBox(width: 10),
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<ConversationSummary> _filter(List<ConversationSummary> conversations) {
    if (_searchQuery.isEmpty && !_unreadOnly) return conversations;
    return conversations.where((conversation) {
      if (_unreadOnly && conversation.unreadCount == 0) return false;
      return conversation.effectiveDisplayName.toLowerCase().contains(
            _searchQuery,
          ) ||
          conversation.otherUsername.toLowerCase().contains(_searchQuery) ||
          conversation.lastMessageContent.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(conversationsStatusProvider);
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final allDirect = ref.watch(directConversationsProvider);
    final allRequests = ref.watch(messageRequestsProvider);
    final direct = _filter(allDirect);
    final requests = _filter(allRequests);
    final unreadCount = [
      ...allDirect,
      ...allRequests,
    ].where((conversation) => conversation.unreadCount > 0).length;
    final filtering = _searchQuery.isNotEmpty || _unreadOnly;
    final noResults = _InboxEmpty(
      title: l10n.inboxNoResults,
      body: l10n.inboxNoResultsBody,
      action: l10n.inboxClearFilters,
      onAction: _clearFilters,
    );

    return VibraPageScaffold(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 16, 0),
            child: Row(
              children: [
                if (widget.showBackButton)
                  BackButton(onPressed: () => context.pop()),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.inboxEyebrow,
                        style: VibraTextStyles.labelSmall.copyWith(
                          color: t.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        AppLocalizations.of(context)!.inboxMessages,
                        style: VibraTextStyles.displaySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.group_outlined),
                  tooltip: AppLocalizations.of(context)!.friendsTitle,
                  onPressed: () => context.push('/friends'),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: SizedBox(
              height: 36,
              child: TabBar(
                controller: _tabController,
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                indicatorWeight: 4,
                labelPadding: const EdgeInsets.only(right: 24),
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.inboxDirect),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(AppLocalizations.of(context)!.inboxRequests),
                        if (allRequests.isNotEmpty) ...[
                          const SizedBox(width: 7),
                          const _UnreadDot(),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: VibraInput(
              controller: _searchController,
              hintText: AppLocalizations.of(context)!.inboxSearchHint,
              prefixIcon: Icons.search_rounded,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
              onChanged: (value) =>
                  setState(() => _searchQuery = value.trim().toLowerCase()),
              suffix: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: AppLocalizations.of(context)!.inboxClearSearch,
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilterChip(
                label: Text('${l10n.inboxUnread} ($unreadCount)'),
                selected: _unreadOnly,
                onSelected: (selected) =>
                    setState(() => _unreadOnly = selected),
              ),
            ),
          ),
          if (status.isLoading) const LinearProgressIndicator(),
          if (status.hasError)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.inboxRefreshError,
                      style: TextStyle(color: t.error),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        ref.read(conversationsProvider.notifier).refresh(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ConversationList(
                  conversations: direct,
                  empty: filtering
                      ? noResults
                      : _InboxEmpty(
                          title: AppLocalizations.of(context)!.inboxEmptyTitle,
                          body: AppLocalizations.of(context)!.inboxEmptyBody,
                          action: AppLocalizations.of(
                            context,
                          )!.friendsFindPeople,
                          onAction: () => context.push('/social'),
                        ),
                  onRefresh: () =>
                      ref.read(conversationsProvider.notifier).refresh(),
                  rowBuilder: _conversationRow,
                ),
                _ConversationList(
                  conversations: requests,
                  empty: filtering
                      ? noResults
                      : _InboxEmpty(
                          title: AppLocalizations.of(context)!.inboxNoRequests,
                          body: AppLocalizations.of(
                            context,
                          )!.inboxNoRequestsBody,
                        ),
                  onRefresh: () =>
                      ref.read(conversationsProvider.notifier).refresh(),
                  rowBuilder: _conversationRow,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({
    required this.conversations,
    required this.empty,
    required this.onRefresh,
    required this.rowBuilder,
  });

  final List<ConversationSummary> conversations;
  final Widget empty;
  final Future<void> Function() onRefresh;
  final Widget Function(ConversationSummary) rowBuilder;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: conversations.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 42, 20, 132),
              children: [empty],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(top: 10, bottom: 132),
              itemCount: conversations.length,
              itemBuilder: (context, index) =>
                  rowBuilder(conversations[index]).animate().fadeIn(
                    delay: Duration(milliseconds: index * 45),
                    duration: 260.ms,
                  ),
            ),
    );
  }
}

class _InboxEmpty extends StatelessWidget {
  const _InboxEmpty({
    required this.title,
    required this.body,
    this.action,
    this.onAction,
  });

  final String title;
  final String body;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return VibraSurface(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: VibraSignalWave(
              height: 35,
              color: t.accentPrimary,
              secondaryColor: t.textPrimary,
              amplitude: 7,
              animate: true,
            ),
          ),
          const SizedBox(height: 15),
          Text(title, style: VibraTextStyles.headlineMedium),
          const SizedBox(height: 6),
          Text(body, style: VibraTextStyles.bodySmall),
          if (action != null && onAction != null) ...[
            const SizedBox(height: 18),
            VibraButton(
              label: action!,
              tone: VibraButtonTone.signal,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return SizedBox(
      width: 8,
      height: 8,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.accentPrimary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
