import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/vibra_motion.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/direct_message.dart';
import '../../../domain/entities/direct_message_permission.dart';
import '../../../core/errors/exceptions.dart' as app_errors;
import '../../../domain/usecases/social_usecases.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/direct_message_permission_provider.dart';
import '../../providers/usecase_providers.dart';
import '../../widgets/common/vibra_input.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/common/vibra_avatar.dart';
import '../../../core/utils/logger.dart';
import '../../../core/config/env_config.dart';
import '../../../core/services/private_media_url.dart';
import 'package:vibra/l10n/app_localizations.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String otherUserId;
  final String otherDisplayName;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherDisplayName,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _composerFocus = FocusNode();
  final Map<String, DirectMessage> _pendingMessages = {};
  List<DirectMessage> _messages = [];
  bool _isLoading = true;
  bool _hasLoadError = false;
  bool _isSending = false;
  bool _isRequestingFriendship = false;

  String get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  StreamSubscription<List<DirectMessage>>? _subscription;
  int _subscriptionGeneration = 0;
  int _conversationGeneration = 0;
  Future<void>? _markReadInFlight;

  @override
  void initState() {
    super.initState();
    _subscribeMessages();
  }

  @override
  void dispose() {
    _subscriptionGeneration++;
    _conversationGeneration++;
    _controller.dispose();
    _composerFocus.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.otherUserId != widget.otherUserId) {
      _conversationGeneration++;
      _messages = [];
      _pendingMessages.clear();
      _controller.clear();
      _isSending = false;
      _isRequestingFriendship = false;
      _markReadInFlight = null;
      _subscribeMessages();
    }
  }

  Future<void> _subscribeMessages() async {
    final generation = ++_subscriptionGeneration;
    setState(() {
      _isLoading = true;
      _hasLoadError = false;
    });
    unawaited(_subscription?.cancel());

    try {
      final stream = await ref
          .read(streamConversationUseCaseProvider)
          .call(widget.otherUserId);
      if (!mounted || generation != _subscriptionGeneration) return;
      _subscription = stream.listen(
        (messages) {
          if (mounted && generation == _subscriptionGeneration) {
            setState(() {
              _messages = [..._pendingMessages.values, ...messages];
              _isLoading = false;
              _hasLoadError = false;
            });
            if (messages.any(
              (message) =>
                  message.senderId == widget.otherUserId &&
                  message.readAt == null,
            )) {
              unawaited(_markRead());
            }
            ref.invalidate(directMessagePermissionProvider(widget.otherUserId));
          }
        },
        onError: (error) {
          VibraLogger.error('Errore realtime chat stream', error: error);
          if (mounted && generation == _subscriptionGeneration) {
            setState(() {
              _isLoading = false;
              _hasLoadError = true;
            });
          }
        },
      );
    } catch (_) {
      if (mounted && generation == _subscriptionGeneration) {
        setState(() {
          _isLoading = false;
          _hasLoadError = true;
        });
      }
    }
  }

  Future<void> _markRead() {
    final existing = _markReadInFlight;
    if (existing != null) return existing;
    late final Future<void> operation;
    operation = _performMarkRead().whenComplete(() {
      // An older conversation finishing must not unlock its successor's read.
      if (identical(_markReadInFlight, operation)) _markReadInFlight = null;
    });
    return _markReadInFlight = operation;
  }

  Future<void> _performMarkRead() async {
    try {
      await ref
          .read(markMessagesAsReadUseCaseProvider)
          .call(widget.otherUserId);
      if (!mounted) return;
      await ref.read(conversationsProvider.notifier).refresh();
    } catch (error) {
      VibraLogger.warning('Unable to mark conversation as read: $error');
    }
  }

  Future<void> _sendMessage({String? content}) async {
    final text = (content ?? _controller.text).trim();
    if (text.isEmpty || _isSending) return;
    if (text.length > 2000) {
      _showError(AppLocalizations.of(context)!.chatMessageTooLong);
      return;
    }
    final permission = ref.read(
      directMessagePermissionProvider(widget.otherUserId),
    );
    if (permission.isLoading || permission.hasError) return;
    if (permission.valueOrNull?.canSend != true) {
      _showError(_permissionMessage(permission.valueOrNull));
      return;
    }
    final receiverId = widget.otherUserId;
    final conversationGeneration = _conversationGeneration;
    setState(() => _isSending = true);
    if (content == null) _controller.clear();

    // Optimistic UI — add immediately
    final optimistic = DirectMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _currentUserId,
      receiverId: widget.otherUserId,
      content: text,
      createdAt: DateTime.now(),
    );
    _pendingMessages[optimistic.id] = optimistic;
    setState(() => _messages = [optimistic, ..._messages]);

    try {
      final sent = await ref
          .read(sendDirectMessageUseCaseProvider)
          .call(SendDirectMessageParams(receiverId: receiverId, content: text));
      if (!mounted ||
          conversationGeneration != _conversationGeneration ||
          receiverId != widget.otherUserId) {
        return;
      }
      _pendingMessages.remove(optimistic.id);
      setState(() {
        _messages = _messages
            .where((message) => message.id != optimistic.id)
            .toList();
        if (!_messages.any((message) => message.id == sent.id)) {
          _messages.insert(0, sent);
        }
      });
      ref.read(conversationsProvider.notifier).refresh();
      ref.invalidate(directMessagePermissionProvider(receiverId));
    } catch (error) {
      if (mounted &&
          conversationGeneration == _conversationGeneration &&
          receiverId == widget.otherUserId) {
        _pendingMessages.remove(optimistic.id);
        setState(() {
          _messages = _messages.where((m) => m.id != optimistic.id).toList();
        });
        // Preserve both the failed message and any draft typed during the request.
        final draft = _controller.text;
        _controller.text = draft.isEmpty ? text : '$text\n\n$draft';
        _controller.selection = TextSelection.collapsed(
          offset: _controller.text.length,
        );
        final l10n = AppLocalizations.of(context)!;
        final reason = error is DirectMessageSendException
            ? _permissionMessage(error.permission)
            : error is app_errors.AuthException ||
                  error is PostgrestException && error.code == 'PT401'
            ? l10n.chatSendSignInRequired
            : '';
        _showError(
          reason.isEmpty
              ? l10n.chatDraftRecovered
              : '$reason ${l10n.chatDraftRecovered}',
        );
        ref.invalidate(directMessagePermissionProvider(receiverId));
      }
    } finally {
      if (mounted &&
          conversationGeneration == _conversationGeneration &&
          receiverId == widget.otherUserId) {
        setState(() => _isSending = false);
      }
    }
  }

  String _permissionMessage(DirectMessagePermission? permission) {
    final l10n = AppLocalizations.of(context)!;
    return switch (permission) {
      DirectMessagePermission.friendshipRequired =>
        l10n.chatSendFriendshipRequired,
      DirectMessagePermission.awaitingReply => l10n.chatSendFirstContactLimit,
      DirectMessagePermission.rateLimited => l10n.chatSendRateLimited,
      _ => l10n.chatSendUnavailable,
    };
  }

  Future<void> _requestFriendship({String? incomingFriendshipId}) async {
    if (_isRequestingFriendship) return;
    final receiverId = widget.otherUserId;
    final generation = _conversationGeneration;
    setState(() => _isRequestingFriendship = true);
    try {
      if (incomingFriendshipId != null) {
        await ref
            .read(pendingFriendshipsProvider.notifier)
            .acceptFriendRequest(incomingFriendshipId);
      } else {
        await ref.read(requestFriendshipUseCaseProvider).call(receiverId);
        await ref.read(pendingFriendshipsProvider.notifier).refresh();
      }
      if (!mounted || generation != _conversationGeneration) return;
      ref.invalidate(userProfileDetailProvider(receiverId));
      ref.invalidate(directMessagePermissionProvider(receiverId));
      final l10n = AppLocalizations.of(context)!;
      _showError(
        incomingFriendshipId == null
            ? l10n.chatFriendshipRequestSent
            : l10n.chatFriendshipAccepted,
      );
    } catch (_) {
      if (mounted && generation == _conversationGeneration) {
        _showError(AppLocalizations.of(context)!.chatFriendshipRequestFailed);
      }
    } finally {
      if (mounted && generation == _conversationGeneration) {
        setState(() => _isRequestingFriendship = false);
      }
    }
  }

  Widget _buildPermissionBanner(
    AsyncValue<DirectMessagePermission> permission,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (!permission.isLoading &&
        !permission.hasError &&
        permission.valueOrNull?.canSend == true) {
      return const SizedBox.shrink();
    }
    final pending = ref.watch(pendingFriendshipsProvider);
    final outgoing = pending.any(
      (f) =>
          f.requesterId == _currentUserId && f.receiverId == widget.otherUserId,
    );
    final incoming = pending
        .where(
          (f) =>
              f.receiverId == _currentUserId &&
              f.requesterId == widget.otherUserId,
        )
        .firstOrNull;
    final requiresFriendship =
        !permission.isLoading &&
        !permission.hasError &&
        permission.valueOrNull == DirectMessagePermission.friendshipRequired;
    final message = permission.isLoading
        ? l10n.chatPermissionChecking
        : permission.hasError
        ? permission.error is app_errors.AuthException ||
                  permission.error is PostgrestException &&
                      (permission.error as PostgrestException).code == 'PT401'
              ? l10n.chatSendSignInRequired
              : l10n.chatLoadError
        : requiresFriendship && outgoing
        ? l10n.chatFriendshipRequestPending
        : _permissionMessage(permission.valueOrNull);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(message, style: Theme.of(context).textTheme.bodySmall),
          if (!permission.isLoading)
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.end,
              children: [
                TextButton(
                  onPressed: () => ref.invalidate(
                    directMessagePermissionProvider(widget.otherUserId),
                  ),
                  child: Text(l10n.commonRetry),
                ),
                if (requiresFriendship && !outgoing)
                  FilledButton.tonal(
                    onPressed: _isRequestingFriendship
                        ? null
                        : () => _requestFriendship(
                            incomingFriendshipId: incoming?.id,
                          ),
                    child: Text(
                      incoming == null
                          ? l10n.chatRequestFriendship
                          : l10n.chatAcceptFriendship,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showReportDialog() {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    String selectedReason = 'spam';
    final descController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: t.surfaceElevated,
        title: Text(l10n.socialReportUser),
        scrollable: true,
        content: StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedReason,
                  dropdownColor: t.surfaceElevated,
                  style: TextStyle(color: t.textPrimary),
                  items: [
                    DropdownMenuItem(
                      value: 'spam',
                      child: Text(l10n.socialReportSpam),
                    ),
                    DropdownMenuItem(
                      value: 'harassment',
                      child: Text(l10n.socialReportHarassment),
                    ),
                    DropdownMenuItem(
                      value: 'inappropriate',
                      child: Text(l10n.socialReportInappropriate),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedReason = val);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  style: TextStyle(color: t.textPrimary),
                  decoration: InputDecoration(
                    hintText: l10n.socialReportDetailsHint,
                    hintStyle: TextStyle(color: t.textSecondary),
                    filled: true,
                    fillColor: t.surfaceMuted,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        VibraSpacing.radiusMedium,
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () async {
              final description = descController.text;
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(reportUserUseCaseProvider)
                    .call(
                      ReportUserParams(
                        reportedId: widget.otherUserId,
                        reason: selectedReason,
                        description: description,
                      ),
                    );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.socialReportSent)),
                  );
                }
              } catch (_) {
                _showError(l10n.socialReportFailed);
              }
            },
            child: Text(l10n.socialReportAction),
          ),
        ],
      ),
    ).whenComplete(descController.dispose);
  }

  void _showBlockDialog() {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: t.surfaceElevated,
        title: Text(l10n.socialBlockUser),
        content: Text(
          l10n.socialBlockConfirm,
          style: TextStyle(color: t.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: t.error,
              foregroundColor: t.onAccent,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(blockUserUseCaseProvider)
                    .call(widget.otherUserId);
                if (mounted) {
                  ref.invalidate(matchedUsersProvider);
                  ref.invalidate(pendingFriendshipsProvider);
                  ref.invalidate(userProfileDetailProvider(widget.otherUserId));
                  await ref.read(conversationsProvider.notifier).refresh();
                  if (!mounted) return;
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n.socialBlockSuccess)),
                  );
                }
              } catch (_) {
                _showError(l10n.socialBlockFailed);
              }
            },
            child: Text(l10n.socialBlockAction),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageRequestBanner(DirectMessagePermission? permission) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final friends = ref.watch(friendsProvider);
    final isFriend =
        permission == DirectMessagePermission.friends ||
        friends.any((f) => f.user.id == widget.otherUserId);
    final hasIncomingMessages = _messages.any(
      (m) => m.senderId == widget.otherUserId,
    );
    final hasReplied = _messages.any(
      (message) => message.receiverId == widget.otherUserId,
    );
    final isMessageRequest = !isFriend && hasIncomingMessages && !hasReplied;

    if (!isMessageRequest) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.surfaceElevated,
        borderRadius: VibraSpacing.borderMedium,
        border: Border.all(color: t.borderDefault),
        boxShadow: [t.cardShadow],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: t.accentFill,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_unread_rounded,
                  color: t.onAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.chatRequestTitle,
                      style: TextStyle(
                        color: t.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.chatRequestBody(widget.otherDisplayName),
                      style: TextStyle(color: t.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 4,
            children: [
              TextButton(
                onPressed: _showBlockDialog,
                style: TextButton.styleFrom(foregroundColor: t.error),
                child: Text(l10n.socialBlockAction),
              ),
              OutlinedButton(
                onPressed: () async {
                  try {
                    await ref
                        .read(softDeleteChatUseCaseProvider)
                        .call(widget.otherUserId);
                    if (!mounted) return;
                    await ref.read(conversationsProvider.notifier).refresh();
                    if (!mounted) return;
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.chatRequestRejected)),
                    );
                  } catch (_) {
                    _showError(l10n.chatRequestRejectFailed);
                  }
                },
                child: Text(l10n.commonReject),
              ),
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor: t.accentSecondary,
                  foregroundColor: t.onAccent,
                ),
                onPressed: _composerFocus.requestFocus,
                child: Text(
                  l10n.commonReply,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final permission = ref.watch(
      directMessagePermissionProvider(widget.otherUserId),
    );
    final canSend =
        !permission.isLoading &&
        !permission.hasError &&
        permission.valueOrNull?.canSend == true;
    final online = ref.watch(
      presenceProvider.select((map) => map[widget.otherUserId] == 'online'),
    );
    final composer = Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.backgroundPrimary,
          border: Border(top: BorderSide(color: t.borderDefault, width: .5)),
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: VibraSpacing.md),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              VibraSpacing.md,
              VibraSpacing.sm,
              VibraSpacing.md,
              0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: VibraInput(
                    controller: _controller,
                    focusNode: _composerFocus,
                    maxLength: 2000,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    hintText: AppLocalizations.of(context)!.chatInputHint,
                  ),
                ),
                const SizedBox(width: VibraSpacing.sm),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) {
                    final enabled =
                        canSend && !_isSending && value.text.trim().isNotEmpty;
                    return AnimatedContainer(
                      duration: VibraMotion.durationFor(
                        context,
                        VibraMotion.fast,
                      ),
                      margin: const EdgeInsets.only(bottom: 2),
                      decoration: BoxDecoration(
                        color: enabled || _isSending
                            ? t.accentFill
                            : t.surfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        tooltip: AppLocalizations.of(context)!.chatSendMessage,
                        onPressed: enabled ? _sendMessage : null,
                        icon: _isSending
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: t.onAccent,
                                ),
                              )
                            : Icon(
                                Icons.arrow_upward_rounded,
                                color: enabled ? t.onAccent : t.textMuted,
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return VibraPageScaffold(
      useGradient: false,
      bottomNavigationBar: composer,
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          borderRadius: VibraSpacing.borderSmall,
          onTap: () => context.push('/user-profile', extra: widget.otherUserId),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                VibraAvatar(
                  name: widget.otherDisplayName,
                  radius: 18,
                  active: online,
                ),
                const SizedBox(width: VibraSpacing.md),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.otherDisplayName,
                        overflow: TextOverflow.ellipsis,
                        style: VibraTextStyles.titleMedium.copyWith(
                          color: t.textPrimary,
                        ),
                      ),
                      if (online)
                        Text(
                          l10n.commonOnline,
                          style: VibraTextStyles.caption.copyWith(
                            color: t.success,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: l10n.userProfileView,
            onPressed: () =>
                context.push('/user-profile', extra: widget.otherUserId),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'report') {
                _showReportDialog();
              } else if (value == 'block') {
                _showBlockDialog();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    const Icon(Icons.flag_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(l10n.socialReportUser),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block_rounded, size: 20, color: t.error),
                    const SizedBox(width: 8),
                    Text(
                      l10n.socialBlockUser,
                      style: TextStyle(color: t.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPermissionBanner(permission),
          _buildMessageRequestBanner(permission.valueOrNull),
          if (_hasLoadError && _messages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.chatConnectionInterrupted,
                      style: TextStyle(color: t.error),
                    ),
                  ),
                  TextButton(
                    onPressed: _subscribeMessages,
                    child: Text(AppLocalizations.of(context)!.commonRetry),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: VibraLoadingIndicator())
                : _hasLoadError && _messages.isEmpty
                ? SingleChildScrollView(
                    child: VibraEmptyView(
                      title: AppLocalizations.of(context)!.chatLoadError,
                      message: AppLocalizations.of(context)!.commonRetry,
                      icon: Icons.cloud_off_rounded,
                      actionLabel: AppLocalizations.of(context)!.commonRetry,
                      onActionTap: _subscribeMessages,
                    ),
                  )
                : _messages.isEmpty
                ? SingleChildScrollView(
                    child: VibraEmptyView(
                      title: AppLocalizations.of(context)!.chatEmptyTitle,
                      message: AppLocalizations.of(context)!.chatEmptyMessage,
                      icon: Icons.chat_bubble_rounded,
                    ),
                  )
                : ListView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    reverse: true,
                    padding: EdgeInsets.fromLTRB(
                      VibraSpacing.pagePadding,
                      20,
                      VibraSpacing.pagePadding,
                      12,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final mine = message.senderId == _currentUserId;
                      // The list is reversed: index - 1 is the next message
                      // in time, index + 1 the previous one.
                      final newer = index > 0 ? _messages[index - 1] : null;
                      final older = index + 1 < _messages.length
                          ? _messages[index + 1]
                          : null;
                      final created = message.createdAt?.toLocal();
                      final groupedWithNewer =
                          newer != null &&
                          newer.senderId == message.senderId &&
                          _sameMinuteWindow(created, newer.createdAt);
                      final showDay =
                          created != null &&
                          (older?.createdAt == null ||
                              !_sameDay(created, older!.createdAt!.toLocal()));
                      final timeString = created != null
                          ? DateFormat.Hm(
                              Localizations.localeOf(context).toString(),
                            ).format(created)
                          : '';
                      final tail = Radius.circular(
                        groupedWithNewer
                            ? VibraSpacing.radiusLarge
                            : VibraSpacing.xs + 2,
                      );
                      const round = Radius.circular(VibraSpacing.radiusLarge);

                      Widget bubble = Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width * .76,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: mine ? t.accentFill : t.surfaceElevated,
                          borderRadius: BorderRadius.only(
                            topLeft: round,
                            topRight: round,
                            bottomLeft: mine ? round : tail,
                            bottomRight: mine ? tail : round,
                          ),
                        ),
                        child: _buildMessageContent(message, theme, mine),
                      );
                      if (index == 0) {
                        bubble = _BubbleEntrance(
                          key: ValueKey(message.id),
                          fromRight: mine,
                          child: bubble,
                        );
                      }

                      return Column(
                        crossAxisAlignment: mine
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (showDay) _DaySeparator(date: created),
                          bubble,
                          if (!groupedWithNewer)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                4,
                                4,
                                4,
                                VibraSpacing.md,
                              ),
                              child: Text(
                                timeString,
                                style: VibraTextStyles.caption.copyWith(
                                  color: t.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 3),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _sameMinuteWindow(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return b.toLocal().difference(a).inMinutes.abs() < 3;
  }

  Widget _buildMessageContent(
    DirectMessage message,
    ThemeData theme,
    bool mine,
  ) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final messageColor = mine ? t.onAccent : t.textPrimary;
    if (message.messageType == 'image' &&
        message.metadata != null &&
        message.metadata!['url'] != null) {
      final mediaUrl = message.metadata!['url'];
      if (mediaUrl is! String) {
        return const Icon(Icons.broken_image_rounded);
      }
      final uri = privateChatMediaUri(mediaUrl, EnvConfig.supabaseUrl);
      final token = Supabase.instance.client.auth.currentSession?.accessToken;
      if (uri == null || token == null) {
        return const Icon(Icons.broken_image_rounded);
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          uri.toString(),
          headers: {
            'Authorization': 'Bearer $token',
            'apikey': EnvConfig.supabaseAnonKey,
          },
          fit: BoxFit.cover,
          cacheWidth: 600,
          loadingBuilder: (context, child, progress) =>
              progress == null ? child : Container(color: t.surfaceMuted),
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(Icons.broken_image_rounded, color: t.textSecondary),
          ),
        ),
      );
    }

    if (message.messageType == 'meetup_proposal') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_rounded,
                color: mine ? t.onAccent : t.accentPrimary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  l10n.chatMeetupTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: messageColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            message.content,
            style: theme.textTheme.bodyMedium?.copyWith(color: messageColor),
          ),
          const SizedBox(height: 12),
          if (!mine)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                  ),
                  onPressed: _isSending
                      ? null
                      : () => _sendMessage(
                          content: l10n.chatMeetupAcceptMessage(
                            message.content,
                          ),
                        ),
                  child: Text(l10n.chatMeetupAccept),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                  ),
                  onPressed: _isSending
                      ? null
                      : () => _sendMessage(
                          content: l10n.chatMeetupDeclineMessage(
                            message.content,
                          ),
                        ),
                  child: Text(l10n.chatMeetupDecline),
                ),
              ],
            ),
        ],
      );
    }

    return Text(
      message.content,
      style: VibraTextStyles.bodyMedium.copyWith(
        color: messageColor,
        height: 1.4,
      ),
    );
  }
}

class _DaySeparator extends StatelessWidget {
  const _DaySeparator({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final label = day == today
        ? AppLocalizations.of(context)!.eventStatusToday
        : DateFormat.yMMMEd(
            Localizations.localeOf(context).toString(),
          ).format(date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VibraSpacing.md),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: VibraSpacing.borderFull,
          ),
          child: Text(
            label,
            style: VibraTextStyles.caption.copyWith(color: t.textSecondary),
          ),
        ),
      ),
    );
  }
}

/// Newest message entrance: fade + short rise towards its side. Native tween,
/// no timers; static under reduced motion.
class _BubbleEntrance extends StatelessWidget {
  const _BubbleEntrance({
    required this.child,
    required this.fromRight,
    super.key,
  });

  final Widget child;
  final bool fromRight;

  @override
  Widget build(BuildContext context) {
    final duration = VibraMotion.durationFor(context, VibraMotion.medium);
    if (duration == Duration.zero) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: VibraMotion.signalCurve,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset((fromRight ? 12 : -12) * (1 - v), 10 * (1 - v)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
