/// Entità pura dell'utente Vibra.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.spotifyId,
    this.fcmToken,
    this.onboardingCompleted = false,
    this.onboardingStep,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final String? spotifyId;
  final String? fcmToken;
  final bool onboardingCompleted;
  final String? onboardingStep;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

