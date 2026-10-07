import '../../../core/errors/exceptions.dart' show ServerException;
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../providers/app_state_providers.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/vibra_neon_avatar.dart';

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
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
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
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      setState(() {
        _isUsernameValid = false;
        _isCheckingUsername = false;
        _usernameError = 'L\'username non può essere vuoto';
      });
      return;
    }

    if (trimmed.length < 3) {
      setState(() {
        _isUsernameValid = false;
        _isCheckingUsername = false;
        _usernameError = 'Minimo 3 caratteri';
      });
      return;
    }

    final isAlphanumeric = RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(trimmed);
    if (!isAlphanumeric) {
      setState(() {
        _isUsernameValid = false;
        _isCheckingUsername = false;
        _usernameError = 'Usa solo lettere, numeri, _ o .';
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
              _usernameError = null;
            }
          });
        }
      } catch (e) {
        if (mounted) {
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
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
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
            content: Text('Impossibile selezionare l\'immagine.'),
            backgroundColor: context.vibraTokens.error,
          ),
        );
      }
    }
  }

  void _showImagePickerModal() {
    final profile = ref.read(myProfileProvider);
    final hasImage =
        _selectedImageFile != null ||
        (!_removeAvatar && (profile.avatarUrl?.isNotEmpty ?? false));

    showModalBottomSheet(
      context: context,
      backgroundColor: context.vibraTokens.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(VibraSpacing.radiusLarge),
        ),
      ),
      builder: (ctx) {
        return SafeArea(
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
                  'Foto Profilo',
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
                    'Scegli dalla galleria',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Seleziona una foto dal tuo dispositivo',
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
                    'Scatta una foto',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Usa la fotocamera per un nuovo scatto',
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
                  Divider(color: context.vibraTokens.borderDefault, height: 24),
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
                      'Rimuovi foto',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: context.vibraTokens.error,
                      ),
                    ),
                    subtitle: Text(
                      'Ripristina l\'avatar predefinito',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.vibraTokens.textSecondary,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      setState(() {
                        _selectedImageFile = null;
                        _removeAvatar = true;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isUsernameValid || _isCheckingUsername) return;

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
                Text('Profilo aggiornato con successo!'),
              ],
            ),
            backgroundColor: context.vibraTokens.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is ServerException
                  ? 'Impossibile salvare il profilo: ${e.message}'
                  : 'Impossibile salvare il profilo. Riprova tra poco.',
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
    final canSave = !_isSaving && _isUsernameValid && !_isCheckingUsername;

    final String displayAvatarUrl = _removeAvatar
        ? ''
        : (_selectedImageFile == null ? (profile.avatarUrl ?? '') : '');

    return VibraPageScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Modifica Profilo',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
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
                'Salva',
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
                      onTap: _isSaving ? null : _showImagePickerModal,
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
                            child: VibraNeonAvatar(
                              imageUrl: displayAvatarUrl,
                              imageFile: _selectedImageFile,
                              radius: 56,
                              score: 1.0,
                              displayName:
                                  _displayNameController.text.isNotEmpty
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
                              color: Colors.white,
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
                      onPressed: _isSaving ? null : _showImagePickerModal,
                      icon: Icon(Icons.edit_rounded, size: 16),
                      label: Text(
                        'Cambia immagine profilo',
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
                              label: 'Username',
                              hint: 'es. musica_fan',
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
                              label: 'Nome',
                              hint: 'Il tuo nome o nickname',
                              controller: _displayNameController,
                              focusNode: _displayNameFocus,
                              nextFocus: _bioFocus,
                              maxLength: 50,
                              isRequired: true,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Il nome non può essere vuoto';
                                }
                                return null;
                              },
                            ),

                            _buildDivider(),

                            // Campo Descrizione (Bio)
                            _buildInputField(
                              icon: Icons.edit_note_rounded,
                              label: 'Descrizione',
                              hint:
                                  'Racconta qualcosa sui tuoi gusti musicali e su di te...',
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
              Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Color(0xFF1DB954).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.music_note_rounded,
                              color: Color(0xFF1DB954),
                              size: 14,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Musica e Streaming',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
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
                                            ? 'Account connesso'
                                            : 'Collega il tuo account per suggerimenti migliori',
                                        style: TextStyle(
                                          color:
                                              context.vibraTokens.textSecondary,
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
                                        'Attivo',
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
                                    child: Text('Collega'),
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
              GestureDetector(
                    onTap: canSave ? _saveProfile : null,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: canSave
                            ? context.vibraTokens.primaryGradient
                            : null,
                        color: canSave
                            ? null
                            : context.vibraTokens.surfaceMuted,
                        borderRadius: BorderRadius.circular(
                          VibraSpacing.radiusMedium,
                        ),
                        boxShadow: canSave
                            ? [
                                BoxShadow(
                                  color: context.vibraTokens.accentPrimary
                                      .withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: _isSaving
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.save_rounded,
                                    size: 20,
                                    color: canSave
                                        ? Colors.white
                                        : context.vibraTokens.textDisabled,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Salva Modifiche',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: canSave
                                          ? Colors.white
                                          : context.vibraTokens.textDisabled,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .slideY(begin: 0.05),
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
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: context.vibraTokens.textSecondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
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
