import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/vibra_colors.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../domain/entities/direct_message.dart';
import '../../../domain/usecases/social_usecases.dart';
import '../../providers/usecase_providers.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../../core/utils/logger.dart';
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

  String get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  StreamSubscription<List<DirectMessage>>? _subscription;

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
    try {
      final stream = await ref
          .read(streamConversationUseCaseProvider)
          .call(widget.otherUserId);
      _subscription = stream.listen(
        (messages) {
          if (mounted) {
            setState(() {
              _messages = messages;
              _isLoading = false;
            });
          }
        },
        onError: (error) {
          VibraLogger.error('Errore realtime chat stream', error: error);
          if (mounted) {
            setState(() => _isLoading = false);
          }
        },
      );
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
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
      await ref
          .read(sendDirectMessageUseCaseProvider)
          .call(
            SendDirectMessageParams(
              receiverId: widget.otherUserId,
              content: text,
            ),
          );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.chatSendFailed)),
        );
      }
    }
  }

  void _showReportDialog() {
    String selectedReason = 'spam';
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: VibraColors.surfaceElevated,
        title: const Text(
          'Segnala Utente',
          style: TextStyle(color: VibraColors.textPrimary),
        ),
        content: StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedReason,
                  dropdownColor: VibraColors.surfaceVariant,
                  style: const TextStyle(color: VibraColors.textPrimary),
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
                  style: const TextStyle(color: VibraColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Dettagli aggiuntivi (opzionale)',
                    hintStyle: const TextStyle(
                      color: VibraColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: VibraColors.surfaceVariant,
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
            onPressed: () => Navigator.pop(context),
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
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: VibraColors.surfaceElevated,
        title: const Text(
          'Blocca Utente',
          style: TextStyle(color: VibraColors.textPrimary),
        ),
        content: const Text(
          'Sei sicuro di voler bloccare questo utente? Non potrete più scambiarvi messaggi.',
          style: TextStyle(color: VibraColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annulla'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: VibraColors.error),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return VibraPageScaffold(
      appBar: AppBar(
        title: Text(widget.otherDisplayName),
        actions: [
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
                    const Icon(
                      Icons.block_rounded,
                      size: 20,
                      color: VibraColors.error,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Blocca Utente',
                      style: TextStyle(color: VibraColors.error),
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
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? VibraEmptyView(
                    title: AppLocalizations.of(context)!.chatEmptyTitle,
                    message: AppLocalizations.of(context)!.chatEmptyMessage,
                    icon: Icons.chat_bubble_rounded,
                  )
                : ListView.builder(
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
                                    gradient: mine
                                        ? LinearGradient(
                                            colors: [
                                              VibraColors.primary,
                                              VibraColors.accent,
                                            ],
                                          )
                                        : null,
                                    color: mine
                                        ? null
                                        : VibraColors.surfaceElevated,
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
                                        : Border.all(
                                            color: VibraColors.glassBorder,
                                          ),
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
                                  color: VibraColors.textSecondary,
                                  fontSize: 10,
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: VibraColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(
                        VibraSpacing.radiusFull,
                      ),
                      border: Border.all(color: VibraColors.glassBorder),
                    ),
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _sendMessage(),
                      style: const TextStyle(color: VibraColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.chatInputHint,
                        hintStyle: const TextStyle(
                          color: VibraColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: const BoxDecoration(
                    color: VibraColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
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
    if (message.messageType == 'image' &&
        message.metadata != null &&
        message.metadata!['url'] != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: message.metadata!['url'] as String,
          fit: BoxFit.cover,
          memCacheWidth: 600,
          placeholder: (context, url) => Container(color: Colors.white10),
          errorWidget: (context, url, error) => const Center(
            child: Icon(Icons.broken_image, color: Colors.white54),
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
              const Icon(
                Icons.location_on_rounded,
                color: VibraColors.accent,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Proposta di Incontro',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(message.content, style: theme.textTheme.bodyMedium),
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
      style: theme.textTheme.bodyMedium?.copyWith(
        color: VibraColors.textPrimary,
      ),
    );
  }
}
