import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/entities/live_message.dart';
import '../../../domain/usecases/events_usecases.dart';
import '../../../domain/usecases/live_usecases.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/core_providers.dart';
import '../../providers/live_events_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/usecase_providers.dart';
import '../../widgets/common/vibra_page_scaffold.dart';

class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key, this.initialEventId});

  final String? initialEventId;

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  final _controller = TextEditingController();
  String? _selectedEventId;
  bool _sending = false;
  bool _joining = false;
  Timer? _locationRefresh;

  @override
  void initState() {
    super.initState();
    _selectedEventId = widget.initialEventId;
    // Recheck eligibility when time passes or the user leaves the venue.
    _locationRefresh = Timer.periodic(const Duration(minutes: 1), (_) {
      ref.invalidate(userLocationProvider);
      ref.invalidate(liveEventsProvider);
    });
  }

  @override
  void didUpdateWidget(covariant LiveScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialEventId != widget.initialEventId) {
      _selectedEventId = widget.initialEventId;
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _locationRefresh?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _showError(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _sendMessage(Event event) async {
    final text = _controller.text.trim();
    if (_sending || text.isEmpty) return;
    if (text.length > 2000) {
      _showError(AppLocalizations.of(context)!.chatMessageTooLong);
      return;
    }
    setState(() => _sending = true);
    _controller.clear();
    try {
      await ref
          .read(sendLiveMessageUseCaseProvider)
          .call(SendLiveMessageParams(eventId: event.id, content: text));
    } catch (_) {
      if (!mounted) return;
      if (_selectedEventId == null || _selectedEventId == event.id) {
        final newerDraft = _controller.text;
        _controller.text = newerDraft.isEmpty ? text : '$text\n\n$newerDraft';
      }
      _showError(AppLocalizations.of(context)!.liveScreenSendFailed);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _join(Event event) async {
    if (_joining) return;
    setState(() => _joining = true);
    try {
      await ref
          .read(setEventAttendanceUseCaseProvider)
          .call(SetEventAttendanceParams(event: event, status: 'going'));
      if (!mounted) return;
      ref.invalidate(liveAttendanceProvider(event.id));
      ref.read(myEventsProvider.notifier).applyAttendance(event, 'going');
    } catch (_) {
      _showError(AppLocalizations.of(context)!.liveAttendanceError);
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final events = ref.watch(liveEventsProvider);
    return VibraPageScaffold(
      appBar: AppBar(title: Text(l10n.liveScreenTitle)),
      child: events.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _stateView(
          Icons.cloud_off_rounded,
          AppLocalizations.of(context)!.liveEventsLoadError,
          FilledButton.tonal(
            onPressed: () => ref.invalidate(liveEventsProvider),
            child: Text(l10n.commonRetry),
          ),
        ),
        data: (available) {
          Event? event;
          if (_selectedEventId == null) {
            if (available.isNotEmpty) event = available.first;
          } else {
            for (final candidate in available) {
              if (candidate.id == _selectedEventId) {
                event = candidate;
                break;
              }
            }
          }
          if (event == null) {
            return _stateView(
              Icons.location_on_outlined,
              _selectedEventId == null
                  ? AppLocalizations.of(context)!.liveLocationHelp
                  : AppLocalizations.of(context)!.liveUnavailableHere,
              FilledButton.tonal(
                onPressed: () {
                  ref.invalidate(userLocationProvider);
                  ref.invalidate(liveEventsProvider);
                },
                child: Text(AppLocalizations.of(context)!.liveRefreshLocation),
              ),
            );
          }
          final selected = event;
          final attendance = ref.watch(liveAttendanceProvider(selected.id));
          final canSend = const {
            'going',
            'maybe',
          }.contains(attendance.valueOrNull);
          final messages = ref.watch(liveMessagesProvider(selected.id));
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: available.length > 1 && widget.initialEventId == null
                    ? DropdownButtonFormField<String>(
                        key: ValueKey(selected.id),
                        initialValue: selected.id,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          )!.liveEventTitle,
                        ),
                        items: available
                            .map(
                              (item) => DropdownMenuItem(
                                value: item.id,
                                child: Text(
                                  item.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: _sending
                            ? null
                            : (value) => setState(() {
                                _selectedEventId = value;
                                _controller.clear();
                              }),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selected.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (selected.venueName?.isNotEmpty ?? false)
                            Text(
                              selected.venueName!,
                              style: TextStyle(color: t.textSecondary),
                            ),
                        ],
                      ),
              ),
              const Divider(height: 1),
              Expanded(
                child: messages.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => _stateView(
                    Icons.wifi_off_rounded,
                    AppLocalizations.of(context)!.liveConnectionInterrupted,
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(liveMessagesProvider(selected.id)),
                      child: Text(l10n.commonRetry),
                    ),
                  ),
                  data: (items) => items.isEmpty
                      ? _stateView(
                          Icons.chat_bubble_outline_rounded,
                          AppLocalizations.of(context)!.liveEmpty,
                          null,
                        )
                      : _messageList(items),
                ),
              ),
              if (!canSend)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: attendance.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, _) => TextButton(
                      onPressed: () =>
                          ref.invalidate(liveAttendanceProvider(selected.id)),
                      child: Text(
                        AppLocalizations.of(context)!.liveRetryAttendance,
                      ),
                    ),
                    data: (_) => FilledButton.tonal(
                      onPressed: _joining ? null : () => _join(selected),
                      child: Text(
                        _joining
                            ? AppLocalizations.of(
                                context,
                              )!.liveConfirmingAttendance
                            : AppLocalizations.of(context)!.liveJoinToChat,
                      ),
                    ),
                  ),
                ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          enabled: canSend,
                          minLines: 1,
                          maxLines: 3,
                          maxLength: 2000,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) =>
                              canSend ? _sendMessage(selected) : null,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(
                              context,
                            )!.liveInputHint,
                            counterText: '',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        tooltip: AppLocalizations.of(context)!.liveSendMessage,
                        onPressed:
                            canSend &&
                                !_sending &&
                                _controller.text.trim().isNotEmpty
                            ? () => _sendMessage(selected)
                            : null,
                        icon: _sending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _stateView(IconData icon, String text, Widget? action) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: context.vibraTokens.textSecondary),
          const SizedBox(height: 16),
          Text(text, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 16), action],
        ],
      ),
    ),
  );

  Widget _messageList(List<LiveMessage> messages) {
    final t = context.vibraTokens;
    final currentUser = ref.watch(supabaseDatasourceProvider).currentUser?.id;
    // The datasource already returns newest first; reverse places it at bottom.
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final mine = message.userId == currentUser;
        return Align(
          alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.8,
            ),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: mine ? t.accentPrimary : t.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyle(color: mine ? t.onAccent : t.textPrimary),
                ),
                if (message.createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.Hm().format(message.createdAt!.toLocal()),
                    style: TextStyle(
                      fontSize: 11,
                      color: mine ? t.onAccent : t.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
