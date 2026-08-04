import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../core/theme/vibra_colors.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../widgets/vibra_glassmorphic_card.dart';
import '../../widgets/email_auth_sheet.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(generalAuthProvider);
    final isLoading = authState.status == GeneralAuthStatus.loading;
    final l10n = AppLocalizations.of(context)!;

    // Se l'utente si è autenticato con successo tramite OAuth, il router si accorge
    // del cambio di sessione di Supabase e lo reindirizza in automatico, ma
    // gestiamo un pop ed eventuale re-routing manuale sul successo per sicurezza.
    ref.listen(generalAuthProvider, (previous, next) {
      if (next.status == GeneralAuthStatus.authenticated) {
        context.go('/home');
      } else if (next.status == GeneralAuthStatus.error) {
        final isSuccessInfo = next.errorMessage?.contains('Registrazione completata') ?? false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? l10n.authFailed),
            backgroundColor: isSuccessInfo ? VibraColors.green : VibraColors.error,
            duration: Duration(seconds: isSuccessInfo ? 6 : 4),
          ),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              gradient: VibraColors.backgroundGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(VibraSpacing.pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/welcome');
                        }
                      },
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    ),
                    const Spacer(),
                    Text(
                      l10n.loginTitle,
                      style: VibraTextStyles.displayMedium.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: VibraSpacing.sm),
                    Text(
                      l10n.loginSubtitle,
                      style: VibraTextStyles.bodyLarge.copyWith(
                        color: VibraColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: VibraSpacing.xl),
                    VibraGlassmorphicCard(
                      child: Column(
                        children: [
                          _AuthButton(
                            label: l10n.loginWithGoogle,
                            icon: Icons.mail_outline_rounded,
                            bgColor: VibraColors.surfaceElevated,
                            onTap: () => ref.read(generalAuthProvider.notifier).signInWithGoogle(),
                          ),
                          const SizedBox(height: VibraSpacing.sm),
                          _AuthButton(
                            label: l10n.loginWithEmail,
                            icon: Icons.alternate_email_rounded,
                            bgColor: VibraColors.surfaceElevated,
                            onTap: () => EmailAuthSheet.show(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: VibraSpacing.md),
                    Text(
                      l10n.loginConsent,
                      style: VibraTextStyles.bodySmall.copyWith(
                        color: VibraColors.textSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(VibraColors.accent),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.bgColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonal(
        style: FilledButton.styleFrom(
          backgroundColor: bgColor ?? VibraColors.surfaceVariant,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VibraSpacing.radiusFull),
          ),
        ),
        onPressed: onTap,
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: VibraSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: VibraTextStyles.labelLarge.copyWith(color: Colors.white),
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
