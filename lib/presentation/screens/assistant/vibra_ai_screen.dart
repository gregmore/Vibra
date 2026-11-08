import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/vibra_colors.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/vibra_ai.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/core_providers.dart';
import '../../providers/vibra_ai_providers.dart';
import '../../widgets/common/vibra_button.dart';
import '../../widgets/common/vibra_image.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/common/vibra_surface.dart';

void _snack(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

/// VIBRA AI (docs/vibra-ai.md): an optional personal music assistant.
/// Verified results (from Spotify and VIBRA) are shown apart from generated
/// text, which is always labelled as AI-generated.
class VibraAiScreen extends ConsumerWidget {
  const VibraAiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final status = ref.watch(aiStatusProvider);
    final consent = status.valueOrNull?.consent == true;
    return VibraPageScaffold(
      appBar: AppBar(
        title: Text(l10n.aiTitle),
        actions: [
          if (consent)
            PopupMenuButton<String>(
              tooltip: l10n.storyMore,
              onSelected: (a) async {
                if (a == 'new') ref.read(aiChatProvider.notifier).clear();
                if (a == 'off') {
                  try {
                    await ref
                        .read(supabaseVibraAiDatasourceProvider)
                        .setConsent(false);
                    ref.read(aiChatProvider.notifier).clear();
                    ref.invalidate(aiStatusProvider);
                    if (context.mounted) _snack(context, l10n.aiTurnedOff);
                  } catch (_) {
                    if (context.mounted) _snack(context, l10n.aiError);
                  }
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'new', child: Text(l10n.aiNewChat)),
                PopupMenuItem(value: 'off', child: Text(l10n.aiTurnOff)),
              ],
            ),
        ],
      ),
      child: status.when(
        loading: () => const VibraLoadingView(),
        error: (_, _) => const _Unavailable(),
        data: (s) => !s.available
            ? const _Unavailable()
            : !s.consent
            ? const _Consent()
            : const _Chat(),
      ),
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VibraEmptyView(
      title: l10n.aiUnavailableTitle,
      message: l10n.aiUnavailableBody,
      icon: Icons.auto_awesome_outlined,
    );
  }
}

/// Explicit opt-in: what is shared, with whom, and how to turn it off.
class _Consent extends ConsumerStatefulWidget {
  const _Consent();

  @override
  ConsumerState<_Consent> createState() => _ConsentState();
}

class _ConsentState extends ConsumerState<_Consent> {
  bool _saving = false;

  Future<void> _enable() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      await ref.read(supabaseVibraAiDatasourceProvider).setConsent(true);
      ref.invalidate(aiStatusProvider);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        _snack(context, l10n.aiError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    Widget row(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: VibraSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: t.accentPrimary),
          const SizedBox(width: VibraSpacing.sm),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
    return ListView(
      padding: const EdgeInsets.all(VibraSpacing.pagePadding),
      children: [
        Icon(Icons.auto_awesome_rounded, size: 40, color: t.accentPrimary),
        const SizedBox(height: VibraSpacing.md),
        Text(l10n.aiConsentTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: VibraSpacing.sm),
        Text(
          l10n.aiConsentIntro,
          style: theme.textTheme.bodyMedium?.copyWith(color: t.textSecondary),
        ),
        const SizedBox(height: VibraSpacing.lg),
        VibraSurface(
          padding: const EdgeInsets.all(VibraSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.aiConsentUses, style: theme.textTheme.titleSmall),
              const SizedBox(height: VibraSpacing.sm),
              row(Icons.donut_large_rounded, l10n.aiConsentUsesProfile),
              row(Icons.chat_bubble_outline_rounded, l10n.aiConsentUsesChat),
              row(Icons.public_rounded, l10n.aiConsentUsesCatalogue),
              const SizedBox(height: VibraSpacing.sm),
              Text(l10n.aiConsentNever, style: theme.textTheme.titleSmall),
              const SizedBox(height: VibraSpacing.sm),
              row(Icons.lock_outline_rounded, l10n.aiConsentNeverBody),
              const SizedBox(height: VibraSpacing.sm),
              Text(
                l10n.aiConsentProvider,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: VibraSpacing.xl),
        VibraButton(
          label: l10n.aiConsentAccept,
          tone: VibraButtonTone.signal,
          leadingIcon: Icons.auto_awesome_rounded,
          expanded: true,
          loading: _saving,
          onPressed: _saving ? null : _enable,
        ),
        const SizedBox(height: VibraSpacing.sm),
        VibraButton(
          label: l10n.aiConsentDecline,
          tone: VibraButtonTone.text,
          expanded: true,
          onPressed: () => context.canPop() ? context.pop() : null,
        ),
      ],
    );
  }
}

class _Chat extends ConsumerStatefulWidget {
  const _Chat();

  @override
  ConsumerState<_Chat> createState() => _ChatState();
}

class _ChatState extends ConsumerState<_Chat> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send([String? text]) async {
    final q = (text ?? _input.text).trim();
    if (q.isEmpty) return;
    _input.clear();
    await ref.read(aiChatProvider.notifier).send(q);
    if (!mounted) return;
    final error = ref.read(aiChatProvider).error;
    if (error == 'consent_required' || error == 'unavailable') {
      ref.invalidate(aiStatusProvider);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final chat = ref.watch(aiChatProvider);
    final examples = [
      l10n.aiExampleSimilar,
      l10n.aiExampleUnderground,
      l10n.aiExampleAlbums,
      l10n.aiExampleExplain,
      l10n.aiExampleConcerts,
      l10n.aiExampleCommunities,
      l10n.aiExampleGenres,
    ];
    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.all(VibraSpacing.pagePadding),
            children: [
              if (chat.messages.isEmpty) ...[
                Text(
                  l10n.aiIntro,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: VibraSpacing.md),
                Wrap(
                  spacing: VibraSpacing.xs,
                  runSpacing: VibraSpacing.xs,
                  children: [
                    for (final e in examples)
                      ActionChip(label: Text(e), onPressed: () => _send(e)),
                  ],
                ),
              ],
              for (final m in chat.messages)
                m.fromUser
                    ? _UserBubble(text: m.text)
                    : _AnswerView(answer: m.answer!),
              if (chat.sending)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: VibraSpacing.md,
                  ),
                  child: Row(
                    children: [
                      const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: VibraSpacing.sm),
                      Text(
                        l10n.aiThinking,
                        style: TextStyle(color: t.textSecondary),
                      ),
                    ],
                  ),
                ),
              if (chat.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: VibraSpacing.sm,
                  ),
                  child: Text(switch (chat.error) {
                    'rate_limited' => l10n.aiRateLimited,
                    'unavailable' => l10n.aiUnavailableBody,
                    _ => l10n.aiError,
                  }, style: TextStyle(color: t.error)),
                ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              VibraSpacing.pagePadding,
              VibraSpacing.xs,
              VibraSpacing.sm,
              VibraSpacing.sm,
            ),
            child: TextField(
              controller: _input,
              maxLength: 2000,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                counterText: '',
                hintText: l10n.aiInputHint,
                suffixIcon: IconButton(
                  tooltip: l10n.storySendReply,
                  onPressed: chat.sending ? null : () => _send(),
                  icon: const Icon(Icons.send_rounded),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: VibraSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: VibraSpacing.md,
          vertical: VibraSpacing.sm,
        ),
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          color: t.accentFill,
          borderRadius: BorderRadius.circular(VibraSpacing.radiusLarge),
        ),
        child: Text(text, style: TextStyle(color: t.onAccent)),
      ),
    );
  }
}

