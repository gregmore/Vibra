import 'package:vibra/presentation/localization/user_facing_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../core/theme/vibra_theme_tokens.dart';
import '../../core/theme/vibra_text_styles.dart';
import '../../core/theme/vibra_motion.dart';
import '../../core/theme/vibra_spacing.dart';
import 'common/vibra_bottom_sheet.dart';
import 'common/vibra_button.dart';
import 'common/vibra_input.dart';
import 'common/vibra_surface.dart';
import 'package:vibra/l10n/app_localizations.dart';

class EmailAuthSheet extends ConsumerStatefulWidget {
  const EmailAuthSheet({super.key});

  static Future<void> show(BuildContext context) {
    return VibraBottomSheet.show<void>(
      context,
      builder: (context) => const EmailAuthSheet(),
    );
  }

  @override
  ConsumerState<EmailAuthSheet> createState() => _EmailAuthSheetState();
}

class _EmailAuthSheetState extends ConsumerState<EmailAuthSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  bool _isSignUp = false;
  bool _ageConfirmed = false;

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _usernameFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _usernameFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSignUp && !_ageConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.authAgeRequired)),
      );
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final username = _usernameController.text.trim();

    final notifier = ref.read(generalAuthProvider.notifier);

    if (_isSignUp) {
      await notifier.signUpWithEmail(
        email,
        password,
        username,
        ageConfirmed: true,
      );
    } else {
      await notifier.signInWithEmail(email, password);
    }

    if (!mounted) return;
    final authState = ref.read(generalAuthProvider);
    if (authState.status == GeneralAuthStatus.authenticated) {
      if (mounted) {
        Navigator.pop(context);
        context.go('/home');
      }
    } else if (authState.status == GeneralAuthStatus.error) {
      if (mounted) {
        final isSuccessInfo = isRegistrationConfirmation(
          authState.errorMessage,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              userFacingError(
                AppLocalizations.of(context)!,
                authState.errorMessage,
              ),
            ),
            backgroundColor: isSuccessInfo
                ? context.vibraTokens.success
                : context.vibraTokens.error,
            duration: Duration(seconds: isSuccessInfo ? 6 : 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(generalAuthProvider);
    final loading = authState.status == GeneralAuthStatus.loading;
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final switchDuration = VibraMotion.durationFor(context, VibraMotion.medium);

    return VibraBottomSheet(
      child: SingleChildScrollView(
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedSwitcher(
                  duration: switchDuration,
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.topLeft,
                    children: [...previous, ?current],
                  ),
                  child: Column(
                    key: ValueKey(_isSignUp),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          _isSignUp
                              ? l10n.authCreateAccount
                              : l10n.authLoginWithEmail,
                          style: VibraTextStyles.headlineLarge.copyWith(
                            color: t.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: VibraSpacing.sm),
                      Text(
                        _isSignUp
                            ? l10n.authEmailRegisterSubtitle
                            : l10n.authEmailLoginSubtitle,
                        style: VibraTextStyles.bodyMedium.copyWith(
                          color: t.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: VibraSpacing.xxl),
                AnimatedSize(
                  duration: switchDuration,
                  curve: VibraMotion.signalCurve,
                  alignment: Alignment.topCenter,
                  child: _isSignUp
                      ? Padding(
                          padding: const EdgeInsets.only(
                            bottom: VibraSpacing.lg,
                          ),
                          child: VibraTextField(
                            controller: _usernameController,
                            focusNode: _usernameFocus,
                            hintText: l10n.authUsername,
                            prefixIcon: Icons.person_outline_rounded,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newUsername],
                            onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.authUsernameHint;
                              }
                              return null;
                            },
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
                VibraTextField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  hintText: l10n.authEmail,
                  prefixIcon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.authEmailHint;
                    }
                    if (!value.contains('@')) {
                      return l10n.authEmailInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: VibraSpacing.lg),
                VibraTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  hintText: l10n.authPassword,
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: true,
                  visibilityToggleLabel: l10n.authShowPassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: [
                    _isSignUp
                        ? AutofillHints.newPassword
                        : AutofillHints.password,
                  ],
                  onFieldSubmitted: (_) => loading ? null : _submit(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.authPasswordHint;
                    }
                    if (value.length < 6) {
                      return l10n.authPasswordShort;
                    }
                    return null;
                  },
                ),
                if (_isSignUp) ...[
                  const SizedBox(height: VibraSpacing.md),
                  VibraSurface(
                    padding: const EdgeInsets.symmetric(
                      horizontal: VibraSpacing.sm,
                      vertical: VibraSpacing.xs,
                    ),
                    radius: VibraSpacing.radiusMedium,
                    child: CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _ageConfirmed,
                      onChanged: (value) =>
                          setState(() => _ageConfirmed = value ?? false),
                      title: Text(
                        l10n.authAgeConfirmation,
                        style: VibraTextStyles.titleSmall.copyWith(
                          color: t.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        l10n.authAgeExplanation,
                        style: VibraTextStyles.bodySmall.copyWith(
                          color: t.textSecondary,
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                ],
                const SizedBox(height: VibraSpacing.xxl),
                VibraPrimaryButton(
                  label: _isSignUp ? l10n.authRegister : l10n.authLogin,
                  loading: loading,
                  onPressed: loading ? null : _submit,
                ),
                const SizedBox(height: VibraSpacing.sm),
                TextButton(
                  onPressed: loading
                      ? null
                      : () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(
                    _isSignUp
                        ? l10n.authAlreadyHaveAccount
                        : l10n.authDontHaveAccount,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
