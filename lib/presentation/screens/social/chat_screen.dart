import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/direct_message.dart';
import '../../../domain/usecases/social_usecases.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/usecase_providers.dart';
import '../../widgets/common/vibra_input.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/vibra_signal_wave.dart';
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
  List<DirectMessage> _messages = [];
  bool _isLoading = true;
  bool _hasLoadError = false;
  bool _isSending = false;

  String get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  StreamSubscription<List<DirectMessage>>? _subscription;
  int _subscriptionGeneration = 0;

  @override
  void initState() {
    super.initState();
    _subscribeMessages();
  }

  @override
  void dispose() {
    _controller.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _subscribeMessages() async {
    final generation = ++_subscriptionGeneration;
    setState(() {
      _isLoading = true;
      _hasLoadError = false;
    });
    unawaited(_subscription?.cancel());
    _markRead();

    try {
      final stream = await ref
          .read(streamConversationUseCaseProvider)
          .call(widget.otherUserId);
      if (!mounted || generation != _subscriptionGeneration) return;
      _subscription = stream.listen(
        (messages) {
          if (mounted && generation == _subscriptionGeneration) {
            setState(() {
              _messages = messages;
              _isLoading = false;
              _hasLoadError = false;
            });
            _markRead();
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

  Future<void> _markRead() async {
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

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    _controller.clear();

    // Optimistic UI — add immediately
    final optimistic = DirectMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _currentUserId,
      receiverId: widget.otherUserId,
      content: text,
      createdAt: DateTime.now(),
    );
    setState(() => _messages = [optimistic, ..._messages]);

    try {
      final sent = await ref
          .read(sendDirectMessageUseCaseProvider)
          .call(
            SendDirectMessageParams(
              receiverId: widget.otherUserId,
              content: text,
            ),
          );
      if (!mounted) return;
      setState(() {
        _messages = _messages
            .where((message) => message.id != optimistic.id)
            .toList();
        if (!_messages.any((message) => message.id == sent.id)) {
          _messages.insert(0, sent);
        }
      });
      ref.read(conversationsProvider.notifier).refresh();
    } catch (_) {
      if (mounted) {
        setState(() {
          _messages = _messages.where((m) => m.id != optimistic.id).toList();
        });
        // Preserve both the failed message and any draft typed during the request.
        final draft = _controller.text;
        _controller.text = draft.isEmpty ? text : '$text\n\n$draft';
        _controller.selection = TextSelection.collapsed(
          offset: _controller.text.length,
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.chatDraftRecovered),
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showReportDialog() {
    final t = context.vibraTokens;
    String selectedReason = 'spam';
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: t.surfaceElevated,
        title: const Text('Segnala Utente'),
        content: StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedReason,
                  dropdownColor: t.surfaceElevated,
                  style: TextStyle(color: t.textPrimary),
                  items: const [
                    DropdownMenuItem(value: 'spam', child: Text('Spam')),
                    DropdownMenuItem(
                      value: 'harassment',
                      child: Text('Molestie'),
                    ),
                    DropdownMenuItem(
                      value: 'inappropriate',
                      child: Text('Contenuto Inappropriato'),
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
                    hintText: 'Dettagli aggiuntivi (opzionale)',
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
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(reportUserUseCaseProvider)
                    .call(
                      ReportUserParams(
                        reportedId: widget.otherUserId,
                        reason: selectedReason,
                        description: descController.text,
                      ),
                    );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Utente segnalato con successo'),
                    ),
                  );
                }
              } catch (_) {}
            },
            child: const Text('Segnala'),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog() {
    final t = context.vibraTokens;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: t.surfaceElevated,
        title: const Text('Blocca Utente'),
        content: Text(
          'Sei sicuro di voler bloccare questo utente? Non potrete più scambiarvi messaggi.',
          style: TextStyle(color: t.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annulla'),
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
                  if (context.mounted) Navigator.pop(context); // Close chat
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Utente bloccato')),
                    );
                  }
                }
              } catch (_) {}
            },
            child: const Text('Blocca'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageRequestBanner() {
    final t = context.vibraTokens;
    final friends = ref.watch(friendsProvider);
    final isFriend = friends.any((f) => f.user.id == widget.otherUserId);
    final hasIncomingMessages = _messages.any(
      (m) => m.senderId == widget.otherUserId,
    );
    final isMessageRequest = !isFriend && hasIncomingMessages;

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
                  color: t.accentPrimary,
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
                      'Richiesta di messaggio',
                      style: TextStyle(
                        color: t.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.otherDisplayName} vorrebbe messaggiare con te. Vuoi accettare la richiesta o connetterti?',
                      style: TextStyle(color: t.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _showBlockDialog,
                style: TextButton.styleFrom(foregroundColor: t.error),
                child: const Text('Blocca'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () async {
                  await ref
                      .read(softDeleteChatUseCaseProvider)
                      .call(widget.otherUserId);
                  if (mounted && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Richiesta rifiutata ed eliminata'),
                      ),
                    );
                  }
                },
                child: const Text('Rifiuta'),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor: t.accentSecondary,
                  foregroundColor: t.onAccent,
                ),
                onPressed: () async {
                  try {
                    await ref
                        .read(requestFriendshipUseCaseProvider)
                        .call(widget.otherUserId);
                    ref.invalidate(matchedUsersProvider);
                    ref.invalidate(conversationsProvider);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Richiesta accettata!')),
                      );
                    }
                  } catch (_) {}
                },
                child: const Text(
                  'Accetta',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
    return VibraPageScaffold(
      appBar: AppBar(
        title: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.push('/user-profile', extra: widget.otherUserId),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  height: 18,
                  child: VibraSignalWave(
                    color: t.textPrimary,
                    secondaryColor: t.accentPrimary,
                    strokeWidth: 1.4,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.otherDisplayName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: t.textSecondary,
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Vedi profilo',
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
                    const Text('Segnala Utente'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block_rounded, size: 20, color: t.error),
                    const SizedBox(width: 8),
                    Text('Blocca Utente', style: TextStyle(color: t.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMessageRequestBanner(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
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
                      final timeString = message.createdAt != null
                          ? DateFormat(
                              'HH:mm',
                            ).format(message.createdAt!.toLocal())
                          : '';

                      return Align(
                        alignment: mine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: mine
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 280,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: mine
                                        ? t.accentPrimary
                                        : t.surfaceElevated,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(
                                        VibraSpacing.radiusLarge,
                                      ),
                                      topRight: Radius.circular(
                                        VibraSpacing.radiusLarge,
                                      ),
                                      bottomLeft: Radius.circular(
                                        mine
                                            ? VibraSpacing.radiusLarge
                                            : VibraSpacing.radiusSmall,
                                      ),
                                      bottomRight: Radius.circular(
                                        mine
                                            ? VibraSpacing.radiusSmall
                                            : VibraSpacing.radiusLarge,
                                      ),
                                    ),
                                    border: mine
                                        ? null
                                        : Border.all(color: t.borderDefault),
                                  ),
                                  child: _buildMessageContent(
                                    message,
                                    theme,
                                    mine,
                                  ),
                                )
                                .animate()
                                .fadeIn(duration: 300.ms)
                                .slideY(
                                  begin: 0.08,
                                  end: 0,
                                  curve: Curves.easeOutQuad,
                                ),
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 10,
                                left: 4,
                                right: 4,
                              ),
                              child: Text(
                                timeString,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: t.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              VibraSpacing.pagePadding,
              8,
              VibraSpacing.pagePadding,
              24,
            ),
            child: Row(
              children: [
                Expanded(
                  child: VibraInput(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    hintText: AppLocalizations.of(context)!.chatInputHint,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: t.accentPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (context, value, _) => IconButton(
                      tooltip: AppLocalizations.of(context)!.chatSendMessage,
                      onPressed: _isSending || value.text.trim().isEmpty
                          ? null
                          : _sendMessage,
                      icon: _isSending
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: t.onAccent,
                              ),
                            )
                          : Icon(Icons.send_rounded, color: t.onAccent),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(
    DirectMessage message,
    ThemeData theme,
    bool mine,
  ) {
    final t = context.vibraTokens;
    final messageColor = mine ? t.onAccent : t.textPrimary;
    if (message.messageType == 'image' &&
        message.metadata != null &&
        message.metadata!['url'] != null) {
      final uri = privateChatMediaUri(
        message.metadata!['url'] as String,
        EnvConfig.supabaseUrl,
      );
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
              Text(
                'Proposta di Incontro',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: messageColor,
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () {},
                  child: const Text('Ci Sto'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () {},
                  child: const Text('Non Posso'),
                ),
              ],
            ),
        ],
      );
    }

    return Text(
      message.content,
      style: theme.textTheme.bodyMedium?.copyWith(color: messageColor),
    );
  }
}
