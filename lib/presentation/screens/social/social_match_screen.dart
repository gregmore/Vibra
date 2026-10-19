import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import 'discover_users_screen.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../providers/app_state_providers.dart';
import '../../widgets/common/vibra_avatar.dart';
import '../../widgets/common/vibra_button.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_surface.dart';
import '../../widgets/vibra_affinity_score.dart';
import '../../widgets/vibra_match_scanner.dart';
import '../../widgets/vibra_signal_wave.dart';
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
    if (!AppConstants.spotifyEnabled) return const DiscoverUsersScreen();
    final profile = ref.watch(myProfileProvider);
    final matches = ref
        .watch(matchedUsersProvider)
        .where((match) => !match.isFriend)
        .toList(growable: false);

    return VibraPageScaffold(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 132),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 520),
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
                    child: _buildMatchStack(profile.avatarUrl ?? '', matches),
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
              color: t.accentPrimary,
              foreground: t.onAccent,
              icon: Icons.waves_rounded,
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
    final score = match.compatibility / 100;
    final name = match.user.displayName ?? match.user.username;
    final sharedArtists = match.topArtists.isEmpty
        ? AppLocalizations.of(context)!.socialMatchSharedListening
        : l10n.socialMatchListenBoth(match.topArtists.take(2).join(', '));

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [t.surfaceElevated, t.surface],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: t.borderStrong),
        boxShadow: [t.elevatedShadow],
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: VibraWaveBackdrop(
                color: t.accentPrimary,
                opacity: 0.22,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: t.accentSoft,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: t.accentPrimary.withValues(alpha: .28),
                        ),
                      ),
                      child: Text(
                        l10n.socialMatchNewAffinity.toUpperCase(),
                        style: VibraTextStyles.labelSmall.copyWith(
                          color: t.accentPrimary,
                          letterSpacing: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        VibraAvatar(
                          imageUrl: myAvatar,
                          name: AppLocalizations.of(context)!.socialYou,
                          radius: 30,
                        ),
                        Container(
                          width: 54,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: VibraSignalWave(
                            height: 22,
                            color: t.accentPrimary,
                            secondaryColor: t.textPrimary,
                            amplitude: 4,
                            animate: true,
                          ),
                        ),
                        VibraAvatar(
                          imageUrl: match.user.avatarUrl,
                          name: name,
                          radius: 38,
                          signalRing: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    VibraAffinityScore(
                      score: score,
                      caption: AppLocalizations.of(
                        context,
                      )!.socialMatchFrequencyNow,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: VibraTextStyles.displayMedium,
                    ),
                    const SizedBox(height: 24),
                    _ReasonLine(
                      index: '01',
                      title: AppLocalizations.of(
                        context,
                      )!.socialMatchSharedSound,
                      text: sharedArtists,
                      icon: Icons.music_note_rounded,
                    ),
                    _ReasonLine(
                      index: '02',
                      title: AppLocalizations.of(context)!.socialMatchSameArea,
                      text: l10n.socialMatchCityEvents(
                        match.city,
                        match.attendingEvents.toString(),
                      ),
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => context.pushNamed(
                        RouteNames.userProfile,
                        extra: match.user.id,
                      ),
                      icon: const Icon(Icons.arrow_outward_rounded, size: 17),
                      label: Text(l10n.socialMatchViewProfile),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            decoration: BoxDecoration(
              color: t.surface.withValues(alpha: .84),
              border: Border(top: BorderSide(color: t.borderDefault)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: VibraButton(
                    label: l10n.socialMatchIgnore,
                    tone: VibraButtonTone.outline,
                    leadingIcon: Icons.close_rounded,
                    onPressed: onPass,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: VibraButton(
                    label: l10n.socialMatchSendVibra,
                    tone: VibraButtonTone.signal,
                    leadingIcon: Icons.waves_rounded,
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

class _ReasonLine extends StatelessWidget {
  const _ReasonLine({
    required this.index,
    required this.title,
    required this.text,
    required this.icon,
  });

  final String index;
  final String title;
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.borderDefault)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            index,
            style: VibraTextStyles.labelSmall.copyWith(color: t.textSecondary),
          ),
          const SizedBox(width: 12),
          Icon(icon, size: 18, color: t.textPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: VibraTextStyles.labelSmall),
                const SizedBox(height: 4),
                Text(text, style: VibraTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
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
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 28),
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
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: VibraSurface(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: VibraSignalWave(
                height: 42,
                color: t.accentPrimary,
                secondaryColor: t.textPrimary,
                amplitude: 9,
                animate: true,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.socialMatchEmptyTitle,
              style: VibraTextStyles.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.socialMatchEmptyMessage,
              style: VibraTextStyles.bodySmall,
            ),
            const SizedBox(height: 20),
            VibraButton(
              label: l10n.socialMatchEmptyAction,
              tone: VibraButtonTone.signal,
              expanded: true,
              onPressed: onExplore,
            ),
            const SizedBox(height: 8),
            VibraButton(
              label: l10n.socialMatchEmptySecondary,
              tone: VibraButtonTone.text,
              expanded: true,
              onPressed: onRescan,
            ),
          ],
        ),
      ),
    );
  }
}
