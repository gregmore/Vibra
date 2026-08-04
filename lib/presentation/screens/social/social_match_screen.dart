import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/vibra_colors.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../providers/app_state_providers.dart';
import '../../widgets/common/vibra_logo.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/vibra_arc_gauge.dart';
import '../../widgets/vibra_match_comparison.dart';
import '../../widgets/vibra_pill_button.dart';
import 'package:vibra/l10n/app_localizations.dart';

class SocialMatchScreen extends ConsumerStatefulWidget {
  const SocialMatchScreen({super.key});

  @override
  ConsumerState<SocialMatchScreen> createState() => _SocialMatchScreenState();
}

class _SocialMatchScreenState extends ConsumerState<SocialMatchScreen> {
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  void _startScanning() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    });
  }

  void _sendVibra(MatchedUserPreview match) {
    ref.read(matchedUsersProvider.notifier).sendVibra(match.user.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.socialMatchVibraSent(match.user.displayName ?? match.user.username)),
        backgroundColor: VibraColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _passMatch(MatchedUserPreview match) {
    ref.read(matchedUsersProvider.notifier).passMatch(match.user.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(myProfileProvider);
    final matches = ref.watch(matchedUsersProvider);
    
    return VibraPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: _isScanning 
              ? _buildScanningState(theme)
              : matches.isNotEmpty
                  ? _buildMatchStack(context, theme, profile.avatarUrl ?? '', matches)
                  : _buildEmptyState(context, theme),
        ),
      ),
    );
  }

  Widget _buildScanningState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing concentric radar rings
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: VibraColors.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat())
               .scale(begin: const Offset(0.6, 0.6), end: const Offset(1.3, 1.3), duration: 1800.ms, curve: Curves.easeOut)
               .fadeOut(duration: 1800.ms),

              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: VibraColors.accent.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat())
               .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.2, 1.2), delay: 400.ms, duration: 1800.ms, curve: Curves.easeOut)
               .fadeOut(delay: 400.ms, duration: 1800.ms),

              // Logo in the middle
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: VibraColors.surfaceElevated,
                  shape: BoxShape.circle,
                  border: Border.all(color: VibraColors.glassBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x608B5CF6),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const VibraLogo(width: 56, height: 56),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            AppLocalizations.of(context)!.socialMatchScanningTitle,
            style: VibraTextStyles.labelLarge.copyWith(
              color: VibraColors.accent,
              letterSpacing: 4.0,
              fontWeight: FontWeight.w700,
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 1.seconds),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.socialMatchScanningSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: VibraColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMatchStack(BuildContext context, ThemeData theme, String myAvatar, List<MatchedUserPreview> matches) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (matches.length > 1)
          Positioned.fill(
            child: Transform.scale(
              scale: 0.92,
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: 0.6,
                child: AbsorbPointer(
                  child: _buildMatchCard(context, theme, myAvatar, matches[1]),
                ),
              ),
            ),
          ),
          
        Positioned.fill(
          child: Dismissible(
            key: ValueKey(matches.first.user.id),
            direction: DismissDirection.horizontal,
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                _sendVibra(matches.first);
              } else {
                _passMatch(matches.first);
              }
            },
            child: _buildMatchCard(context, theme, myAvatar, matches.first),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchCard(BuildContext context, ThemeData theme, String myAvatar, MatchedUserPreview match) {
    final l10n = AppLocalizations.of(context)!;
    final scoreNormalized = match.compatibility / 100.0;
    final displayName = match.user.displayName ?? match.user.username;
    
    return Container(
      decoration: BoxDecoration(
        color: VibraColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: VibraColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          // Intestazione
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: VibraColors.accent.withValues(alpha: 0.15),
                borderRadius: VibraSpacing.borderFull,
                border: Border.all(color: VibraColors.accent.withValues(alpha: 0.3)),
              ),
              child: Text(
                l10n.socialMatchNewAffinity,
                style: VibraTextStyles.labelLarge.copyWith(
                  color: VibraColors.accent,
                  letterSpacing: 3.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.5, end: 0),
          ),
          const SizedBox(height: 16),
          
          // Contenuto scrollabile centrale per evitare overflow su schermi piccoli
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Widget ArcGauge al centro con MatchScore
                  Center(
                    child: VibraArcGauge(
                      score: scoreNormalized,
                      size: 180,
                      strokeWidth: 14,
                    ),
                  ).animate().scaleXY(begin: 0.8, end: 1.0, duration: 600.ms, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 16),
                  
                  // Widget Match Comparison
                  VibraMatchComparison(
                    myImageUrl: myAvatar,
                    theirImageUrl: match.user.avatarUrl ?? '',
                    theirDisplayName: displayName,
                    score: scoreNormalized,
                  ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 12),
                  
                  // Nome
                  Center(
                    child: Text(
                      displayName,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                  ),
                  const SizedBox(height: 12),
                  
                  // Motivazione del match
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: VibraColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
                      border: Border.all(color: VibraColors.glassBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.socialMatchWhyMatched,
                          style: VibraTextStyles.labelSmall.copyWith(
                            color: VibraColors.textSecondary,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (match.topArtists.isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(Icons.music_note_rounded, size: 16, color: VibraColors.accent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.socialMatchListenBoth(match.topArtists.take(2).join(", ")),
                                  style: VibraTextStyles.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 16, color: VibraColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.socialMatchCityEvents(match.city, match.attendingEvents.toString()),
                                style: VibraTextStyles.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                  
                  const SizedBox(height: 8),
                  
                  // Anteprima profilo button
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        context.pushNamed(RouteNames.userProfile, extra: match.user.id);
                      },
                      icon: const Icon(Icons.person_search_rounded, size: 18),
                      label: Text(AppLocalizations.of(context)!.socialMatchViewProfile),
                      style: TextButton.styleFrom(
                        foregroundColor: VibraColors.textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ).animate().fadeIn(delay: 550.ms),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Azioni
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bottone Passa
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: VibraColors.surfaceVariant,
                      shape: BoxShape.circle,
                      border: Border.all(color: VibraColors.glassBorder),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, size: 24),
                      color: VibraColors.textSecondary,
                      onPressed: () => _passMatch(match),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(AppLocalizations.of(context)!.socialMatchIgnore, style: VibraTextStyles.labelSmall.copyWith(color: VibraColors.textDisabled, fontSize: 10)),
                ],
              ).animate().fadeIn(delay: 600.ms),
              
              const SizedBox(width: 16),
              
              // Bottone Vibra
              Expanded(
                child: VibraPillButton(
                  text: l10n.socialMatchSendVibra,
                  icon: Icons.graphic_eq_rounded,
                  isPrimary: true,
                  onPressed: () => _sendVibra(match),
                ).animate().fadeIn(delay: 600.ms).scaleXY(begin: 0.9, end: 1.0),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: VibraEmptyView(
        title: l10n.socialMatchEmptyTitle,
        message: l10n.socialMatchEmptyMessage,
        icon: Icons.radar_rounded,
        actionLabel: l10n.socialMatchEmptyAction,
        onActionTap: () => context.go('/explore'),
        secondaryActionLabel: l10n.socialMatchEmptySecondary,
        onSecondaryActionTap: () {
          ref.invalidate(matchedUsersProvider);
          setState(() {
            _isScanning = true;
          });
          _startScanning();
        },
      ),
    );
  }
}
