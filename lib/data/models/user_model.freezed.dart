// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {

 String get id; String get email; String get username;@JsonKey(name: 'display_name') String? get displayName;@JsonKey(name: 'avatar_url') String? get avatarUrl; String? get bio;@JsonKey(name: 'spotify_id') String? get spotifyId;@JsonKey(name: 'spotify_access_token') String? get spotifyAccessToken;@JsonKey(name: 'spotify_refresh_token') String? get spotifyRefreshToken;@JsonKey(name: 'fcm_token') String? get fcmToken;@JsonKey(name: 'onboarding_completed', defaultValue: false) bool get onboardingCompleted;@JsonKey(name: 'onboarding_step') String? get onboardingStep;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.spotifyId, spotifyId) || other.spotifyId == spotifyId)&&(identical(other.spotifyAccessToken, spotifyAccessToken) || other.spotifyAccessToken == spotifyAccessToken)&&(identical(other.spotifyRefreshToken, spotifyRefreshToken) || other.spotifyRefreshToken == spotifyRefreshToken)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.onboardingCompleted, onboardingCompleted) || other.onboardingCompleted == onboardingCompleted)&&(identical(other.onboardingStep, onboardingStep) || other.onboardingStep == onboardingStep)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,username,displayName,avatarUrl,bio,spotifyId,spotifyAccessToken,spotifyRefreshToken,fcmToken,onboardingCompleted,onboardingStep,createdAt,updatedAt);

@override
String toString() {
  return 'UserModel(id: $id, email: $email, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, bio: $bio, spotifyId: $spotifyId, spotifyAccessToken: $spotifyAccessToken, spotifyRefreshToken: $spotifyRefreshToken, fcmToken: $fcmToken, onboardingCompleted: $onboardingCompleted, onboardingStep: $onboardingStep, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 String id, String email, String username,@JsonKey(name: 'display_name') String? displayName,@JsonKey(name: 'avatar_url') String? avatarUrl, String? bio,@JsonKey(name: 'spotify_id') String? spotifyId,@JsonKey(name: 'spotify_access_token') String? spotifyAccessToken,@JsonKey(name: 'spotify_refresh_token') String? spotifyRefreshToken,@JsonKey(name: 'fcm_token') String? fcmToken,@JsonKey(name: 'onboarding_completed', defaultValue: false) bool onboardingCompleted,@JsonKey(name: 'onboarding_step') String? onboardingStep,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? username = null,Object? displayName = freezed,Object? avatarUrl = freezed,Object? bio = freezed,Object? spotifyId = freezed,Object? spotifyAccessToken = freezed,Object? spotifyRefreshToken = freezed,Object? fcmToken = freezed,Object? onboardingCompleted = null,Object? onboardingStep = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,spotifyId: freezed == spotifyId ? _self.spotifyId : spotifyId // ignore: cast_nullable_to_non_nullable
as String?,spotifyAccessToken: freezed == spotifyAccessToken ? _self.spotifyAccessToken : spotifyAccessToken // ignore: cast_nullable_to_non_nullable
as String?,spotifyRefreshToken: freezed == spotifyRefreshToken ? _self.spotifyRefreshToken : spotifyRefreshToken // ignore: cast_nullable_to_non_nullable
as String?,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,onboardingCompleted: null == onboardingCompleted ? _self.onboardingCompleted : onboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool,onboardingStep: freezed == onboardingStep ? _self.onboardingStep : onboardingStep // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  String username, @JsonKey(name: 'display_name')  String? displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl,  String? bio, @JsonKey(name: 'spotify_id')  String? spotifyId, @JsonKey(name: 'spotify_access_token')  String? spotifyAccessToken, @JsonKey(name: 'spotify_refresh_token')  String? spotifyRefreshToken, @JsonKey(name: 'fcm_token')  String? fcmToken, @JsonKey(name: 'onboarding_completed', defaultValue: false)  bool onboardingCompleted, @JsonKey(name: 'onboarding_step')  String? onboardingStep, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.email,_that.username,_that.displayName,_that.avatarUrl,_that.bio,_that.spotifyId,_that.spotifyAccessToken,_that.spotifyRefreshToken,_that.fcmToken,_that.onboardingCompleted,_that.onboardingStep,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  String username, @JsonKey(name: 'display_name')  String? displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl,  String? bio, @JsonKey(name: 'spotify_id')  String? spotifyId, @JsonKey(name: 'spotify_access_token')  String? spotifyAccessToken, @JsonKey(name: 'spotify_refresh_token')  String? spotifyRefreshToken, @JsonKey(name: 'fcm_token')  String? fcmToken, @JsonKey(name: 'onboarding_completed', defaultValue: false)  bool onboardingCompleted, @JsonKey(name: 'onboarding_step')  String? onboardingStep, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.id,_that.email,_that.username,_that.displayName,_that.avatarUrl,_that.bio,_that.spotifyId,_that.spotifyAccessToken,_that.spotifyRefreshToken,_that.fcmToken,_that.onboardingCompleted,_that.onboardingStep,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  String username, @JsonKey(name: 'display_name')  String? displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl,  String? bio, @JsonKey(name: 'spotify_id')  String? spotifyId, @JsonKey(name: 'spotify_access_token')  String? spotifyAccessToken, @JsonKey(name: 'spotify_refresh_token')  String? spotifyRefreshToken, @JsonKey(name: 'fcm_token')  String? fcmToken, @JsonKey(name: 'onboarding_completed', defaultValue: false)  bool onboardingCompleted, @JsonKey(name: 'onboarding_step')  String? onboardingStep, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.email,_that.username,_that.displayName,_that.avatarUrl,_that.bio,_that.spotifyId,_that.spotifyAccessToken,_that.spotifyRefreshToken,_that.fcmToken,_that.onboardingCompleted,_that.onboardingStep,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserModel implements UserModel {
  const _UserModel({required this.id, required this.email, required this.username, @JsonKey(name: 'display_name') this.displayName, @JsonKey(name: 'avatar_url') this.avatarUrl, this.bio, @JsonKey(name: 'spotify_id') this.spotifyId, @JsonKey(name: 'spotify_access_token') this.spotifyAccessToken, @JsonKey(name: 'spotify_refresh_token') this.spotifyRefreshToken, @JsonKey(name: 'fcm_token') this.fcmToken, @JsonKey(name: 'onboarding_completed', defaultValue: false) this.onboardingCompleted = false, @JsonKey(name: 'onboarding_step') this.onboardingStep, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override final  String id;
@override final  String email;
@override final  String username;
@override@JsonKey(name: 'display_name') final  String? displayName;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override final  String? bio;
@override@JsonKey(name: 'spotify_id') final  String? spotifyId;
@override@JsonKey(name: 'spotify_access_token') final  String? spotifyAccessToken;
@override@JsonKey(name: 'spotify_refresh_token') final  String? spotifyRefreshToken;
@override@JsonKey(name: 'fcm_token') final  String? fcmToken;
@override@JsonKey(name: 'onboarding_completed', defaultValue: false) final  bool onboardingCompleted;
@override@JsonKey(name: 'onboarding_step') final  String? onboardingStep;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.spotifyId, spotifyId) || other.spotifyId == spotifyId)&&(identical(other.spotifyAccessToken, spotifyAccessToken) || other.spotifyAccessToken == spotifyAccessToken)&&(identical(other.spotifyRefreshToken, spotifyRefreshToken) || other.spotifyRefreshToken == spotifyRefreshToken)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.onboardingCompleted, onboardingCompleted) || other.onboardingCompleted == onboardingCompleted)&&(identical(other.onboardingStep, onboardingStep) || other.onboardingStep == onboardingStep)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,username,displayName,avatarUrl,bio,spotifyId,spotifyAccessToken,spotifyRefreshToken,fcmToken,onboardingCompleted,onboardingStep,createdAt,updatedAt);