class _AnswerView extends StatelessWidget {
  const _AnswerView({required this.answer});
  final AiAnswer answer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    if (answer.status != 'ok') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: VibraSpacing.sm),
        child: Text(
          answer.status == 'refused' ? l10n.aiRefused : l10n.aiIncomplete,
          style: TextStyle(color: t.textSecondary),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VibraSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Generated text is always labelled.
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: t.accentPrimary,
              ),
              const SizedBox(width: VibraSpacing.xs),
              Text(
                l10n.aiGeneratedLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: t.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: VibraSpacing.xs),
          Text(answer.text, style: theme.textTheme.bodyMedium),
          if (answer.verified.isNotEmpty) ...[
            const SizedBox(height: VibraSpacing.md),
            Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 16,
                  color: VibraPalette.success,
                ),
                const SizedBox(width: VibraSpacing.xs),
                Text(l10n.aiVerifiedTitle, style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: VibraSpacing.xs),
            for (final item in answer.verified) _VerifiedCard(item: item),
          ],
          if (answer.ideas.isNotEmpty) ...[
            const SizedBox(height: VibraSpacing.md),
            Text(l10n.aiIdeasTitle, style: theme.textTheme.titleSmall),
            Text(
              l10n.aiIdeasBody,
              style: theme.textTheme.bodySmall?.copyWith(color: t.textMuted),
            ),
            const SizedBox(height: VibraSpacing.xs),
            for (final idea in answer.ideas)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(
                  idea.kind == 'genre'
                      ? Icons.category_outlined
                      : Icons.lightbulb_outline_rounded,
                  color: t.textSecondary,
                ),
                title: Text(idea.title),
                subtitle: idea.note == null || idea.note!.isEmpty
                    ? null
                    : Text(idea.note!),
              ),
          ],
        ],
      ),
    );
  }
}

