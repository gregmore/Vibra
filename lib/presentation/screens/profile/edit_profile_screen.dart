import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/vibra_colors.dart';
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
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  bool _isUploadingAvatar = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(myProfileProvider);
    _displayNameController = TextEditingController(
      text: profile.displayName ?? profile.username,
    );
    _bioController = TextEditingController(text: profile.bio ?? '');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
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
            content: Text('Errore durante la selezione della foto.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await ref
          .read(myProfileProvider.notifier)
          .updateProfile(
            displayName: _displayNameController.text.trim(),
            bio: _bioController.text.trim(),
          );
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore durante il salvataggio del profilo.'),
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                'Salva',
                style: TextStyle(
                  color: VibraColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            // Avatar section
            Center(
              child: GestureDetector(
                onTap: _isUploadingAvatar ? null : _pickAndUploadImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    VibraNeonAvatar(
                      imageUrl: profile.avatarUrl ?? '',
                      radius: 56,
                      score: 1.0,
                      displayName: profile.displayName ?? profile.username,
                    ),
                    if (_isUploadingAvatar)
                      Container(
                        width: 112,
                        height: 112,
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
                        decoration: BoxDecoration(
                          color: VibraColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: VibraColors.surface,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Form fields
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Nome Visualizzato',
                hintText: 'Come vuoi farti chiamare?',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Il nome non può essere vuoto';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Biografia',
                hintText: 'Racconta qualcosa di te...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Spotify connection
            Text(
              'Musica',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: VibraColors.surfaceElevated,
                borderRadius: VibraSpacing.borderMedium,
                border: Border.all(color: VibraColors.glassBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.graphic_eq_rounded,
                    color: Color(0xFF1DB954),
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Spotify',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hasSpotify
                              ? 'Account connesso'
                              : 'Collega il tuo account per suggerimenti migliori',
                          style: TextStyle(
                            color: VibraColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (hasSpotify)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF1DB954),
                    )
                  else
                    ElevatedButton(
                      onPressed: () => context.push('/spotify-connect'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1DB954),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text('Collega'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
