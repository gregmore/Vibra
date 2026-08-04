import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// DTO del profilo utente in tabella `public.users`.
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String username,
    @JsonKey(name: 'display_name') String? displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? bio,
    @JsonKey(name: 'spotify_id') String? spotifyId,
    @JsonKey(name: 'spotify_access_token') String? spotifyAccessToken,
    @JsonKey(name: 'spotify_refresh_token') String? spotifyRefreshToken,
    @JsonKey(name: 'fcm_token') String? fcmToken,
    @JsonKey(name: 'onboarding_completed', defaultValue: false) @Default(false) bool onboardingCompleted,
    @JsonKey(name: 'onboarding_step') String? onboardingStep,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