class _VerifiedCard extends ConsumerWidget {
  const _VerifiedCard({required this.item});
  final AiVerifiedItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final source = switch (item.source) {
      'spotify' => l10n.aiSourceSpotify,
      'vibra_events' => l10n.aiSourceEvents,
      'vibra_communities' => l10n.aiSourceCommunities,
      'musical_dna' => l10n.aiSourceDna,
      _ => l10n.aiSourceGenres,
    };
    final icon = switch (item.kind) {
      AiItemKind.artist => Icons.mic_external_on_rounded,
      AiItemKind.album => Icons.album_rounded,
      AiItemKind.track => Icons.music_note_rounded,
      AiItemKind.event => Icons.event_rounded,
      AiItemKind.community => Icons.groups_2_outlined,
      AiItemKind.genre => Icons.category_outlined,
    };

    Future<void> open() async {
      switch (item.kind) {
        case AiItemKind.event:
          final id = item.localId;
          final event = id == null
              ? null
              : await ref.read(supabaseVibraAiDatasourceProvider).event(id);
          if (event != null && context.mounted) {
            context.push('/event-detail', extra: event);
          }
        case AiItemKind.community:
          context.push('/community', extra: item.localId);
        case AiItemKind.genre:
          break;
        default:
          final uri = item.url == null ? null : Uri.tryParse(item.url!);
          if (uri != null) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
      }
    }

    final members = item.kind == AiItemKind.community
        ? int.tryParse(item.subtitle ?? '')
        : null;
    final details = [
      if (item.kind != AiItemKind.community) ?item.subtitle,
      if (item.kind == AiItemKind.event && item.date != null)
        DateFormat.yMMMEd(locale).add_Hm().format(item.date!.toLocal()),
      if (members != null) l10n.aiMembersCount(members),
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: VibraSpacing.sm),
      child: VibraSurface(
        onTap: item.kind == AiItemKind.genre ? null : open,
        semanticLabel: '${item.title}, $source',
        padding: const EdgeInsets.all(VibraSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(
                item.kind == AiItemKind.artist ? 28 : VibraSpacing.radiusSmall,
              ),
              child: SizedBox.square(
                dimension: 56,
                child: item.imageUrl == null
                    ? ColoredBox(
                        color: t.surfaceMuted,
                        child: Icon(icon, color: t.textSecondary),
                      )
                    : VibraNetworkImage(
                        url: item.imageUrl,
                        cacheWidth: 160,
                        fallbackIcon: icon,
                      ),
              ),
            ),
            const SizedBox(width: VibraSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  if (details.isNotEmpty)
                    Text(
                      details.join(' · '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: t.textSecondary,
                      ),
                    ),
                  const SizedBox(height: VibraSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: VibraPalette.success,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          source,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: t.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (item.note != null && item.note!.isNotEmpty) ...[
                    const SizedBox(height: VibraSpacing.xs),
                    Text(
                      item.note!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
