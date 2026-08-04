// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'music_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MusicProfileModel {

 String get id;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'top_artists') List<Map<String, dynamic>> get topArtists;@JsonKey(name: 'top_tracks') List<Map<String, dynamic>> get topTracks;@JsonKey(name: 'top_genres') List<Map<String, dynamic>> get topGenres;@JsonKey(name: 'last_synced_at') DateTime? get lastSyncedAt;
/// Create a copy of MusicProfileModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MusicProfileModelCopyWith<MusicProfileModel> get copyWith => _$MusicProfileModelCopyWithImpl<MusicProfileModel>(this as MusicProfileModel, _$identity);

  /// Serializes this MusicProfileModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MusicProfileModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other.topArtists, topArtists)&&const DeepCollectionEquality().equals(other.topTracks, topTracks)&&const DeepCollectionEquality().equals(other.topGenres, topGenres)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,const DeepCollectionEquality().hash(topArtists),const DeepCollectionEquality().hash(topTracks),const DeepCollectionEquality().hash(topGenres),lastSyncedAt);

@override
String toString() {
  return 'MusicProfileModel(id: $id, userId: $userId, topArtists: $topArtists, topTracks: $topTracks, topGenres: $topGenres, lastSyncedAt: $lastSyncedAt)';
}


}

/// @nodoc
abstract mixin class $MusicProfileModelCopyWith<$Res>  {
  factory $MusicProfileModelCopyWith(MusicProfileModel value, $Res Function(MusicProfileModel) _then) = _$MusicProfileModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'top_artists') List<Map<String, dynamic>> topArtists,@JsonKey(name: 'top_tracks') List<Map<String, dynamic>> topTracks,@JsonKey(name: 'top_genres') List<Map<String, dynamic>> topGenres,@JsonKey(name: 'last_synced_at') DateTime? lastSyncedAt
});




}
/// @nodoc
class _$MusicProfileModelCopyWithImpl<$Res>
    implements $MusicProfileModelCopyWith<$Res> {
  _$MusicProfileModelCopyWithImpl(this._self, this._then);

  final MusicProfileModel _self;
  final $Res Function(MusicProfileModel) _then;

/// Create a copy of MusicProfileModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? topArtists = null,Object? topTracks = null,Object? topGenres = null,Object? lastSyncedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,topArtists: null == topArtists ? _self.topArtists : topArtists // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,topTracks: null == topTracks ? _self.topTracks : topTracks // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,topGenres: null == topGenres ? _self.topGenres : topGenres // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MusicProfileModel].
extension MusicProfileModelPatterns on MusicProfileModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MusicProfileModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MusicProfileModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MusicProfileModel value)  $default,){
final _that = this;
switch (_that) {
case _MusicProfileModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MusicProfileModel value)?  $default,){
final _that = this;
switch (_that) {
case _MusicProfileModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'top_artists')  List<Map<String, dynamic>> topArtists, @JsonKey(name: 'top_tracks')  List<Map<String, dynamic>> topTracks, @JsonKey(name: 'top_genres')  List<Map<String, dynamic>> topGenres, @JsonKey(name: 'last_synced_at')  DateTime? lastSyncedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MusicProfileModel() when $default != null:
return $default(_that.id,_that.userId,_that.topArtists,_that.topTracks,_that.topGenres,_that.lastSyncedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'top_artists')  List<Map<String, dynamic>> topArtists, @JsonKey(name: 'top_tracks')  List<Map<String, dynamic>> topTracks, @JsonKey(name: 'top_genres')  List<Map<String, dynamic>> topGenres, @JsonKey(name: 'last_synced_at')  DateTime? lastSyncedAt)  $default,) {final _that = this;
switch (_that) {
case _MusicProfileModel():
return $default(_that.id,_that.userId,_that.topArtists,_that.topTracks,_that.topGenres,_that.lastSyncedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'top_artists')  List<Map<String, dynamic>> topArtists, @JsonKey(name: 'top_tracks')  List<Map<String, dynamic>> topTracks, @JsonKey(name: 'top_genres')  List<Map<String, dynamic>> topGenres, @JsonKey(name: 'last_synced_at')  DateTime? lastSyncedAt)?  $default,) {final _that = this;
switch (_that) {
case _MusicProfileModel() when $default != null:
return $default(_that.id,_that.userId,_that.topArtists,_that.topTracks,_that.topGenres,_that.lastSyncedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MusicProfileModel implements MusicProfileModel {
  const _MusicProfileModel({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'top_artists') final  List<Map<String, dynamic>> topArtists = const <Map<String, dynamic>>[], @JsonKey(name: 'top_tracks') final  List<Map<String, dynamic>> topTracks = const <Map<String, dynamic>>[], @JsonKey(name: 'top_genres') final  List<Map<String, dynamic>> topGenres = const <Map<String, dynamic>>[], @JsonKey(name: 'last_synced_at') this.lastSyncedAt}): _topArtists = topArtists,_topTracks = topTracks,_topGenres = topGenres;
  factory _MusicProfileModel.fromJson(Map<String, dynamic> json) => _$MusicProfileModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
 final  List<Map<String, dynamic>> _topArtists;
@override@JsonKey(name: 'top_artists') List<Map<String, dynamic>> get topArtists {
  if (_topArtists is EqualUnmodifiableListView) return _topArtists;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topArtists);
}

 final  List<Map<String, dynamic>> _topTracks;
@override@JsonKey(name: 'top_tracks') List<Map<String, dynamic>> get topTracks {
  if (_topTracks is EqualUnmodifiableListView) return _topTracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topTracks);
}

 final  List<Map<String, dynamic>> _topGenres;
@override@JsonKey(name: 'top_genres') List<Map<String, dynamic>> get topGenres {
  if (_topGenres is EqualUnmodifiableListView) return _topGenres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topGenres);
}

