import 'package:vibra/presentation/localization/user_facing_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import 'spotify_unavailable_screen.dart';
import '../../widgets/vibra_glassmorphic_card.dart';
import '../../providers/spotify_auth_provider.dart';
import 'package:vibra/l10n/app_localizations.dart';

const _spotifyGreen = Color(0xFF1ED760);

class SpotifyConnectScreen extends ConsumerStatefulWidget {
  const SpotifyConnectScreen({super.key});

  @override
  ConsumerState<SpotifyConnectScreen> createState() =>
      _SpotifyConnectScreenState();
}

class _SpotifyConnectScreenState extends ConsumerState<SpotifyConnectScreen> {
  @override
  Widget build(BuildContext context) {
    if (!AppConstants.spotifyEnabled) return const SpotifyUnavailableScreen();
    final theme = Theme.of(context);
    final t = context.vibraTokens;
    final authState = ref.watch(spotifyAuthProvider);
    final status = authState.status;
    final hasUser = Supabase.instance.client.auth.currentUser != null;

    // Gestione degli step visivi
    final step1Active = status == SpotifyAuthStatus.authorizing;
    final step1Done =
        status == SpotifyAuthStatus.exchangingToken ||
        status == SpotifyAuthStatus.syncingProfile ||
        status == SpotifyAuthStatus.success;

    final step2Active = status == SpotifyAuthStatus.exchangingToken;
    final step2Done =
        status == SpotifyAuthStatus.syncingProfile ||
        status == SpotifyAuthStatus.success;

    final step3Active = status == SpotifyAuthStatus.syncingProfile;
    final step3Done = status == SpotifyAuthStatus.success;

    final isProcessing =
        status == SpotifyAuthStatus.authorizing ||
        status == SpotifyAuthStatus.exchangingToken ||
        status == SpotifyAuthStatus.syncingProfile;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [t.backgroundPrimary, t.backgroundSecondary],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Navigazione / Back
                if (!isProcessing && status != SpotifyAuthStatus.success)
                  IconButton(
                    tooltip: AppLocalizations.of(context)!.spotifyBackToLogin,
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/login');
                      }
                    },
                    icon: Icon(Icons.arrow_back_rounded, color: t.textPrimary),
                  )
                else
                  const SizedBox(
                    height: 48,
                  ), // Spazio placeholder per mantenere il layout

                const SizedBox(height: 16),

                // Titolo e sottotitolo principali
                Text(
                  AppLocalizations.of(context)!.spotifyConnectTitle,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade(duration: 400.ms).slideX(begin: -0.1, end: 0),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.spotifyConnectSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: t.textSecondary,
                    height: 1.5,
                  ),
                ).animate().fade(delay: 100.ms, duration: 400.ms),

                const SizedBox(height: 32),

                Text(
                  AppLocalizations.of(context)!.spotifyConsentBody,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: t.textSecondary,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 20),

                // Banner di errore o annullamento
                if (status == SpotifyAuthStatus.userCancelled)
                  _buildStatusBanner(
                    icon: Icons.info_outline_rounded,
                    color: t.warning,
                    message:
                        '${AppLocalizations.of(context)!.spotifyAuthCancelledTitle}\n${AppLocalizations.of(context)!.spotifyAuthCancelled}',
                  ).animate().shake(duration: 400.ms)
                else if (status == SpotifyAuthStatus.error)
                  _buildStatusBanner(
                    icon: Icons.error_outline_rounded,
                    color: t.error,
                    message:
                        '${AppLocalizations.of(context)!.errorTitle}\n${userFacingError(AppLocalizations.of(context)!, authState.errorMessage)}',
                  ).animate().shake(duration: 400.ms),

                if (status == SpotifyAuthStatus.userCancelled ||
                    status == SpotifyAuthStatus.error)
                  const SizedBox(height: 20),

                // Card principale degli step
                Expanded(
                  child: SingleChildScrollView(
                    child: VibraGlassmorphicCard(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.spotifyConnectOnboarding,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _SyncStep(
                              title: AppLocalizations.of(
                                context,
                              )!.spotifyAuthStep1Title,
                              subtitle: AppLocalizations.of(
                                context,
                              )!.spotifyAuthStep1Sub,
                              isActive: step1Active,
                              isDone: step1Done,
                            ),
                            const SizedBox(height: 20),
                            _SyncStep(
                              title: AppLocalizations.of(
                                context,
                              )!.spotifyAuthStep2Title,
                              subtitle: AppLocalizations.of(
                                context,
                              )!.spotifyAuthStep2Sub,
                              isActive: step2Active,
                              isDone: step2Done,
                            ),
                            const SizedBox(height: 20),
                            _SyncStep(
                              title: AppLocalizations.of(
                                context,
                              )!.spotifyAuthStep3Title,
                              subtitle: AppLocalizations.of(
                                context,
                              )!.spotifyAuthStep3Sub,
                              isActive: step3Active,
                              isDone: step3Done,
                              showMusicAnimation: step3Active,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fade(delay: 200.ms, duration: 400.ms),
                ),

                const SizedBox(height: 24),

                // Disclaimer sulla privacy
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 14,
                          color: t.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!.spotifyConnectPrivacyDesc,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: t.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Bottone di azione (CTA)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: status == SpotifyAuthStatus.success
                      ? ElevatedButton.icon(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/home');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _spotifyGreen,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: Text(
                            AppLocalizations.of(
                              context,
                            )!.spotifyConnectContinue,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ).animate().scale(
                          duration: 300.ms,
                          curve: Curves.easeOutBack,
                        )
                      : ElevatedButton(
                          onPressed: isProcessing
                              ? null
                              : () => ref
                                    .read(spotifyAuthProvider.notifier)
                                    .connectSpotify(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _spotifyGreen,
                            foregroundColor: Colors.black,
                            disabledBackgroundColor: t.surfaceMuted,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isProcessing
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      t.textDisabled,
                                    ),
                                  ),
                                )
                              : Text(
                                  status == SpotifyAuthStatus.error ||
                                          status ==
                                              SpotifyAuthStatus.userCancelled
                                      ? AppLocalizations.of(
                                          context,
                                        )!.spotifyConnectRetry
                                      : AppLocalizations.of(
                                          context,
                                        )!.spotifyConnectAction,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                ),
                if (hasUser &&
                    !isProcessing &&
                    status != SpotifyAuthStatus.success) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () => context.go('/home'),
                      style: TextButton.styleFrom(
                        foregroundColor: t.textSecondary,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.spotifyConnectSkip,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner({
    required IconData icon,
    required Color color,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncStep extends StatelessWidget {
  const _SyncStep({
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.isDone,
    this.showMusicAnimation = false,
  });

  final String title;
  final String subtitle;
  final bool isActive;
  final bool isDone;
  final bool showMusicAnimation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.vibraTokens;

    Widget buildLeading() {
      if (isDone) {
        return const Icon(
          Icons.check_circle_rounded,
          color: _spotifyGreen,
          size: 24,
        ).animate().scale(duration: 250.ms, curve: Curves.elasticOut);
      }
      if (isActive) {
        if (showMusicAnimation) {
          // Animazione di note musicali per la sincronizzazione dei gusti
          return SizedBox(
            width: 24,
            height: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                return Container(
                      width: 3,
                      height: 12,
                      decoration: BoxDecoration(
                        color: t.accentPrimary,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scaleY(
                      begin: 0.3,
                      end: 1.3,
                      duration: (400 + (index * 150)).ms,
                      curve: Curves.easeInOut,
                    );
              }),
            ),
          );
        }
        return SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(t.accentPrimary),
          ),
        );
      }
      return Icon(
        Icons.radio_button_off_rounded,
        color: t.textDisabled,
        size: 22,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(top: 2), child: buildLeading()),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isDone
                      ? t.textPrimary
                      : isActive
                      ? t.textPrimary
                      : t.textDisabled,
                  fontWeight: isActive || isDone
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDone
                      ? t.textSecondary
                      : isActive
                      ? t.textSecondary
                      : t.textDisabled,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
