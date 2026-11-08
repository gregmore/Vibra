import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/vibra_motion.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../domain/entities/app_user.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../providers/app_state_providers.dart';
import '../../widgets/common/vibra_avatar.dart';
import '../../widgets/common/vibra_button.dart';
import '../../widgets/common/vibra_logo.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/common/vibra_match_indicator.dart';
import '../../../domain/entities/music_affinity.dart';
import '../../localization/music_affinity_text.dart';
import '../../widgets/vibra_match_scanner.dart';
import 'package:vibra/l10n/app_localizations.dart';

/// Match sociale come una connessione editoriale, non un gauge fitness.
class SocialMatchScreen extends ConsumerStatefulWidget {
  const SocialMatchScreen({super.key});

  @override
  ConsumerState<SocialMatchScreen> createState() => _SocialMatchScreenState();
}

class _SocialMatchScreenState extends ConsumerState<SocialMatchScreen> {
  bool _isScanning = true;
  bool _sendingVibra = false;
  int _celebration = 0;

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  void _startScanning() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isScanning = false);
    });
  }

  Future<void> _sendVibra(MatchedUserPreview match) async {
    if (_sendingVibra) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _sendingVibra = true);
    try {
      await ref.read(matchedUsersProvider.notifier).sendVibra(match.user.id);
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      if (!VibraMotion.reduced(context)) setState(() => _celebration++);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              l10n.socialMatchVibraSent(
                match.user.displayName ?? match.user.username,
              ),
            ),
          ),
        );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.socialMatchSendFailed)));
    } finally {
      if (mounted) setState(() => _sendingVibra = false);
    }
  }

  void _passMatch(MatchedUserPreview match) {
    ref.read(matchedUsersProvider.notifier).passMatch(match.user.id);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(myProfileProvider);
    final matches = ref
        .watch(matchedUsersProvider)
        .where((match) => !match.isFriend)
        .toList(growable: false);

    return VibraPageScaffold(
      useGradient: false,
      child: Stack(
        children: [
          Positioned.fill(child: _buildBody(profile, matches)),
          if (_celebration > 0)
            Positioned.fill(
              child: _VibraSentBurst(
                key: ValueKey(_celebration),
                onDone: () {
                  if (mounted) setState(() => _celebration = 0);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(AppUser profile, List<MatchedUserPreview> matches) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          VibraSpacing.pagePadding,
          VibraSpacing.md,
          VibraSpacing.pagePadding,
          VibraSpacing.lg,
        ),
        child: Column(
          children: [
            if (GoRouter.maybeOf(context)?.canPop() ?? false)
              Row(
                children: [
                  BackButton(onPressed: () => context.pop()),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.socialMatchNewAffinity,
                      style: VibraTextStyles.labelSmall.copyWith(
                        color: context.vibraTokens.accentPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: VibraMotion.durationFor(context, VibraMotion.page),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween(begin: .965, end: 1.0).animate(animation),
                    child: child,
                  ),
                ),
                child: _isScanning
                    ? const _ScanningState(key: ValueKey('scanning'))
                    : matches.isNotEmpty
                    ? KeyedSubtree(
                        key: ValueKey('match-${matches.first.user.id}'),
                        child: _buildMatchStack(
                          profile.avatarUrl ?? '',
                          matches,
                        ),
                      )
                    : _EmptyMatchState(
                        key: const ValueKey('empty'),
                        onExplore: () => context.go('/explore'),
                        onRescan: () {
                          ref.invalidate(matchedUsersProvider);
                          setState(() => _isScanning = true);
                          _startScanning();
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchStack(String myAvatar, List<MatchedUserPreview> matches) {
    final t = context.vibraTokens;
    return Stack(
      alignment: Alignment.center,
      children: [
        if (matches.length > 1)
          Positioned.fill(
            child: Transform.translate(
              offset: const Offset(0, 14),
              child: Transform.scale(
                scale: 0.96,
                alignment: Alignment.bottomCenter,
                child: Opacity(
                  opacity: 0.42,
                  child: IgnorePointer(
                    child: _MatchPortrait(
                      myAvatar: myAvatar,
                      match: matches[1],
                      onPass: () {},
                      onSend: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        Positioned.fill(
          child: Dismissible(
            key: ValueKey(matches.first.user.id),
            direction: _sendingVibra
                ? DismissDirection.none
                : DismissDirection.horizontal,
            background: _SwipeHint(
              alignment: Alignment.centerLeft,
              label: AppLocalizations.of(context)!.socialMatchSend,
              color: t.accentFill,
              foreground: t.onAccent,
              icon: Icons.graphic_eq_rounded,
            ),
            secondaryBackground: _SwipeHint(
              alignment: Alignment.centerRight,
              label: AppLocalizations.of(context)!.socialMatchPass,
              color: t.surfaceMuted,
              foreground: t.textPrimary,
              icon: Icons.close_rounded,
            ),
            confirmDismiss: (direction) async {
              if (_sendingVibra) return false;
              if (direction == DismissDirection.startToEnd) {
                await _sendVibra(matches.first);
              } else {
                _passMatch(matches.first);
              }
              // The provider removes the card only after the operation succeeds.
              return false;
            },
            child: _MatchPortrait(
              myAvatar: myAvatar,
              match: matches.first,
              sending: _sendingVibra,
              onPass: _sendingVibra ? null : () => _passMatch(matches.first),
              onSend: _sendingVibra ? null : () => _sendVibra(matches.first),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanningState extends StatelessWidget {
  const _ScanningState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: VibraMatchScanner(
        title: l10n.socialMatchScanningTitle,
        subtitle: l10n.socialMatchScanningSubtitle,
      ),
    ).animate().fadeIn(duration: 360.ms).scaleXY(begin: .97, end: 1);
  }
}

class _MatchPortrait extends StatelessWidget {
  const _MatchPortrait({
    required this.myAvatar,
    required this.match,
    required this.onPass,
    required this.onSend,
    this.sending = false,
  });

  final String myAvatar;
  final MatchedUserPreview match;
  final VoidCallback? onPass;
  final VoidCallback? onSend;
  final bool sending;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final name = match.user.displayName ?? match.user.username;
    final affinity = match.affinity ?? AffinityDetails.empty;
    final category = AffinityCategory.fromScore(match.compatibility);
    // Shared genres first (families, then specific subgenres); otherwise the
    // other person's main genres. All from the server's explanation.
    final sharedGenres = <String>{
      for (final f in affinity.sharedFamilies) genreFamilyLabel(l10n, f),
      for (final s in affinity.sharedSubgenres) genreLabel(l10n, s),
    }.take(4).toList(growable: false);
    final theirGenres = [
      for (final f in affinity.theirTopFamilies) genreFamilyLabel(l10n, f),
    ];
    // Only artists the server found on both sides; never the other
    // person's own list presented as "in common".
    final artists = affinity.sharedArtists;
    final reasons = [
      for (final reason in affinity.reasons)
        if (reason is! SharedArtistsReason || artists.isEmpty)
          affinityReasonText(l10n, reason),
    ];

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(VibraSpacing.radiusXXL),
        border: Border.all(color: t.borderDefault),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                VibraSpacing.xl,
                VibraSpacing.xl,
                VibraSpacing.xl,
                VibraSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PairAvatars(
                    myAvatar: myAvatar,
                    myName: l10n.socialYou,
                    theirAvatar: match.user.avatarUrl,
                    theirName: name,
                  ),
                  const SizedBox(height: VibraSpacing.lg),
                  Semantics(
                    header: true,
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: VibraTextStyles.headlineMedium.copyWith(
                        color: t.textPrimary,
                      ),
                    ),
                  ),
                  if (match.user.displayName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '@${match.user.username}',
                      textAlign: TextAlign.center,
                      style: VibraTextStyles.bodySmall.copyWith(
                        color: t.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: VibraSpacing.xl),
                  Center(
                    child: VibraMatchIndicator(
                      percentage: match.compatibility,
                      size: 124,
                      label: l10n.socialMatchScore,
                    ),
                  ),
                  const SizedBox(height: VibraSpacing.md),
                  Center(child: _CategoryChip(category: category)),
                  const SizedBox(height: VibraSpacing.lg),
                  Text(
                    '“${affinityQuote(l10n, category)}”',
                    textAlign: TextAlign.center,
                    style: VibraTextStyles.bodyLarge.copyWith(
                      color: t.textPrimary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (sharedGenres.isNotEmpty || theirGenres.isNotEmpty) ...[
                    const SizedBox(height: VibraSpacing.xl),
                    _AffinitySection(
                      title: sharedGenres.isNotEmpty
                          ? l10n.affinitySharedGenres
                          : l10n.affinityTheirGenres,
                      value:
                          (sharedGenres.isNotEmpty ? sharedGenres : theirGenres)
                              .join(' · ')
                              .toUpperCase(),
                      accent: true,
                    ),
                  ],
                  if (artists.isNotEmpty) ...[
                    const SizedBox(height: VibraSpacing.md),
                    _AffinitySection(
                      title: l10n.affinityArtistsInCommon,
                      value: artists.take(3).join(' · '),
                    ),
                  ],
                  if (reasons.isNotEmpty) ...[
                    const SizedBox(height: VibraSpacing.xl),
                    Text(
                      l10n.affinityWhy.toUpperCase(),
                      style: VibraTextStyles.labelSmall.copyWith(
                        color: t.textSecondary,
                      ),
                    ),
                    const SizedBox(height: VibraSpacing.sm),
                    for (final reason in reasons)
                      Padding(
                        padding: const EdgeInsets.only(bottom: VibraSpacing.sm),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 7),
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: t.accentPrimary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            const SizedBox(width: VibraSpacing.md),
                            Expanded(
                              child: Text(
                                reason,
                                style: VibraTextStyles.bodyMedium.copyWith(
                                  color: t.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: VibraSpacing.sm),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => context.pushNamed(
                        RouteNames.userProfile,
                        extra: match.user.id,
                      ),
                      icon: const Icon(Icons.arrow_outward_rounded, size: 17),
                      label: Text(l10n.socialMatchViewProfile),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(
              VibraSpacing.lg,
              VibraSpacing.md,
              VibraSpacing.lg,
              VibraSpacing.lg,
            ),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: t.borderDefault)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: VibraButton(
                    label: l10n.socialMatchIgnore,
                    tone: VibraButtonTone.outline,
                    onPressed: onPass,
                  ),
                ),
                const SizedBox(width: VibraSpacing.md),
                Expanded(
                  flex: 3,
                  child: VibraButton(
                    label: l10n.socialMatchSendVibra,
                    tone: VibraButtonTone.signal,
                    leadingIcon: Icons.graphic_eq_rounded,
                    onPressed: onSend,
                    loading: sending,
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

/// Affinity band chip under the gauge (6 documented bands).
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final AffinityCategory category;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final strong = category.index <= AffinityCategory.high.index;
    final color = strong ? t.accentPrimary : t.accentSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .14),
        borderRadius: VibraSpacing.borderFull,
      ),
      child: Text(
        affinityCategoryLabel(AppLocalizations.of(context)!, category),
        style: VibraTextStyles.labelMedium.copyWith(color: t.textPrimary),
      ),
    );
  }
}

class _AffinitySection extends StatelessWidget {
  const _AffinitySection({
    required this.title,
    required this.value,
    this.accent = false,
  });

  final String title;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Container(
      padding: const EdgeInsets.all(VibraSpacing.lg),
      decoration: BoxDecoration(
        color: t.surfaceElevated,
        borderRadius: VibraSpacing.borderMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: VibraTextStyles.labelSmall.copyWith(color: t.textSecondary),
          ),
          const SizedBox(height: VibraSpacing.sm),
          Text(
            value,
            style:
                (accent
                        ? VibraTextStyles.titleSmall.copyWith(letterSpacing: .6)
                        : VibraTextStyles.bodyMedium)
                    .copyWith(color: accent ? t.accentPrimary : t.textPrimary),
          ),
        ],
      ),
    );
  }
}

/// You and them: two overlapping portraits joined by the VIBRA mark.
class _PairAvatars extends StatelessWidget {
  const _PairAvatars({
    required this.myAvatar,
    required this.myName,
    required this.theirAvatar,
    required this.theirName,
  });

  final String myAvatar;
  final String myName;
  final String? theirAvatar;
  final String theirName;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return SizedBox(
      height: 112,
      width: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 18,
            child: VibraAvatar(imageUrl: myAvatar, name: myName, radius: 40),
          ),
          Positioned(
            right: 8,
            child: VibraAvatar(
              imageUrl: theirAvatar,
              name: theirName,
              radius: 54,
              signalRing: true,
            ),
          ),
          Positioned(
            left: 88,
            bottom: 8,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: t.backgroundPrimary,
                shape: BoxShape.circle,
                border: Border.all(color: t.accentPrimary, width: 1.5),
              ),
              alignment: Alignment.center,
              child: VibraLogo(width: 18, height: 16, color: t.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// One-shot confirmation after a Vibra is sent: the mark blooms in violet
/// with a single expanding ring, then fades. ~900 ms, never loops.
class _VibraSentBurst extends StatelessWidget {
  const _VibraSentBurst({required this.onDone, super.key});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: VibraMotion.logo,
        onEnd: onDone,
        builder: (context, v, _) {
          final appear = Curves.easeOutBack.transform((v / .4).clamp(0, 1));
          final fade = 1 - Curves.easeIn.transform(((v - .6) / .4).clamp(0, 1));
          return Opacity(
            opacity: fade,
            child: Center(
              child: SizedBox.square(
                dimension: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 80 + 140 * v,
                      height: 80 + 140 * v,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: t.accentPrimary.withValues(alpha: 1 - v),
                          width: 2,
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: .6 + .4 * appear,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: t.accentFill,
                        ),
                        alignment: Alignment.center,
                        child: VibraLogo(
                          width: 46,
                          height: 40,
                          color: t.onAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint({
    required this.alignment,
    required this.label,
    required this.color,
    required this.foreground,
    required this.icon,
  });

  final Alignment alignment;
  final String label;
  final Color color;
  final Color foreground;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(VibraSpacing.radiusXXL),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground, size: 28),
          const SizedBox(height: 6),
          Text(
            label,
            style: VibraTextStyles.labelSmall.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

class _EmptyMatchState extends StatelessWidget {
  const _EmptyMatchState({
    required this.onExplore,
    required this.onRescan,
    super.key,
  });

  final VoidCallback onExplore;
  final VoidCallback onRescan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VibraEmptyView(
      icon: Icons.graphic_eq_rounded,
      title: l10n.socialMatchEmptyTitle,
      message: l10n.socialMatchEmptyMessage,
      actionLabel: l10n.socialMatchEmptyAction,
      onActionTap: onExplore,
      secondaryActionLabel: l10n.socialMatchEmptySecondary,
      onSecondaryActionTap: onRescan,
    );
  }
}
