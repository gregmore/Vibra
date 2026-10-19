import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/profile_photo_provider.dart';
import '../../providers/spotify_auth_provider.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/shared/user_avatar.dart';

class OnboardingWizardScreen extends ConsumerStatefulWidget {
  const OnboardingWizardScreen({super.key});

  @override
  ConsumerState<OnboardingWizardScreen> createState() =>
      _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends ConsumerState<OnboardingWizardScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int get _totalPages => AppConstants.spotifyEnabled ? 5 : 4;

  // Step 2: Profilo completo
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _displayNameFocus = FocusNode();
  final FocusNode _bioFocus = FocusNode();

  bool _isUsernameValid = false;
  bool _isCheckingUsername = false;
  String? _usernameError;
  Timer? _debounceTimer;
  bool _isUploadingAvatar = false;

  // Animation controllers
  late AnimationController _avatarPulseController;
  late Animation<double> _avatarPulseAnim;
  late AnimationController _fieldsSlideController;
  late Animation<Offset> _fieldsSlideAnim;
  late Animation<double> _fieldsFadeAnim;

  @override
  void initState() {
    super.initState();

    _avatarPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _avatarPulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _avatarPulseController, curve: Curves.easeInOut),
    );

    _fieldsSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fieldsSlideAnim =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _fieldsSlideController,
            curve: Curves.easeOutCubic,
          ),
        );
    _fieldsFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fieldsSlideController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(myProfileProvider);
      _usernameController.text = profile.username;
      _displayNameController.text = profile.displayName ?? '';
      _bioController.text = profile.bio ?? '';
      _validateUsername(profile.username);

      // Resume from saved step if needed
      if (profile.onboardingStep != null) {
        int initialPage = 0;
        switch (profile.onboardingStep) {
          case 'profile':
            initialPage = 1;
            break;
          case 'spotify':
            initialPage = 2;
            break;
          case 'location':
            initialPage = AppConstants.spotifyEnabled ? 3 : 2;
            break;
          case 'notifications':
            initialPage = AppConstants.spotifyEnabled ? 4 : 3;
            break;
        }
        if (initialPage > 0) {
          _pageController.jumpToPage(initialPage);
          setState(() {
            _currentPage = initialPage;
          });
        }
      }

      if (_currentPage == 1) {
        _fieldsSlideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _pageController.dispose();
    _usernameController.dispose();
    _displayNameController.dispose();
    _bioController.dispose();
    _usernameFocus.dispose();
    _displayNameFocus.dispose();
    _bioFocus.dispose();
    _avatarPulseController.dispose();
    _fieldsSlideController.dispose();
    super.dispose();
  }

  void _nextPage(String stepName) {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      ref
          .read(myProfileProvider.notifier)
          .updateProfile(onboardingStep: stepName);
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() async {
    await ref
        .read(myProfileProvider.notifier)
        .updateProfile(onboardingCompleted: true, onboardingStep: 'done');
    if (mounted) context.go('/home');
  }

  Future<void> _validateUsername(String value) async {
    _debounceTimer?.cancel();
    final trimmed = value.trim();

    if (trimmed.isEmpty || trimmed.length < 3) {
      setState(() {
        _isUsernameValid = false;
        _isCheckingUsername = false;
        _usernameError = trimmed.isEmpty
            ? null
            : AppLocalizations.of(context)!.profileUsernameShort;
      });
      return;
    }

    final isAlphanumeric = RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(trimmed);
    if (!isAlphanumeric) {
      setState(() {
        _isUsernameValid = false;
        _isCheckingUsername = false;
        _usernameError = AppLocalizations.of(
          context,
        )!.profileUsernameCharactersOnboarding;
      });
      return;
    }

    setState(() {
      _isCheckingUsername = true;
      _usernameError = null;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final currentUserId = Supabase.instance.client.auth.currentUser?.id;
        final res = await Supabase.instance.client
            .from('users_public')
            .select('id')
            .eq('username', trimmed)
            .neq('id', currentUserId ?? '00000000-0000-0000-0000-000000000000')
            .maybeSingle();

        if (mounted) {
          setState(() {
            _isCheckingUsername = false;
            if (res != null) {
              _isUsernameValid = false;
              _usernameError = AppLocalizations.of(
                context,
              )!.profileUsernameTaken;
            } else {
              _isUsernameValid = true;
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isCheckingUsername = false;
            _isUsernameValid = false;
            _usernameError = AppLocalizations.of(
              context,
            )!.commonConnectionError;
          });
        }
      }
    });
  }

  Future<void> _pickAvatar() async {
    if (_isUploadingAvatar) return;
    setState(() => _isUploadingAvatar = true);
    try {
      final picker = ref.read(profileImagePickerProvider);
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
        requestFullMetadata: false,
      );
      if (image != null && mounted) {
        setState(() => _isUploadingAvatar = true);
        await ref
            .read(myProfileProvider.notifier)
            .updateProfile(avatarUrl: image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.profilePhotoPickError),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Widget _buildHeader() {
    final t = context.vibraTokens;
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalPages, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 28 : 8,
                decoration: BoxDecoration(
                  gradient: _currentPage == index ? t.primaryGradient : null,
                  color: _currentPage == index ? null : t.borderStrong,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
        if (_currentPage > 0)
          Positioned(
            left: 8,
            child: IconButton(
              tooltip: AppLocalizations.of(context)!.onboardingBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return VibraPageScaffold(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: VibraSpacing.md),
            _buildHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  if (index == 1) {
                    _fieldsSlideController.forward(from: 0);
                    _avatarPulseController.repeat(reverse: true);
                  } else {
                    _avatarPulseController.stop();
                  }
                },
                children: [
                  _buildWelcomeStep(),
                  _buildProfileSetupStep(),
                  if (AppConstants.spotifyEnabled) _buildSpotifyStep(),
                  _buildLocationStep(),
                  _buildNotificationStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Step 1: Benvenuto ───────────────────────────────────────────────────

  Widget _buildWelcomeStep() {
    final t = context.vibraTokens;
    return Padding(
      padding: const EdgeInsets.all(VibraSpacing.pagePadding),
      child: Column(
        children: [
          const Spacer(),
          // Icona con glow
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: t.primaryGradient,
              boxShadow: [t.elevatedShadow],
            ),
            child: Icon(Icons.graphic_eq_rounded, size: 52, color: t.onAccent),
          ),
          const SizedBox(height: VibraSpacing.xxl),
          Text(
            AppLocalizations.of(context)!.welcomeTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: VibraSpacing.md),
          Text(
            AppLocalizations.of(context)!.launchExploreBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: t.textSecondary,
              height: 1.6,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _nextPage('profile'),
              child: Text(AppLocalizations.of(context)!.onboardingStart),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 2: Completamento Profilo (UI principale) ───────────────────────

  Widget _buildProfileSetupStep() {
    final t = context.vibraTokens;
    final profile = ref.watch(myProfileProvider);
    final bool canProceed = _isUsernameValid && !_isCheckingUsername;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: VibraSpacing.pagePadding,
          vertical: VibraSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: VibraSpacing.md),

            // ── Titolo ──────────────────────────────────────
            Text(
              AppLocalizations.of(context)!.onboardingProfileTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: VibraSpacing.xs),
            Text(
              AppLocalizations.of(context)!.onboardingProfileBody,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
            ),
            const SizedBox(height: VibraSpacing.xxl),

            // ── Avatar ──────────────────────────────────────
            _buildAvatarPicker(profile),
            const SizedBox(height: VibraSpacing.xxxl),

            // ── Campi profilo ────────────────────────────────
            FadeTransition(
              opacity: _fieldsFadeAnim,
              child: SlideTransition(
                position: _fieldsSlideAnim,
                child: Column(
                  children: [
                    // Contenitore glassmorphism per i campi
                    _buildProfileCard(profile),
                    const SizedBox(height: VibraSpacing.xxl),

                    // Bottone principale
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: canProceed
                            ? () async {
                                await ref
                                    .read(myProfileProvider.notifier)
                                    .updateProfile(
                                      username: _usernameController.text.trim(),
                                      displayName:
                                          _displayNameController.text
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : _displayNameController.text.trim(),
                                      bio: _bioController.text.trim().isEmpty
                                          ? null
                                          : _bioController.text.trim(),
                                      onboardingStep:
                                          AppConstants.spotifyEnabled
                                          ? 'spotify'
                                          : 'location',
                                    );
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                        child: Text(
                          AppLocalizations.of(context)!.onboardingContinue,
                        ),
                      ),
                    ),
                    const SizedBox(height: VibraSpacing.md),
                    TextButton(
                      onPressed: canProceed
                          ? () async {
                              await ref
                                  .read(myProfileProvider.notifier)
                                  .updateProfile(
                                    username: _usernameController.text.trim(),
                                    displayName:
                                        _displayNameController.text
                                            .trim()
                                            .isEmpty
                                        ? null
                                        : _displayNameController.text.trim(),
                                    bio: _bioController.text.trim().isEmpty
                                        ? null
                                        : _bioController.text.trim(),
                                  );
                              _finishOnboarding();
                            }
                          : null,
                      child: Text(
                        AppLocalizations.of(context)!.onboardingSkipToHome,
                      ),
                    ),
                    const SizedBox(height: VibraSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPicker(dynamic profile) {
    final t = context.vibraTokens;
    return Semantics(
      button: true,
      label: _isUploadingAvatar
          ? AppLocalizations.of(context)!.onboardingPhotoUploading
          : AppLocalizations.of(context)!.onboardingPhotoSelect,
      child: Material(
        color: Colors.transparent,
        child: InkResponse(
          onTap: _pickAvatar,
          radius: 74,
          splashColor: t.accentPrimary.withValues(alpha: .16),
          hoverColor: t.accentPrimary.withValues(alpha: .08),
          focusColor: t.accentPrimary.withValues(alpha: .12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow esterno animato
              AnimatedBuilder(
                animation: _avatarPulseAnim,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _avatarPulseAnim.value,
                    child: Container(
                      width: 148,
                      height: 148,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: t.primaryGradient,
                        boxShadow: [t.elevatedShadow],
                      ),
                    ),
                  );
                },
              ),

              // Avatar principale
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: t.accentPrimary, width: 3),
                ),
                child: ClipOval(
                  child: _isUploadingAvatar
                      ? Container(
                          color: t.surfaceMuted,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: t.accentPrimary,
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                      : UserAvatar(
                          name: profile.username.isNotEmpty
                              ? profile.username
                              : profile.displayName ??
                                    AppLocalizations.of(context)!.userGeneric,
                          avatarUrl: profile.avatarUrl,
                          radius: 70,
                        ),
                ),
              ),

              // Badge fotocamera
              Positioned(
                bottom: 6,
                right: 6,
                child: _buildCameraBadge(profile),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraBadge(dynamic profile) {
    final t = context.vibraTokens;
    final hasAvatar = profile.avatarUrl != null;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: t.primaryGradient,
        boxShadow: [t.cardShadow],
        border: Border.all(color: t.backgroundPrimary, width: 2.5),
      ),
      child: Icon(
        hasAvatar ? Icons.edit_rounded : Icons.camera_alt_rounded,
        color: t.onAccent,
        size: 18,
      ),
    );
  }

  Widget _buildProfileCard(dynamic profile) {
    final t = context.vibraTokens;
    return Container(
      decoration: BoxDecoration(
        borderRadius: VibraSpacing.borderMedium,
        color: t.surfaceElevated,
        border: Border.all(color: t.borderDefault),
        boxShadow: [t.cardShadow],
      ),
      child: Column(
        children: [
          // ── Username ──
          _buildFieldTile(
            icon: Icons.alternate_email_rounded,
            label: AppLocalizations.of(context)!.authUsername,
            hint: AppLocalizations.of(context)!.onboardingUsernameExample,
            controller: _usernameController,
            focusNode: _usernameFocus,
            nextFocus: _displayNameFocus,
            onChanged: _validateUsername,
            errorText: _usernameError,
            isRequired: true,
            trailing: _isCheckingUsername
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: t.accentPrimary,
                    ),
                  )
                : _isUsernameValid
                ? Icon(Icons.check_circle_rounded, color: t.success, size: 20)
                : null,
            isLast: false,
          ),

          _buildDivider(),

          // ── Nome display ──
          _buildFieldTile(
            icon: Icons.person_rounded,
            label: AppLocalizations.of(context)!.profileName,
            hint: AppLocalizations.of(context)!.profileNameHint,
            controller: _displayNameController,
            focusNode: _displayNameFocus,
            nextFocus: _bioFocus,
            isRequired: false,
            isLast: false,
          ),

          _buildDivider(),

          // ── Bio ──
          _buildFieldTile(
            icon: Icons.edit_note_rounded,
            label: AppLocalizations.of(context)!.profileDescription,
            hint: AppLocalizations.of(context)!.profileDescriptionHint,
            controller: _bioController,
            focusNode: _bioFocus,
            maxLines: 3,
            maxLength: 150,
            isRequired: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    final t = context.vibraTokens;
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 52),
      color: t.borderDefault,
    );
  }

  Widget _buildFieldTile({
    required IconData icon,
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    ValueChanged<String>? onChanged,
    String? errorText,
    Widget? trailing,
    bool isRequired = false,
    bool isLast = false,
    int maxLines = 1,
    int? maxLength,
  }) {
    final t = context.vibraTokens;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: VibraSpacing.lg,
        vertical: VibraSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          // Icona
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 14.0 : 0),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: t.accentSoft,
                borderRadius: BorderRadius.circular(VibraSpacing.radiusSmall),
              ),
              child: Icon(icon, color: t.textPrimary, size: 18),
            ),
          ),
          const SizedBox(width: VibraSpacing.md),

          // Campo testo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: t.textSecondary,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: 3),
                      Text(
                        AppLocalizations.of(context)!.onboardingRequired,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: t.textSecondary,
                          letterSpacing: .4,
                        ),
                      ),
                    ],
                  ],
                ),
                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  maxLines: maxLines,
                  maxLength: maxLength,
                  textInputAction: isLast
                      ? TextInputAction.done
                      : TextInputAction.next,
                  onSubmitted: (_) {
                    if (nextFocus != null) {
                      FocusScope.of(context).requestFocus(nextFocus);
                    } else {
                      focusNode.unfocus();
                    }
                  },
                  onChanged: onChanged,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    counterText: maxLength != null ? null : '',
                    errorText: errorText,
                    errorStyle: TextStyle(
                      color: t.error,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Trailing icon (check / loading)
          if (trailing != null) ...[
            const SizedBox(width: VibraSpacing.sm),
            trailing,
          ],
        ],
      ),
    );
  }

  // ─── Step 3: Spotify ─────────────────────────────────────────────────────

  Widget _buildSpotifyStep() {
    final t = context.vibraTokens;
    const spotifyGreen = Color(0xFF1DB954);
    const onSpotify = Color(0xFF07170C);
    final profile = ref.watch(myProfileProvider);
    final spotifyState = ref.watch(spotifyAuthProvider);
    final hasSpotify =
        profile.spotifyId != null && profile.spotifyId!.isNotEmpty;

    final isProcessing =
        spotifyState.status == SpotifyAuthStatus.authorizing ||
        spotifyState.status == SpotifyAuthStatus.exchangingToken ||
        spotifyState.status == SpotifyAuthStatus.syncingProfile;

    return Padding(
      padding: const EdgeInsets.all(VibraSpacing.pagePadding),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.surfaceElevated,
              border: Border.all(color: spotifyGreen, width: 2),
              boxShadow: [t.cardShadow],
            ),
            child: const Icon(
              Icons.music_note_rounded,
              size: 48,
              color: spotifyGreen,
            ),
          ),
          const SizedBox(height: VibraSpacing.xl),
          Text(
            AppLocalizations.of(context)!.myProfileConnectSpotify,
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: VibraSpacing.md),
          Text(
            AppLocalizations.of(context)!.onboardingSpotifyBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: t.textSecondary,
              height: 1.6,
            ),
          ),
          if (spotifyState.status == SpotifyAuthStatus.userCancelled ||
              spotifyState.status == SpotifyAuthStatus.error) ...[
            const SizedBox(height: VibraSpacing.md),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: t.surfaceElevated,
                borderRadius: VibraSpacing.borderMedium,
                border: Border.all(color: t.error, width: 1.5),
              ),
              child: Text(
                spotifyState.status == SpotifyAuthStatus.userCancelled
                    ? AppLocalizations.of(context)!.onboardingSpotifyCancelled
                    : AppLocalizations.of(context)!.onboardingSpotifyError,
                style: TextStyle(
                  color: t.error,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const Spacer(),
          if (!hasSpotify) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isProcessing
                    ? null
                    : () {
                        ref.read(spotifyAuthProvider.notifier).connectSpotify();
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: spotifyGreen,
                  foregroundColor: onSpotify,
                ),
                child: isProcessing
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: onSpotify,
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)!.myProfileConnectSpotify,
                      ),
              ),
            ),
            const SizedBox(height: VibraSpacing.sm),
          ],
          SizedBox(
            width: double.infinity,
            child: hasSpotify
                ? FilledButton(
                    onPressed: () => _nextPage('location'),
                    child: Text(
                      AppLocalizations.of(context)!.onboardingContinue,
                    ),
                  )
                : FilledButton.tonal(
                    onPressed: isProcessing
                        ? null
                        : () => _nextPage('location'),
                    child: Text(AppLocalizations.of(context)!.commonSkip),
                  ),
          ),
        ],
      ),
    );
  }

  // ─── Step 4: Posizione ───────────────────────────────────────────────────

  Widget _buildLocationStep() {
    final t = context.vibraTokens;
    return Padding(
      padding: const EdgeInsets.all(VibraSpacing.pagePadding),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: t.primaryGradient,
              boxShadow: [t.elevatedShadow],
            ),
            child: Icon(Icons.location_on_rounded, size: 48, color: t.onAccent),
          ),
          const SizedBox(height: VibraSpacing.xl),
          Text(
            AppLocalizations.of(context)!.onboardingLocationTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: VibraSpacing.md),
          Text(
            AppLocalizations.of(context)!.onboardingLocationBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: t.textSecondary,
              height: 1.6,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                bool serviceEnabled =
                    await Geolocator.isLocationServiceEnabled();
                if (serviceEnabled) {
                  LocationPermission permission =
                      await Geolocator.checkPermission();
                  if (permission == LocationPermission.denied) {
                    permission = await Geolocator.requestPermission();
                  }

                  if (permission == LocationPermission.whileInUse ||
                      permission == LocationPermission.always) {
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user != null) {
                      await Supabase.instance.client
                          .from('privacy_preferences')
                          .upsert({
                            'user_id': user.id,
                            'location_processing': true,
                            'policy_version': '2026-08-27',
                            'updated_at': DateTime.now()
                                .toUtc()
                                .toIso8601String(),
                          });
                    }
                  }

                  if (permission == LocationPermission.deniedForever &&
                      mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(
                            context,
                          )!.onboardingLocationDenied,
                        ),
                      ),
                    );
                  }
                }
                _nextPage('notifications');
              },
              child: Text(
                AppLocalizations.of(context)!.onboardingAllowLocation,
              ),
            ),
          ),
          const SizedBox(height: VibraSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: () => _nextPage('notifications'),
              child: Text(AppLocalizations.of(context)!.commonNotNow),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 5: Notifiche ───────────────────────────────────────────────────

  Widget _buildNotificationStep() {
    final t = context.vibraTokens;
    return Padding(
      padding: const EdgeInsets.all(VibraSpacing.pagePadding),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: t.primaryGradient,
              boxShadow: [t.elevatedShadow],
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              size: 48,
              color: t.onAccent,
            ),
          ),
          const SizedBox(height: VibraSpacing.xl),
          Text(
            AppLocalizations.of(context)!.onboardingNotificationsTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: VibraSpacing.md),
          Text(
            AppLocalizations.of(context)!.onboardingNotificationsBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: t.textSecondary,
              height: 1.6,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                final messaging = FirebaseMessaging.instance;
                final settings = await messaging.requestPermission(
                  alert: true,
                  badge: true,
                  sound: true,
                );

                if (settings.authorizationStatus ==
                        AuthorizationStatus.denied &&
                    mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(
                          context,
                        )!.onboardingNotificationsDenied,
                      ),
                    ),
                  );
                }
                _finishOnboarding();
              },
              child: Text(
                AppLocalizations.of(context)!.onboardingAllowNotifications,
              ),
            ),
          ),
          const SizedBox(height: VibraSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: () => _finishOnboarding(),
              child: Text(AppLocalizations.of(context)!.commonNotNow),
            ),
          ),
        ],
      ),
    );
  }
}
