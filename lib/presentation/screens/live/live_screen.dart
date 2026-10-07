import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import 'package:vibra/l10n/app_localizations.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/usecases/live_usecases.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/usecase_providers.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_section_header.dart';
import '../../widgets/vibra_neon_avatar.dart';
import '../../widgets/vibra_glassmorphic_card.dart';

class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  bool liveEnabled = true;
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    controller.clear();

    try {
      final events = ref.read(allEventsProvider);
      final eventId = events.isNotEmpty ? events.first.id : 'ev1';
      await ref
          .read(sendLiveMessageUseCaseProvider)
          .call(SendLiveMessageParams(eventId: eventId, content: text));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.liveScreenSendFailed),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(matchedUsersProvider).take(3).toList();
    final liveMessages = ref.watch(liveMessagesProvider);
    final theme = Theme.of(context);
    final t = context.vibraTokens;

    return VibraPageScaffold(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              VibraSpacing.pagePadding,
              20,
              VibraSpacing.pagePadding,
              14,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.liveScreenTitle,
                            style: theme.textTheme.displaySmall,
                          ),
                          if (liveEnabled)
                            Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: t.accentPrimary,
                                    borderRadius: VibraSpacing.borderFull,
                                  ),
                                  child: Text(
                                    'LIVE',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: t.onAccent,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                )
                                .animate(
                                  onPlay: (controller) => controller.repeat(),
                                )
                                .scale(
                                  begin: const Offset(0.8, 0.8),
                                  end: const Offset(1.2, 1.2),
                                  duration: 1000.ms,
                                )
                                .then()
                                .scale(
                                  begin: const Offset(1.2, 1.2),
                                  end: const Offset(0.8, 0.8),
                                  duration: 1000.ms,
                                ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        liveEnabled
                            ? 'Sei entro 500m dal venue. Chat attiva per le prossime 24h.'
                            : 'La modalità Live si attiva solo vicino al venue.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: t.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: liveEnabled,
                  activeThumbColor: t.accentPrimary,
                  onChanged: (value) => setState(() => liveEnabled = value),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
          VibraSectionHeader(
            title: AppLocalizations.of(context)!.liveScreenPresentNowTitle,
            subtitle: AppLocalizations.of(context)!.liveScreenPresentNowSub,
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          SizedBox(
            height: 92,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: VibraSpacing.pagePadding,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Container(
                      width: 172,
                      margin: const EdgeInsets.only(
                        right: 10,
                        top: 8,
                        bottom: 8,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: t.surfaceElevated,
                        borderRadius: VibraSpacing.borderMedium,
                        border: Border.all(color: t.borderDefault),
                        boxShadow: [t.cardShadow],
                      ),
                      child: Row(
                        children: [
                          VibraNeonAvatar(
                            imageUrl: user.user.avatarUrl ?? '',
                            radius: 18,
                            displayName:
                                user.user.displayName ?? user.user.username,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  user.user.displayName ?? user.user.username,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: t.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${user.compatibility}%',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: t.matchColor(
                                      user.compatibility / 100,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: (200 + index * 100).ms, duration: 400.ms)
                    .slideX(begin: 0.1, end: 0);
              },
            ),
          ),
          VibraSectionHeader(
            title: AppLocalizations.of(context)!.liveScreenChatTitle,
            subtitle: AppLocalizations.of(context)!.liveScreenChatSub,
          ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
          Expanded(
            child: Stack(
              children: [
                // Chat list
                ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.fromLTRB(
                    VibraSpacing.pagePadding,
                    12,
                    VibraSpacing.pagePadding,
                    12,
                  ),
                  itemCount: liveMessages.length,
                  itemBuilder: (context, index) {
                    final message = liveMessages[index];
                    final currentUserId =
                        Supabase.instance.client.auth.currentUser?.id;
                    final mine = message.userId == currentUserId;
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
                                  maxWidth: 290,
                                ),
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  gradient: mine ? t.primaryGradient : null,
                                  color: mine ? null : t.surfaceElevated,
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
                                child: Text(
                                  message.content,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: mine ? t.onAccent : t.textPrimary,
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 300.ms)
                              .slideY(
                                begin: 0.1,
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
                // Disabled overlay
                if (!liveEnabled)
                  Positioned.fill(
                    child: Container(
                      color: t.backgroundPrimary.withValues(alpha: 0.94),
                      padding: EdgeInsets.all(VibraSpacing.pagePadding),
                      child: Center(
                        child: VibraGlassmorphicCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off_rounded,
                                size: 64,
                                color: t.textSecondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context)!.liveModeDisabled,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: t.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Attivala per accedere alla chat in tempo reale con gli altri partecipanti presenti al concerto.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: t.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              FilledButton.tonal(
                                onPressed: () =>
                                    setState(() => liveEnabled = true),
                                style: FilledButton.styleFrom(
                                  backgroundColor: t.accentPrimary,
                                  foregroundColor: t.onAccent,
                                ),
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.liveScreenActivateMode,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                  ),
              ],
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
                      color: t.surface,
                      borderRadius: VibraSpacing.borderFull,
                      border: Border.all(color: t.borderStrong),
                    ),
                    child: TextField(
                      controller: controller,
                      enabled: liveEnabled,
                      onSubmitted: (_) => _sendMessage(),
                      style: TextStyle(color: t.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Scrivi in chat live...',
                        hintStyle: TextStyle(color: t.textSecondary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: liveEnabled ? t.accentPrimary : t.surfaceMuted,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    tooltip: 'Invia messaggio live',
                    onPressed: liveEnabled ? _sendMessage : null,
                    icon: Icon(
                      Icons.send_rounded,
                      color: liveEnabled ? t.onAccent : t.textDisabled,
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
}
