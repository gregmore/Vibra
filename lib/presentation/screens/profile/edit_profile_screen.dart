import 'package:vibra/l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/profile_photo_provider.dart';
import '../../widgets/common/vibra_button.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_avatar.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _displayNameFocus = FocusNode();
  final FocusNode _bioFocus = FocusNode();

  File? _selectedImageFile;
  bool _removeAvatar = false;
  bool _isSaving = false;
  bool _isPickingImage = false;
  int _usernameValidation = 0;
  int _photoSelectionVersion = 0;

  bool _isUsernameValid = true;
  bool _isCheckingUsername = false;
  String? _usernameError;
  Timer? _debounceTimer;
  late String _initialUsername;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(myProfileProvider);
    _initialUsername = profile.username;
    _usernameController = TextEditingController(text: profile.username);
    _displayNameController = TextEditingController(
      text: profile.displayName ?? profile.username,
    );
    _bioController = TextEditingController(text: profile.bio ?? '');
    if (defaultTargetPlatform == TargetPlatform.android) {
      Future.microtask(_recoverLostImage);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _usernameValidation++;
    _usernameController.dispose();
    _displayNameController.dispose();
    _bioController.dispose();
    _usernameFocus.dispose();
    _displayNameFocus.dispose();
    _bioFocus.dispose();
    super.dispose();
  }

  Future<void> _validateUsername(String value) async {
    _debounceTimer?.cancel();
    final validation = ++_usernameValidation;
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      setState(() {
        _isUsernameValid = false;
        _isCheckingUsername = false;
        _usernameError = AppLocalizations.of(context)!.profileUsernameEmpty;
      });
      return;
    }

    if (trimmed.length < 3) {
      setState(() {
        _isUsernameValid = false;
        _isCheckingUsername = false;
        _usernameError = AppLocalizations.of(context)!.profileUsernameShort;
      });
      return;
    }

    final isAlphanumeric = RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(trimmed);
    if (!isAlphanumeric) {
      setState(() {
        _isUsernameValid = false;
        _isCheckingUsername = false;
        _usernameError = AppLocalizations.of(
          context,
        )!.profileUsernameCharacters;
      });
      return;
    }

    // Se l'username è identico a quello iniziale dell'utente, è valido
    if (trimmed.toLowerCase() == _initialUsername.toLowerCase()) {
      setState(() {
        _isUsernameValid = true;
        _isCheckingUsername = false;
        _usernameError = null;
      });
      return;
    }

    setState(() {
      _isCheckingUsername = true;
      _usernameError = null;
    });

    _debounceTimer = Timer(Duration(milliseconds: 400), () async {
      try {
        final currentUserId = Supabase.instance.client.auth.currentUser?.id;
        final res = await Supabase.instance.client
            .from('users_public')
            .select('id')
            .eq('username', trimmed)
            .neq('id', currentUserId ?? '00000000-0000-0000-0000-000000000000')
            .maybeSingle();

        if (mounted && validation == _usernameValidation) {
          setState(() {
            _isCheckingUsername = false;
            if (res != null) {
              _isUsernameValid = false;
              _usernameError = AppLocalizations.of(
                context,
              )!.profileUsernameTaken;
            } else {
              _isUsernameValid = true;
              _usernameError = null;
            }
          });
        }
      } catch (e) {
        if (mounted && validation == _usernameValidation) {
          setState(() {
            _isCheckingUsername = false;
            // Se c'è un errore di connessione offline, lasciamo procedere
            _isUsernameValid = true;
            _usernameError = null;
          });
        }
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPickingImage || _isSaving) return;
    _photoSelectionVersion++;
    setState(() => _isPickingImage = true);
    try {
      final picker = ref.read(profileImagePickerProvider);
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (image != null && mounted) {
        setState(() {
          _selectedImageFile = File(image.path);
          _removeAvatar = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is PlatformException && e.code.contains('denied')
                  ? AppLocalizations.of(context)!.profilePhotoPermission
                  : AppLocalizations.of(context)!.profilePhotoPickError,
            ),
            backgroundColor: context.vibraTokens.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  Future<void> _recoverLostImage() async {
    final version = _photoSelectionVersion;
    try {
      final response = await ref
          .read(profileImagePickerProvider)
          .retrieveLostData();
      if (!mounted ||
          response.isEmpty ||
          _isPickingImage ||
          version != _photoSelectionVersion) {
        return;
      }
      final files =
          response.files ?? (response.file == null ? null : [response.file!]);
      if (files != null && files.isNotEmpty) {
        setState(() {
          _selectedImageFile = File(files.first.path);
          _removeAvatar = false;
        });
      }
    } catch (_) {
      // Recovery is optional when no Android gallery result was interrupted.
    }
  }

  void _showImagePickerModal() {
    if (_isPickingImage || _isSaving) return;
    final profile = ref.read(myProfileProvider);
    final hasImage =
        _selectedImageFile != null ||
        (!_removeAvatar && (profile.avatarUrl?.isNotEmpty ?? false));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.vibraTokens.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(VibraSpacing.radiusLarge),
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.vibraTokens.borderDefault,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.profilePhotoTitle,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.vibraTokens.accentPrimary.withValues(
                          alpha: 0.15,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.photo_library_rounded,
                        color: context.vibraTokens.accentPrimary,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.profilePhotoGallery,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)!.profilePhotoGalleryBody,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.vibraTokens.textSecondary,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.vibraTokens.accentSecondary.withValues(
                          alpha: 0.15,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: context.vibraTokens.accentSecondary,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.profilePhotoCamera,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)!.profilePhotoCameraBody,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.vibraTokens.textSecondary,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  if (hasImage) ...[
                    Divider(
                      color: context.vibraTokens.borderDefault,
                      height: 24,
                    ),
                    ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: context.vibraTokens.error.withValues(
                            alpha: 0.15,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: context.vibraTokens.error,
                          size: 22,
                        ),
                      ),
                      title: Text(
                        AppLocalizations.of(context)!.profilePhotoRemove,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: context.vibraTokens.error,
                        ),
                      ),
                      subtitle: Text(
                        AppLocalizations.of(context)!.profilePhotoRestore,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.vibraTokens.textSecondary,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        setState(() {
                          _photoSelectionVersion++;
                          _selectedImageFile = null;
                          _removeAvatar = true;
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (_isSaving || _isPickingImage) return;
    if (!_formKey.currentState!.validate()) return;
    if (!_isUsernameValid || _isCheckingUsername) return;

    _photoSelectionVersion++;
    setState(() => _isSaving = true);
    try {
      String? avatarParam;
      if (_selectedImageFile != null) {
        avatarParam = _selectedImageFile!.path;
      } else if (_removeAvatar) {
        avatarParam = '';
      }

      await ref
          .read(myProfileProvider.notifier)
          .updateProfile(
            username: _usernameController.text.trim(),
            displayName: _displayNameController.text.trim(),
            bio: _bioController.text.trim(),
            avatarUrl: avatarParam,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(AppLocalizations.of(context)!.profileSaved),
                ),
              ],
            ),
            backgroundColor: context.vibraTokens.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/profile');
        }
      }
    } catch (e) {
      if (mounted) {
        if (e is PostgrestException && e.code == '23505') {
          setState(() {
            _isUsernameValid = false;
            _usernameError = AppLocalizations.of(context)!.profileUsernameTaken;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is PostgrestException && e.code == '23505'
                  ? AppLocalizations.of(context)!.profileUsernameTakenRetry
                  : AppLocalizations.of(context)!.profileSaveError,
            ),
            backgroundColor: context.vibraTokens.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(myProfileProvider);
    final theme = Theme.of(context);
    final hasSpotify =
        profile.spotifyId != null && profile.spotifyId!.isNotEmpty;
    final canSave =
        !_isSaving &&
        !_isPickingImage &&
        _isUsernameValid &&
        !_isCheckingUsername;

    final String displayAvatarUrl = _removeAvatar
        ? ''
        : (_selectedImageFile == null ? (profile.avatarUrl ?? '') : '');

    return VibraPageScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.profileEditTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          tooltip: AppLocalizations.of(context)!.profileBack,
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/profile'),
        ),
        actions: [
          if (_isSaving)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.vibraTokens.accentPrimary,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: canSave ? _saveProfile : null,
              child: Text(
                AppLocalizations.of(context)!.commonSave,
                style: TextStyle(
                  color: canSave
                      ? context.vibraTokens.accentPrimary
                      : context.vibraTokens.textDisabled,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              // ─── Sezione Avatar ───────────────────────────────────
              Column(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _isSaving || _isPickingImage
                          ? null
                          : _showImagePickerModal,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          // Glow / Bordo Neon Avatar
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: context.vibraTokens.accentPrimary
                                      .withValues(alpha: 0.3),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: VibraAvatar(
                              imageUrl:
                                  _selectedImageFile?.path ?? displayAvatarUrl,
                              radius: 56,
                              signalRing: true,
                              name: _displayNameController.text.isNotEmpty
                                  ? _displayNameController.text
                                  : _usernameController.text,
                            ),
                          ),

                          // Badge Modifica Foto
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: context.vibraTokens.primaryGradient,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.vibraTokens.backgroundPrimary,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: context.vibraTokens.accentPrimary
                                      .withValues(alpha: 0.4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: context.vibraTokens.onAccent,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: _isSaving || _isPickingImage
                          ? null
                          : _showImagePickerModal,
                      icon: Icon(Icons.edit_rounded, size: 16),
                      label: Text(
                        AppLocalizations.of(context)!.profilePhotoChange,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.03),
              SizedBox(height: 24),

              // ─── Scheda Campi Dati (Glassmorphism) ──────────────────
              ClipRRect(
                    borderRadius: BorderRadius.circular(
                      VibraSpacing.radiusLarge,
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            VibraSpacing.radiusLarge,
                          ),
                          color: context.vibraTokens.surfaceElevated.withValues(
                            alpha: 0.8,
                          ),
                          border: Border.all(
                            color: context.vibraTokens.borderDefault,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Campo Username
                            _buildInputField(
                              icon: Icons.alternate_email_rounded,
                              label: AppLocalizations.of(context)!.authUsername,
                              hint: AppLocalizations.of(
                                context,
                              )!.profileUsernameExample,
                              controller: _usernameController,
                              focusNode: _usernameFocus,
                              nextFocus: _displayNameFocus,
                              onChanged: _validateUsername,
                              maxLength: 30,
                              errorText: _usernameError,
                              isRequired: true,
                              trailing: _isCheckingUsername
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color:
                                            context.vibraTokens.accentPrimary,
                                      ),
                                    )
                                  : _isUsernameValid
                                  ? Icon(
                                      Icons.check_circle_rounded,
                                      color: context.vibraTokens.success,
                                      size: 20,
                                    )
                                  : null,
                            ),

                            _buildDivider(),

                            // Campo Nome (Display Name)
                            _buildInputField(
                              icon: Icons.person_outline_rounded,
                              label: AppLocalizations.of(context)!.profileName,
                              hint: AppLocalizations.of(
                                context,
                              )!.profileNameHint,
                              controller: _displayNameController,
                              focusNode: _displayNameFocus,
                              nextFocus: _bioFocus,
                              maxLength: 50,
                              isRequired: true,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return AppLocalizations.of(
                                    context,
                                  )!.profileNameEmpty;
                                }
                                return null;
                              },
                            ),

                            _buildDivider(),

                            // Campo Descrizione (Bio)
                            _buildInputField(
                              icon: Icons.edit_note_rounded,
                              label: AppLocalizations.of(
                                context,
                              )!.profileDescription,
                              hint: AppLocalizations.of(
                                context,
                              )!.profileDescriptionHint,
                              controller: _bioController,
                              focusNode: _bioFocus,
                              maxLines: 4,
                              maxLength: 160,
                              isRequired: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms)
                  .slideY(begin: 0.03),

              SizedBox(height: 28),

              // ─── Scheda Spotify ──────────────────────────────────
              if (AppConstants.spotifyEnabled)
                Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Color(
                                  0xFF1DB954,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.music_note_rounded,
                                color: Color(0xFF1DB954),
                                size: 14,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.profileMusicStreaming,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            VibraSpacing.radiusMedium,
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: context.vibraTokens.surfaceElevated
                                    .withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(
                                  VibraSpacing.radiusMedium,
                                ),
                                border: Border.all(
                                  color: context.vibraTokens.borderDefault,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Color(
                                        0xFF1DB954,
                                      ).withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(
                                            0xFF1DB954,
                                          ).withValues(alpha: 0.25),
                                          blurRadius: 12,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.graphic_eq_rounded,
                                      color: Color(0xFF1DB954),
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Spotify',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          hasSpotify
                                              ? AppLocalizations.of(
                                                  context,
                                                )!.profileAccountConnected
                                              : AppLocalizations.of(
                                                  context,
                                                )!.profileConnectSuggestions,
                                          style: TextStyle(
                                            color: context
                                                .vibraTokens
                                                .textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  if (hasSpotify)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: Color(0xFF1DB954),
                                          size: 20,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.commonActive,
                                          style: TextStyle(
                                            color: Color(0xFF1DB954),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    ElevatedButton(
                                      onPressed: () =>
                                          context.push('/spotify-connect'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF1DB954),
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.commonConnect,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(begin: 0.03),

              SizedBox(height: 36),

              // ─── Pulsante Salvataggio Principale ───────────────────
              VibraButton(
                label: AppLocalizations.of(context)!.profileSaveChanges,
                onPressed: canSave ? _saveProfile : null,
                loading: _isSaving,
                expanded: true,
                tone: VibraButtonTone.signal,
                leadingIcon: Icons.save_rounded,
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: EdgeInsets.only(left: 56),
      color: context.vibraTokens.borderDefault.withValues(alpha: 0.5),
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
    String? errorText,
    Widget? trailing,
    bool isRequired = false,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 12 : 0),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.vibraTokens.accentPrimary.withValues(
                  alpha: 0.15,
                ),
                borderRadius: BorderRadius.circular(VibraSpacing.radiusSmall),
              ),
              child: Icon(
                icon,
                color: context.vibraTokens.accentPrimary,
                size: 18,
              ),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: context.vibraTokens.textSecondary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    if (isRequired) ...[
                      SizedBox(width: 3),
                      Text(
                        '*',
                        style: TextStyle(
                          color: context.vibraTokens.accentSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
                TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  maxLines: maxLines,
                  maxLength: maxLength,
                  textInputAction: maxLines > 1
                      ? TextInputAction.newline
                      : TextInputAction.next,
                  onFieldSubmitted: (_) {
                    if (nextFocus != null) {
                      FocusScope.of(context).requestFocus(nextFocus);
                    } else {
                      focusNode.unfocus();
                    }
                  },
                  onChanged: onChanged,
                  validator: validator,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.vibraTokens.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.vibraTokens.textDisabled,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 6),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    counterText: maxLength != null ? null : '',
                    errorText: errorText,
                    errorStyle: TextStyle(
                      color: context.vibraTokens.error,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[SizedBox(width: 8), trailing],
        ],
      ),
    );
  }
}