@override
String toString() {
  return 'UserModel(id: $id, email: $email, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, bio: $bio, spotifyId: $spotifyId, spotifyAccessToken: $spotifyAccessToken, spotifyRefreshToken: $spotifyRefreshToken, fcmToken: $fcmToken, onboardingCompleted: $onboardingCompleted, onboardingStep: $onboardingStep, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String username,@JsonKey(name: 'display_name') String? displayName,@JsonKey(name: 'avatar_url') String? avatarUrl, String? bio,@JsonKey(name: 'spotify_id') String? spotifyId,@JsonKey(name: 'spotify_access_token') String? spotifyAccessToken,@JsonKey(name: 'spotify_refresh_token') String? spotifyRefreshToken,@JsonKey(name: 'fcm_token') String? fcmToken,@JsonKey(name: 'onboarding_completed', defaultValue: false) bool onboardingCompleted,@JsonKey(name: 'onboarding_step') String? onboardingStep,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? username = null,Object? displayName = freezed,Object? avatarUrl = freezed,Object? bio = freezed,Object? spotifyId = freezed,Object? spotifyAccessToken = freezed,Object? spotifyRefreshToken = freezed,Object? fcmToken = freezed,Object? onboardingCompleted = null,Object? onboardingStep = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_UserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,spotifyId: freezed == spotifyId ? _self.spotifyId : spotifyId // ignore: cast_nullable_to_non_nullable
as String?,spotifyAccessToken: freezed == spotifyAccessToken ? _self.spotifyAccessToken : spotifyAccessToken // ignore: cast_nullable_to_non_nullable
as String?,spotifyRefreshToken: freezed == spotifyRefreshToken ? _self.spotifyRefreshToken : spotifyRefreshToken // ignore: cast_nullable_to_non_nullable
as String?,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,onboardingCompleted: null == onboardingCompleted ? _self.onboardingCompleted : onboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool,onboardingStep: freezed == onboardingStep ? _self.onboardingStep : onboardingStep // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
