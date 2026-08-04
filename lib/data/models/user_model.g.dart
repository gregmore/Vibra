// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  username: json['username'] as String,
  displayName: json['display_name'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  bio: json['bio'] as String?,
  spotifyId: json['spotify_id'] as String?,
  spotifyAccessToken: json['spotify_access_token'] as String?,
  spotifyRefreshToken: json['spotify_refresh_token'] as String?,
  fcmToken: json['fcm_token'] as String?,
  onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
  onboardingStep: json['onboarding_step'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'bio': instance.bio,
      'spotify_id': instance.spotifyId,
      'spotify_access_token': instance.spotifyAccessToken,
      'spotify_refresh_token': instance.spotifyRefreshToken,
      'fcm_token': instance.fcmToken,
      'onboarding_completed': instance.onboardingCompleted,
      'onboarding_step': instance.onboardingStep,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