@override@JsonKey(name: 'last_synced_at') final  DateTime? lastSyncedAt;

/// Create a copy of MusicProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MusicProfileModelCopyWith<_MusicProfileModel> get copyWith => __$MusicProfileModelCopyWithImpl<_MusicProfileModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MusicProfileModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MusicProfileModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other._topArtists, _topArtists)&&const DeepCollectionEquality().equals(other._topTracks, _topTracks)&&const DeepCollectionEquality().equals(other._topGenres, _topGenres)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,const DeepCollectionEquality().hash(_topArtists),const DeepCollectionEquality().hash(_topTracks),const DeepCollectionEquality().hash(_topGenres),lastSyncedAt);

@override
String toString() {
  return 'MusicProfileModel(id: $id, userId: $userId, topArtists: $topArtists, topTracks: $topTracks, topGenres: $topGenres, lastSyncedAt: $lastSyncedAt)';
}


}

/// @nodoc
abstract mixin class _$MusicProfileModelCopyWith<$Res> implements $MusicProfileModelCopyWith<$Res> {
  factory _$MusicProfileModelCopyWith(_MusicProfileModel value, $Res Function(_MusicProfileModel) _then) = __$MusicProfileModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'top_artists') List<Map<String, dynamic>> topArtists,@JsonKey(name: 'top_tracks') List<Map<String, dynamic>> topTracks,@JsonKey(name: 'top_genres') List<Map<String, dynamic>> topGenres,@JsonKey(name: 'last_synced_at') DateTime? lastSyncedAt
});




}
/// @nodoc
class __$MusicProfileModelCopyWithImpl<$Res>
    implements _$MusicProfileModelCopyWith<$Res> {
  __$MusicProfileModelCopyWithImpl(this._self, this._then);

  final _MusicProfileModel _self;
  final $Res Function(_MusicProfileModel) _then;

/// Create a copy of MusicProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? topArtists = null,Object? topTracks = null,Object? topGenres = null,Object? lastSyncedAt = freezed,}) {
  return _then(_MusicProfileModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,topArtists: null == topArtists ? _self._topArtists : topArtists // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,topTracks: null == topTracks ? _self._topTracks : topTracks // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,topGenres: null == topGenres ? _self._topGenres : topGenres // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
