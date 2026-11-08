import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/vibra_colors.dart';
import '../../core/theme/vibra_spacing.dart';
import '../../core/theme/vibra_theme_tokens.dart';
import '../../domain/entities/music_reaction.dart';
import '../../l10n/app_localizations.dart';
import '../providers/core_providers.dart';
import '../providers/daily_vibe_providers.dart';
import 'common/vibra_bottom_sheet.dart';

/// Reusable reaction components (docs/track-reactions.md), used by Daily
/// Vibe, Stories, the Feed and Communities.

String reactionEmoji(String key) => MusicReactions.emoji[key] ?? '•';

String reactionLabel(AppLocalizations l10n, String key) => switch (key) {
  'fire' => l10n.reactionFire,
  'obsessed' => l10n.reactionObsessed,
  'underrated' => l10n.reactionUnderrated,
  'classic' => l10n.reactionClassic,
  'new_discovery' => l10n.reactionNewDiscovery,
  'on_repeat' => l10n.reactionOnRepeat,
  'heart' => l10n.reactionHeart,
  'headphones' => l10n.reactionHeadphones,
  'clap' => l10n.reactionClap,
  'mind_blown' => l10n.reactionMindBlown,
  _ => key,
};

/// "🔥 3 · 💎 1" for a compact count summary.
String reactionSummary(Map<String, int> counts) => [
  for (final e in counts.entries)
    if (e.value > 0) '${reactionEmoji(e.key)}${e.value}',
].join(' ');

/// A row of reaction chips with counts. Track reactions show their name
/// (they say something about the song); general ones are emoji only.
class ReactionChips extends StatelessWidget {
  const ReactionChips({
    required this.options,
    required this.counts,
    required this.mine,
    this.onToggle,
    this.hideEmpty = false,
    super.key,
  });

  final List<String> options;
  final Map<String, int> counts;
  final Set<String> mine;

  /// Null: read-only (e.g. your own share).
  final ValueChanged<String>? onToggle;

  /// Only show reactions someone used (read-only views).
  final bool hideEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labelled =
        identical(options, MusicReactions.track) ||
        options.any(
          (o) =>
              MusicReactions.track.contains(o) &&
              !MusicReactions.general.contains(o),
        );
    return Wrap(
      spacing: VibraSpacing.xs,
      runSpacing: VibraSpacing.xs,
      children: [
        for (final r in options)
          if (!hideEmpty || (counts[r] ?? 0) > 0 || mine.contains(r))
            ReactionChip(
              reaction: r,
              label: labelled ? reactionLabel(l10n, r) : null,
              count: counts[r] ?? 0,
              selected: mine.contains(r),
              onTap: onToggle == null
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      onToggle!(r);
                    },
            ),
      ],
    );
  }
}

class ReactionChip extends StatelessWidget {
  const ReactionChip({
    required this.reaction,
    required this.count,
    required this.selected,
    this.label,
    this.onTap,
    super.key,
  });

