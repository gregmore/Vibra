import 'package:vibra/presentation/localization/user_facing_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../core/theme/vibra_theme_tokens.dart';
import '../../core/theme/vibra_text_styles.dart';
import '../../core/theme/vibra_spacing.dart';
import 'package:vibra/l10n/app_localizations.dart';

class EmailAuthSheet extends ConsumerStatefulWidget {
  const EmailAuthSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EmailAuthSheet(),
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
  bool _obscurePassword = true;
  bool _ageConfirmed = false;

  // Focus nodes per glow effect
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _usernameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Forza rebuild per glow sui focus
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
    _usernameFocus.addListener(() => setState(() {}));
  }

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

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData prefixIcon,
    required bool hasFocus,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: hasFocus
            ? context.vibraTokens.accentPrimary
            : context.vibraTokens.textSecondary,
        fontWeight: hasFocus ? FontWeight.w500 : FontWeight.w400,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: hasFocus
            ? context.vibraTokens.accentPrimary
            : context.vibraTokens.textSecondary,
        size: 20,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: hasFocus
          ? context.vibraTokens.accentPrimary.withValues(alpha: 0.05)
          : context.vibraTokens.surfaceMuted,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
        borderSide: BorderSide(color: context.vibraTokens.borderDefault),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
        borderSide: BorderSide(
          color: context.vibraTokens.accentPrimary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
        borderSide: BorderSide(color: context.vibraTokens.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
        borderSide: BorderSide(color: context.vibraTokens.error, width: 1.5),
      ),
      errorStyle: TextStyle(color: context.vibraTokens.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(generalAuthProvider);
    final isKeyboard = MediaQuery.of(context).viewInsets.bottom > 0;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.vibraTokens.backgroundPrimary,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(VibraSpacing.radiusXL),
          ),
          border: Border(
            top: BorderSide(
              color: context.vibraTokens.borderDefault,
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: context.vibraTokens.accentPrimary.withValues(alpha: 0.1),
              blurRadius: 40,
              spreadRadius: 0,
              offset: Offset(0, -10),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Drag handle ──────────────────────────────────
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.vibraTokens.textSecondary.withValues(
                          alpha: 0.2,
                        ),
                        context.vibraTokens.textSecondary.withValues(
                          alpha: 0.4,
                        ),
                        context.vibraTokens.textSecondary.withValues(
                          alpha: 0.2,
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms),

              SizedBox(height: 24),

              // ── Titolo ───────────────────────────────────────
              AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: Text(
                      _isSignUp
                          ? l10n.authCreateAccount
                          : l10n.authLoginWithEmail,
                      key: ValueKey(_isSignUp),
                      style: VibraTextStyles.displaySmall.copyWith(
                        color: context.vibraTokens.textPrimary,
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms)
                  .slideY(begin: 0.15, end: 0, delay: 100.ms, duration: 400.ms),

              SizedBox(height: 8),

              // ── Sottotitolo ──────────────────────────────────
              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: Text(
                  _isSignUp
                      ? l10n.authEmailRegisterSubtitle
                      : l10n.authEmailLoginSubtitle,
                  key: ValueKey('sub_$_isSignUp'),
                  style: VibraTextStyles.bodyMedium.copyWith(
                    color: context.vibraTokens.textSecondary,
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              SizedBox(height: 28),

              // ── Form ─────────────────────────────────────────
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ── Username (solo signup) ──────────────────
                    AnimatedSize(
                      duration: Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      child: _isSignUp
                          ? Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      VibraSpacing.radiusMedium,
                                    ),
                                    boxShadow: _usernameFocus.hasFocus
                                        ? [
                                            BoxShadow(
                                              color: context
                                                  .vibraTokens
                                                  .accentPrimary
                                                  .withValues(alpha: 0.15),
                                              blurRadius: 12,
                                              spreadRadius: 0,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: TextFormField(
                                    controller: _usernameController,
                                    focusNode: _usernameFocus,
                                    style: TextStyle(
                                      color: context.vibraTokens.textPrimary,
                                    ),
                                    decoration: _buildInputDecoration(
                                      label: l10n.authUsername,
                                      prefixIcon: Icons.person_outline_rounded,
                                      hasFocus: _usernameFocus.hasFocus,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return l10n.authUsernameHint;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(height: 16),
                              ],
                            )
                          : SizedBox.shrink(),
                    ),

                    // ── Email ──────────────────────────────────
                    Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              VibraSpacing.radiusMedium,
                            ),
                            boxShadow: _emailFocus.hasFocus
                                ? [
                                    BoxShadow(
                                      color: context.vibraTokens.accentPrimary
                                          .withValues(alpha: 0.15),
                                      blurRadius: 12,
                                      spreadRadius: 0,
                                    ),
                                  ]
                                : null,
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              color: context.vibraTokens.textPrimary,
                            ),
                            decoration: _buildInputDecoration(
                              label: l10n.authEmail,
                              prefixIcon: Icons.email_outlined,
                              hasFocus: _emailFocus.hasFocus,
                            ),
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
                        )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 400.ms)
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          delay: 300.ms,
                          duration: 400.ms,
                        ),

                    SizedBox(height: 16),

                    if (_isSignUp)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _ageConfirmed,
                        activeColor: context.vibraTokens.accentPrimary,
                        onChanged: (value) =>
                            setState(() => _ageConfirmed = value ?? false),
                        title: Text(
                          l10n.authAgeConfirmation,
                          style: TextStyle(
                            color: context.vibraTokens.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          l10n.authAgeExplanation,
                          style: TextStyle(
                            color: context.vibraTokens.textSecondary,
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),

                    // ── Password ────────────────────────────────
                    Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              VibraSpacing.radiusMedium,
                            ),
                            boxShadow: _passwordFocus.hasFocus
                                ? [
                                    BoxShadow(
                                      color: context.vibraTokens.accentPrimary
                                          .withValues(alpha: 0.15),
                                      blurRadius: 12,
                                      spreadRadius: 0,
                                    ),
                                  ]
                                : null,
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            obscureText: _obscurePassword,
                            style: TextStyle(
                              color: context.vibraTokens.textPrimary,
                            ),
                            decoration: _buildInputDecoration(
                              label: l10n.authPassword,
                              prefixIcon: Icons.lock_outline_rounded,
                              hasFocus: _passwordFocus.hasFocus,
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword
                                    ? l10n.authShowPassword
                                    : l10n.authHidePassword,
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: _passwordFocus.hasFocus
                                      ? context.vibraTokens.accentPrimary
                                      : context.vibraTokens.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
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
                        )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 400.ms)
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          delay: 400.ms,
                          duration: 400.ms,
                        ),

                    SizedBox(height: 32),

                    // ── Submit button con gradient ──────────────
                    SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient:
                                  authState.status == GeneralAuthStatus.loading
                                  ? null
                                  : context.vibraTokens.primaryGradient,
                              color:
                                  authState.status == GeneralAuthStatus.loading
                                  ? context.vibraTokens.surfaceMuted
                                  : null,
                              borderRadius: BorderRadius.circular(
                                VibraSpacing.radiusFull,
                              ),
                              boxShadow:
                                  authState.status != GeneralAuthStatus.loading
                                  ? [
                                      BoxShadow(
                                        color: context.vibraTokens.accentPrimary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 16,
                                        spreadRadius: 0,
                                        offset: Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(
                                  VibraSpacing.radiusFull,
                                ),
                                onTap:
                                    authState.status ==
                                        GeneralAuthStatus.loading
                                    ? null
                                    : _submit,
                                child: Center(
                                  child:
                                      authState.status ==
                                          GeneralAuthStatus.loading
                                      ? SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  context.vibraTokens.onAccent,
                                                ),
                                          ),
                                        )
                                      : Text(
                                          _isSignUp
                                              ? l10n.authRegister
                                              : l10n.authLogin,
                                          style: VibraTextStyles.labelLarge
                                              .copyWith(
                                                color: context
                                                    .vibraTokens
                                                    .onAccent,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.5,
                                              ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 400.ms)
                        .slideY(
                          begin: 0.15,
                          end: 0,
                          delay: 500.ms,
                          duration: 400.ms,
                        ),

                    SizedBox(height: 16),

                    // ── Toggle signup/login ─────────────────────
                    TextButton(
                      onPressed: () => setState(() => _isSignUp = !_isSignUp),
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 250),
                        child: Text(
                          _isSignUp
                              ? l10n.authAlreadyHaveAccount
                              : l10n.authDontHaveAccount,
                          key: ValueKey('toggle_$_isSignUp'),
                          style: VibraTextStyles.bodyMedium.copyWith(
                            color: context.vibraTokens.accentPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

                    if (isKeyboard) SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
