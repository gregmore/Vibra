// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spotify_track_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SpotifyTrackModel {

 String get id; String get name;@JsonKey(name: 'artists') List<SpotifyTrackArtistModel> get artists; int? get popularity;
/// Create a copy of SpotifyTrackModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpotifyTrackModelCopyWith<SpotifyTrackModel> get copyWith => _$SpotifyTrackModelCopyWithImpl<SpotifyTrackModel>(this as SpotifyTrackModel, _$identity);

  /// Serializes this SpotifyTrackModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpotifyTrackModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.artists, artists)&&(identical(other.popularity, popularity) || other.popularity == popularity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(artists),popularity);

@override
String toString() {
  return 'SpotifyTrackModel(id: $id, name: $name, artists: $artists, popularity: $popularity)';
}


}

/// @nodoc
abstract mixin class $SpotifyTrackModelCopyWith<$Res>  {
  factory $SpotifyTrackModelCopyWith(SpotifyTrackModel value, $Res Function(SpotifyTrackModel) _then) = _$SpotifyTrackModelCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'artists') List<SpotifyTrackArtistModel> artists, int? popularity
});




}
/// @nodoc
class _$SpotifyTrackModelCopyWithImpl<$Res>
    implements $SpotifyTrackModelCopyWith<$Res> {
  _$SpotifyTrackModelCopyWithImpl(this._self, this._then);

  final SpotifyTrackModel _self;
  final $Res Function(SpotifyTrackModel) _then;

/// Create a copy of SpotifyTrackModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? artists = null,Object? popularity = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,artists: null == artists ? _self.artists : artists // ignore: cast_nullable_to_non_nullable
as List<SpotifyTrackArtistModel>,popularity: freezed == popularity ? _self.popularity : popularity // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [SpotifyTrackModel].
extension SpotifyTrackModelPatterns on SpotifyTrackModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpotifyTrackModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpotifyTrackModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpotifyTrackModel value)  $default,){
final _that = this;
switch (_that) {
case _SpotifyTrackModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpotifyTrackModel value)?  $default,){
final _that = this;
switch (_that) {
case _SpotifyTrackModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'artists')  List<SpotifyTrackArtistModel> artists,  int? popularity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpotifyTrackModel() when $default != null:
return $default(_that.id,_that.name,_that.artists,_that.popularity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'artists')  List<SpotifyTrackArtistModel> artists,  int? popularity)  $default,) {final _that = this;
switch (_that) {
case _SpotifyTrackModel():
return $default(_that.id,_that.name,_that.artists,_that.popularity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'artists')  List<SpotifyTrackArtistModel> artists,  int? popularity)?  $default,) {final _that = this;
switch (_that) {
case _SpotifyTrackModel() when $default != null:
return $default(_that.id,_that.name,_that.artists,_that.popularity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SpotifyTrackModel implements SpotifyTrackModel {
  const _SpotifyTrackModel({required this.id, required this.name, @JsonKey(name: 'artists') final  List<SpotifyTrackArtistModel> artists = const <SpotifyTrackArtistModel>[], this.popularity}): _artists = artists;
  factory _SpotifyTrackModel.fromJson(Map<String, dynamic> json) => _$SpotifyTrackModelFromJson(json);

@override final  String id;
@override final  String name;
 final  List<SpotifyTrackArtistModel> _artists;
@override@JsonKey(name: 'artists') List<SpotifyTrackArtistModel> get artists {
  if (_artists is EqualUnmodifiableListView) return _artists;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_artists);
}

@override final  int? popularity;

/// Create a copy of SpotifyTrackModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpotifyTrackModelCopyWith<_SpotifyTrackModel> get copyWith => __$SpotifyTrackModelCopyWithImpl<_SpotifyTrackModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SpotifyTrackModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpotifyTrackModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._artists, _artists)&&(identical(other.popularity, popularity) || other.popularity == popularity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_artists),popularity);

@override
String toString() {
  return 'SpotifyTrackModel(id: $id, name: $name, artists: $artists, popularity: $popularity)';
}


}

/// @nodoc
abstract mixin class _$SpotifyTrackModelCopyWith<$Res> implements $SpotifyTrackModelCopyWith<$Res> {
  factory _$SpotifyTrackModelCopyWith(_SpotifyTrackModel value, $Res Function(_SpotifyTrackModel) _then) = __$SpotifyTrackModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'artists') List<SpotifyTrackArtistModel> artists, int? popularity
});




}
/// @nodoc
class __$SpotifyTrackModelCopyWithImpl<$Res>
    implements _$SpotifyTrackModelCopyWith<$Res> {
  __$SpotifyTrackModelCopyWithImpl(this._self, this._then);

  final _SpotifyTrackModel _self;
  final $Res Function(_SpotifyTrackModel) _then;

/// Create a copy of SpotifyTrackModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? artists = null,Object? popularity = freezed,}) {
  return _then(_SpotifyTrackModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,artists: null == artists ? _self._artists : artists // ignore: cast_nullable_to_non_nullable
as List<SpotifyTrackArtistModel>,popularity: freezed == popularity ? _self.popularity : popularity // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$SpotifyTrackArtistModel {

 String get id; String get name;
/// Create a copy of SpotifyTrackArtistModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpotifyTrackArtistModelCopyWith<SpotifyTrackArtistModel> get copyWith => _$SpotifyTrackArtistModelCopyWithImpl<SpotifyTrackArtistModel>(this as SpotifyTrackArtistModel, _$identity);

  /// Serializes this SpotifyTrackArtistModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpotifyTrackArtistModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'SpotifyTrackArtistModel(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $SpotifyTrackArtistModelCopyWith<$Res>  {
  factory $SpotifyTrackArtistModelCopyWith(SpotifyTrackArtistModel value, $Res Function(SpotifyTrackArtistModel) _then) = _$SpotifyTrackArtistModelCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$SpotifyTrackArtistModelCopyWithImpl<$Res>
    implements $SpotifyTrackArtistModelCopyWith<$Res> {
  _$SpotifyTrackArtistModelCopyWithImpl(this._self, this._then);

  final SpotifyTrackArtistModel _self;
  final $Res Function(SpotifyTrackArtistModel) _then;

/// Create a copy of SpotifyTrackArtistModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SpotifyTrackArtistModel].
extension SpotifyTrackArtistModelPatterns on SpotifyTrackArtistModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpotifyTrackArtistModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpotifyTrackArtistModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpotifyTrackArtistModel value)  $default,){
final _that = this;
switch (_that) {
case _SpotifyTrackArtistModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpotifyTrackArtistModel value)?  $default,){
final _that = this;
switch (_that) {
case _SpotifyTrackArtistModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpotifyTrackArtistModel() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name)  $default,) {final _that = this;
switch (_that) {
case _SpotifyTrackArtistModel():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _SpotifyTrackArtistModel() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SpotifyTrackArtistModel implements SpotifyTrackArtistModel {
  const _SpotifyTrackArtistModel({required this.id, required this.name});
  factory _SpotifyTrackArtistModel.fromJson(Map<String, dynamic> json) => _$SpotifyTrackArtistModelFromJson(json);

@override final  String id;
@override final  String name;

/// Create a copy of SpotifyTrackArtistModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpotifyTrackArtistModelCopyWith<_SpotifyTrackArtistModel> get copyWith => __$SpotifyTrackArtistModelCopyWithImpl<_SpotifyTrackArtistModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SpotifyTrackArtistModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpotifyTrackArtistModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'SpotifyTrackArtistModel(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$SpotifyTrackArtistModelCopyWith<$Res> implements $SpotifyTrackArtistModelCopyWith<$Res> {
  factory _$SpotifyTrackArtistModelCopyWith(_SpotifyTrackArtistModel value, $Res Function(_SpotifyTrackArtistModel) _then) = __$SpotifyTrackArtistModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$SpotifyTrackArtistModelCopyWithImpl<$Res>
    implements _$SpotifyTrackArtistModelCopyWith<$Res> {
  __$SpotifyTrackArtistModelCopyWithImpl(this._self, this._then);

  final _SpotifyTrackArtistModel _self;
  final $Res Function(_SpotifyTrackArtistModel) _then;

/// Create a copy of SpotifyTrackArtistModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_SpotifyTrackArtistModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