  final String reaction;
  final String? label;
  final int count;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: '${reactionLabel(l10n, reaction)}${count > 0 ? ', $count' : ''}',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(VibraSpacing.radiusFull),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minHeight: 36, minWidth: 44),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? t.accentSoft : t.surfaceElevated,
            borderRadius: BorderRadius.circular(VibraSpacing.radiusFull),
            border: Border.all(
              color: selected ? t.accentPrimary : t.borderDefault,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(reactionEmoji(reaction)),
              if (label != null) ...[
                const SizedBox(width: 4),
                Text(
                  label!,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: selected ? t.textPrimary : t.textSecondary,
                  ),
                ),
              ],
              if (count > 0) ...[
                const SizedBox(width: 4),
                Text(
                  '$count',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: t.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Big round reaction buttons for dark, full-screen surfaces (stories).
class ReactionButtonRow extends StatelessWidget {
  const ReactionButtonRow({
    required this.options,
    required this.mine,
    required this.onToggle,
    super.key,
  });
  final List<String> options;
  final Set<String> mine;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labelled = options.any((o) => !MusicReactions.general.contains(o));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final r in options)
          Flexible(
            child: Semantics(
              button: true,
              selected: mine.contains(r),
              label: reactionLabel(l10n, r),
              excludeSemantics: true,
              onTap: () => onToggle(r),
              child: InkResponse(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onToggle(r);
                },
                radius: 28,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(VibraSpacing.sm),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: mine.contains(r)
                            ? const Color(0x338B5CF6)
                            : Colors.transparent,
                        border: Border.all(
                          color: mine.contains(r)
                              ? VibraPalette.violet
                              : Colors.transparent,
                        ),
                      ),
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 180),
                        scale: mine.contains(r) ? 1.15 : 1,
                        child: Text(
                          reactionEmoji(r),
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    ),
                    if (labelled)
                      Text(
                        reactionLabel(l10n, r),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: VibraPalette.textOnDarkSecondary,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A sheet to pick one reaction. Returns its key.
Future<String?> showReactionPicker(
  BuildContext context, {
  required List<String> options,
  required Set<String> mine,
}) {
  final l10n = AppLocalizations.of(context)!;
  final song = options.any((o) => !MusicReactions.general.contains(o));
  return VibraBottomSheet.show<String>(
    context,
    builder: (sheet) => VibraBottomSheet(
      title: song ? l10n.reactionTrackTitle : l10n.feedReact,
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        childAspectRatio: 1.3,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final r in options)
            Semantics(
              button: true,
              selected: mine.contains(r),
              label: reactionLabel(l10n, r),
              excludeSemantics: true,
              onTap: () => Navigator.of(sheet).pop(r),
              child: InkWell(
                borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
                onTap: () => Navigator.of(sheet).pop(r),
                child: Container(
                  margin: const EdgeInsets.all(VibraSpacing.xs),
                  decoration: BoxDecoration(
                    color: mine.contains(r)
                        ? context.vibraTokens.accentSoft
                        : null,
                    borderRadius: BorderRadius.circular(
                      VibraSpacing.radiusMedium,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        reactionEmoji(r),
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(height: VibraSpacing.xs),
                      Text(
                        reactionLabel(l10n, r),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

/// External URLs already in my Discoveries (to show "saved").
/// Reads only the links, not the whole collection (docs/performance.md).
final discoveredUrlsProvider = Provider.autoDispose<Set<String>>(
  (ref) => ref.watch(discoveredUrlsSourceProvider).valueOrNull ?? const {},
);

/// Saves a shared song to Discoveries. Returns false on failure.
Future<bool> saveSongToDiscoveries(
  WidgetRef ref,
  DiscoverySource source,
  String id,
) async {
  try {
    await ref.read(supabaseDailyVibeDatasourceProvider).saveTrack(source, id);
    ref.invalidate(discoveriesProvider);
    ref.invalidate(discoveredUrlsSourceProvider);
    return true;
  } catch (_) {
    return false;
  }
}

/// "Add to Discoveries" for a shared song, reusable anywhere.
class SaveSongButton extends ConsumerStatefulWidget {
  const SaveSongButton({
    required this.source,
    required this.id,
    required this.externalUrl,
    this.compact = false,
    this.onDark = false,
    super.key,
  });

  final DiscoverySource source;
  final String id;
  final String externalUrl;

  /// Icon only.
  final bool compact;

  /// On a dark full-screen surface (stories).
  final bool onDark;

  @override
  ConsumerState<SaveSongButton> createState() => _SaveSongButtonState();
}

class _SaveSongButtonState extends ConsumerState<SaveSongButton> {
  bool _saving = false;
  bool _justSaved = false;

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    final ok = await saveSongToDiscoveries(ref, widget.source, widget.id);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _justSaved = ok;
    });
    showDiscoverySavedSnack(context, ok: ok, l10n: l10n);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final saved =
        _justSaved ||
        ref.watch(discoveredUrlsProvider).contains(widget.externalUrl);
    final color = widget.onDark ? VibraPalette.textOnDark : null;
    final icon = Icon(
      saved ? Icons.library_add_check_rounded : Icons.library_add_outlined,
      size: 20,
      color: saved
          ? (widget.onDark ? VibraPalette.violet : t.accentPrimary)
          : color,
    );
    final onPressed = saved || _saving ? null : _save;
    if (widget.compact) {
      return IconButton(
        tooltip: saved ? l10n.vibeSaved : l10n.vibeSave,
        onPressed: onPressed,
        icon: icon,
      );
    }
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        disabledForegroundColor: widget.onDark
            ? VibraPalette.textOnDarkSecondary
            : null,
      ),
      icon: icon,
      label: Text(saved ? l10n.vibeSaved : l10n.vibeSave),
    );
  }
}

void showDiscoverySavedSnack(
  BuildContext context, {
  required bool ok,
  required AppLocalizations l10n,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(
    SnackBar(
      content: Text(ok ? l10n.discoveryAdded : l10n.discoveryAddFailed),
      action: ok
          ? SnackBarAction(
              label: l10n.discoveriesTitle,
              onPressed: () => context.push('/discoveries'),
            )
          : null,
    ),
  );
}

/// After a "New discovery" reaction, offer to keep the song.
void offerToSaveDiscovery(
  BuildContext context,
  WidgetRef ref, {
  required String reaction,
  required bool turnedOn,
  required DiscoverySource source,
  required String id,
  required String externalUrl,
}) {
  if (reaction != MusicReactions.discovery || !turnedOn) return;
  if (ref.read(discoveredUrlsProvider).contains(externalUrl)) return;
  final l10n = AppLocalizations.of(context)!;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(l10n.discoveryOffer),
      action: SnackBarAction(
        label: l10n.vibeSave,
        onPressed: () => saveSongToDiscoveries(ref, source, id),
      ),
    ),
  );
}
