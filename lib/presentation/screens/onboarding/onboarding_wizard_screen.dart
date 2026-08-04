import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/vibra_colors.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/spotify_auth_provider.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/shared/user_avatar.dart';

class OnboardingWizardScreen extends ConsumerStatefulWidget {
  const OnboardingWizardScreen({super.key});

  @override
  ConsumerState<OnboardingWizardScreen> createState() =>
      _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState
    extends ConsumerState<OnboardingWizardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 6;

  // Step 2: Username
  final TextEditingController _usernameController = TextEditingController();
  bool _isUsernameValid = false;
  bool _isCheckingUsername = false;
  String? _usernameError;
  Timer? _debounceTimer;

  // Step 3: Avatar
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(myProfileProvider);
      _usernameController.text = profile.username;
      _validateUsername(profile.username);

      // Resume from saved step if needed
      if (profile.onboardingStep != null) {
        int initialPage = 0;
        switch (profile.onboardingStep) {
          case 'username':
            initialPage = 1;
            break;
          case 'avatar':
            initialPage = 2;
            break;
          case 'spotify':
            initialPage = 3;
            break;
          case 'location':
            initialPage = 4;
            break;
          case 'notifications':
            initialPage = 5;
            break;
        }
        if (initialPage > 0) {
          _pageController.jumpToPage(initialPage);
          setState(() {
            _currentPage = initialPage;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _pageController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _nextPage(String stepName) {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
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
        _usernameError = 'Minimo 3 caratteri';
      });
      return;
    }

    final isAlphanumeric = RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(trimmed);
    if (!isAlphanumeric) {
      setState(() {
        _isUsernameValid = false;
        _isCheckingUsername = false;
        _usernameError = 'Solo lettere, numeri e underscore';
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
            .from('users')
            .select('id')
            .eq('username', trimmed)
            .neq('id', currentUserId ?? '')
            .maybeSingle();

        if (mounted) {
          setState(() {
            _isCheckingUsername = false;
            if (res != null) {
              _isUsernameValid = false;
              _usernameError = 'Username già in uso';
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
            _usernameError = 'Errore di connessione';
          });
        }
      }
    });
  }

  Widget _buildHeader() {
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
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? VibraColors.primary
                      : VibraColors.glassBorder,
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
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildWelcomeStep(),
                  _buildUsernameStep(),
                  _buildAvatarStep(),
                  _buildSpotifyStep(),
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

  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(VibraSpacing.pagePadding),
      child: Column(
        children: [
          const Spacer(),
          const Icon(
            Icons.graphic_eq_rounded,
            size: 80,
            color: VibraColors.primary,
          ),
          const SizedBox(height: VibraSpacing.xl),
          Text(
            'Benvenuto in Vibra',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: VibraSpacing.md),
          Text(
            'Scopri eventi musicali vicini a te e connettiti con persone che hanno i tuoi stessi gusti.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: VibraColors.textSecondary),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _nextPage('username'),
              child: const Text('Iniziamo'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameStep() {
    return Padding(
      padding: const EdgeInsets.all(VibraSpacing.pagePadding),
      child: Column(
        children: [
          const Spacer(),
          Text(
            'Scegli il tuo Username',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: VibraSpacing.xl),
          TextField(
            controller: _usernameController,
            onChanged: _validateUsername,
            decoration: InputDecoration(
              labelText: 'Username',
              errorText: _usernameError,
              prefixIcon: const Icon(Icons.alternate_email_rounded),
              suffixIcon: _isCheckingUsername
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : (_isUsernameValid
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green,
                          )
                        : null),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isUsernameValid && !_isCheckingUsername
                  ? () async {
                      await ref
                          .read(myProfileProvider.notifier)
                          .updateProfile(
                            username: _usernameController.text.trim(),
                            onboardingStep: 'avatar',
                          );
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  : null,
              child: const Text('Continua'),
            ),
          ),
          const SizedBox(height: VibraSpacing.md),
          TextButton(
            onPressed: _isUsernameValid && !_isCheckingUsername
                ? () async {
                    await ref
                        .read(myProfileProvider.notifier)
                        .updateProfile(
                          username: _usernameController.text.trim(),
                        );
                    _finishOnboarding();
                  }
                : null,
            child: const Text('Salta il resto e vai alla Home'),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarStep() {
    final profile = ref.watch(myProfileProvider);
    return Padding(
      padding: const EdgeInsets.all(VibraSpacing.pagePadding),
      child: Column(
        children: [
          const Spacer(),
          Text(
            'Aggiungi una Foto',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: VibraSpacing.xl),
          GestureDetector(
            onTap: _isUploadingAvatar
                ? null
                : () async {
                    try {
                      final picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
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
                          const SnackBar(
                            content: Text(
                              'Permesso negato o errore nella selezione foto.',
                            ),
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isUploadingAvatar = false);
                      }
                    }
                  },
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                UserAvatar(
                  name: profile.username,
                  avatarUrl: profile.avatarUrl,
                  radius: 60,
                ),
                if (_isUploadingAvatar)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                if (!_isUploadingAvatar)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: VibraColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: profile.avatarUrl != null
                ? FilledButton(
                    onPressed: () => _nextPage('spotify'),
                    child: const Text('Continua'),
                  )
                : FilledButton.tonal(
                    onPressed: () => _nextPage('spotify'),
                    child: const Text('Salta per ora'),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotifyStep() {
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
          const Icon(
            Icons.music_note_rounded,
            size: 80,
            color: VibraColors.primary,
          ),
          const SizedBox(height: VibraSpacing.xl),
          Text(
            'Collega Spotify',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: VibraSpacing.md),
          Text(
            'Trova eventi basati sui tuoi ascolti e scopri la tua affinità musicale con gli altri utenti.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: VibraColors.textSecondary),
          ),
          if (spotifyState.status == SpotifyAuthStatus.userCancelled ||
              spotifyState.status == SpotifyAuthStatus.error) ...[
            const SizedBox(height: VibraSpacing.md),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: VibraColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                spotifyState.status == SpotifyAuthStatus.userCancelled
                    ? 'Collegamento annullato. Puoi riprovare o saltare per ora.'
                    : 'Errore durante il collegamento. Riprova più tardi.',
                style: const TextStyle(color: VibraColors.error, fontSize: 13),
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
                child: isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Collega Spotify'),
              ),
            ),
            const SizedBox(height: VibraSpacing.sm),
          ],
          SizedBox(
            width: double.infinity,
            child: hasSpotify
                ? FilledButton(
                    onPressed: () => _nextPage('location'),
                    child: const Text('Continua'),
                  )
                : FilledButton.tonal(
                    onPressed: isProcessing
                        ? null
                        : () => _nextPage('location'),
                    child: const Text('Salta'),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStep() {
    return Padding(
      padding: const EdgeInsets.all(VibraSpacing.pagePadding),
      child: Column(
        children: [
          const Spacer(),
          const Icon(
            Icons.location_on_rounded,
            size: 80,
            color: VibraColors.primary,
          ),
          const SizedBox(height: VibraSpacing.xl),
          Text(
            'Eventi vicino a te',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: VibraSpacing.md),
          Text(
            'Attiva la posizione per scoprire i concerti e i locali nella tua zona.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: VibraColors.textSecondary),
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

                  if (permission == LocationPermission.deniedForever &&
                      mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Permesso negato permanentemente. Puoi abilitarlo in seguito nelle Impostazioni.',
                        ),
                      ),
                    );
                  }
                }
                _nextPage('notifications');
              },
              child: const Text('Consenti Posizione'),
            ),
          ),
          const SizedBox(height: VibraSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: () => _nextPage('notifications'),
              child: const Text('Non ora'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationStep() {
    return Padding(
      padding: const EdgeInsets.all(VibraSpacing.pagePadding),
      child: Column(
        children: [
          const Spacer(),
          const Icon(
            Icons.notifications_active_rounded,
            size: 80,
            color: VibraColors.primary,
          ),
          const SizedBox(height: VibraSpacing.xl),
          Text(
            'Rimani aggiornato',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: VibraSpacing.md),
          Text(
            'Ricevi notifiche quando i tuoi artisti preferiti suonano in città o quando ricevi un messaggio.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: VibraColors.textSecondary),
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
                    const SnackBar(
                      content: Text(
                        'Notifiche negate. Non riceverai avvisi sui nuovi eventi.',
                      ),
                    ),
                  );
                }
                _finishOnboarding();
              },
              child: const Text('Attiva Notifiche'),
            ),
          ),
          const SizedBox(height: VibraSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: () => _finishOnboarding(),
              child: const Text('Non ora'),
            ),
          ),
        ],
      ),
    );
  }
}
