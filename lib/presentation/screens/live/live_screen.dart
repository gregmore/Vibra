import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import 'package:vibra/l10n/app_localizations.dart';
import '../../../core/theme/vibra_colors.dart';
import '../../../core/theme/vibra_spacing.dart';
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
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: VibraColors.accent,
                                    shape: BoxShape.circle,
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
                          color: VibraColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: liveEnabled,
                  activeThumbColor: VibraColors.accent,
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
                        color: VibraColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(
                          VibraSpacing.radiusLarge,
                        ),
                        border: Border.all(
                          color: VibraColors.glassBorder,
                          width: 1,
                        ),
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
                                    color: VibraColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${user.compatibility}%',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: VibraColors
                                        .accentWarm, // using accentWarm instead of plain green
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
                                child: Text(
                                  message.content,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: VibraColors.textPrimary,
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
                // Disabled overlay
                if (!liveEnabled)
                  Positioned.fill(
                    child: Container(
                      color: VibraColors.background.withValues(alpha: 0.85),
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
                                color: VibraColors.textSecondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context)!.liveModeDisabled,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: VibraColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Attivala per accedere alla chat in tempo reale con gli altri partecipanti presenti al concerto.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: VibraColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              FilledButton.tonal(
                                onPressed: () =>
                                    setState(() => liveEnabled = true),
                                style: FilledButton.styleFrom(
                                  backgroundColor: VibraColors.accent,
                                  foregroundColor: VibraColors.textPrimary,
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
                      color: VibraColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(
                        VibraSpacing.radiusFull,
                      ),
                      border: Border.all(color: VibraColors.glassBorder),
                    ),
                    child: TextField(
                      controller: controller,
                      enabled: liveEnabled,
                      onSubmitted: (_) => _sendMessage(),
                      style: const TextStyle(color: VibraColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Scrivi in chat live...',
                        hintStyle: TextStyle(color: VibraColors.textSecondary),
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
                    color: liveEnabled
                        ? VibraColors.accent
                        : VibraColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: liveEnabled ? _sendMessage : null,
                    icon: Icon(
                      Icons.send_rounded,
                      color: liveEnabled
                          ? Colors.white
                          : VibraColors.textSecondary,
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
