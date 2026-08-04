// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spotify_playlist_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SpotifyPlaylistModel {

 String get id; String get name;@JsonKey(name: 'tracks') SpotifyPlaylistTracksModel? get tracks;@JsonKey(name: 'images') List<SpotifyPlaylistImageModel> get images;
/// Create a copy of SpotifyPlaylistModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpotifyPlaylistModelCopyWith<SpotifyPlaylistModel> get copyWith => _$SpotifyPlaylistModelCopyWithImpl<SpotifyPlaylistModel>(this as SpotifyPlaylistModel, _$identity);

  /// Serializes this SpotifyPlaylistModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpotifyPlaylistModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.tracks, tracks) || other.tracks == tracks)&&const DeepCollectionEquality().equals(other.images, images));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,tracks,const DeepCollectionEquality().hash(images));

@override
String toString() {
  return 'SpotifyPlaylistModel(id: $id, name: $name, tracks: $tracks, images: $images)';
}


}

/// @nodoc
abstract mixin class $SpotifyPlaylistModelCopyWith<$Res>  {
  factory $SpotifyPlaylistModelCopyWith(SpotifyPlaylistModel value, $Res Function(SpotifyPlaylistModel) _then) = _$SpotifyPlaylistModelCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'tracks') SpotifyPlaylistTracksModel? tracks,@JsonKey(name: 'images') List<SpotifyPlaylistImageModel> images
});


$SpotifyPlaylistTracksModelCopyWith<$Res>? get tracks;

}
/// @nodoc
class _$SpotifyPlaylistModelCopyWithImpl<$Res>
    implements $SpotifyPlaylistModelCopyWith<$Res> {
  _$SpotifyPlaylistModelCopyWithImpl(this._self, this._then);

  final SpotifyPlaylistModel _self;
  final $Res Function(SpotifyPlaylistModel) _then;

/// Create a copy of SpotifyPlaylistModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? tracks = freezed,Object? images = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,tracks: freezed == tracks ? _self.tracks : tracks // ignore: cast_nullable_to_non_nullable
as SpotifyPlaylistTracksModel?,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<SpotifyPlaylistImageModel>,
  ));
}
/// Create a copy of SpotifyPlaylistModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpotifyPlaylistTracksModelCopyWith<$Res>? get tracks {
    if (_self.tracks == null) {
    return null;
  }

  return $SpotifyPlaylistTracksModelCopyWith<$Res>(_self.tracks!, (value) {
    return _then(_self.copyWith(tracks: value));
  });
}
}


/// Adds pattern-matching-related methods to [SpotifyPlaylistModel].
extension SpotifyPlaylistModelPatterns on SpotifyPlaylistModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpotifyPlaylistModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpotifyPlaylistModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpotifyPlaylistModel value)  $default,){
final _that = this;
switch (_that) {
case _SpotifyPlaylistModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpotifyPlaylistModel value)?  $default,){
final _that = this;
switch (_that) {
case _SpotifyPlaylistModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'tracks')  SpotifyPlaylistTracksModel? tracks, @JsonKey(name: 'images')  List<SpotifyPlaylistImageModel> images)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpotifyPlaylistModel() when $default != null:
return $default(_that.id,_that.name,_that.tracks,_that.images);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'tracks')  SpotifyPlaylistTracksModel? tracks, @JsonKey(name: 'images')  List<SpotifyPlaylistImageModel> images)  $default,) {final _that = this;
switch (_that) {
case _SpotifyPlaylistModel():
return $default(_that.id,_that.name,_that.tracks,_that.images);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'tracks')  SpotifyPlaylistTracksModel? tracks, @JsonKey(name: 'images')  List<SpotifyPlaylistImageModel> images)?  $default,) {final _that = this;
switch (_that) {
case _SpotifyPlaylistModel() when $default != null:
return $default(_that.id,_that.name,_that.tracks,_that.images);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SpotifyPlaylistModel implements SpotifyPlaylistModel {
  const _SpotifyPlaylistModel({required this.id, required this.name, @JsonKey(name: 'tracks') this.tracks, @JsonKey(name: 'images') final  List<SpotifyPlaylistImageModel> images = const <SpotifyPlaylistImageModel>[]}): _images = images;
  factory _SpotifyPlaylistModel.fromJson(Map<String, dynamic> json) => _$SpotifyPlaylistModelFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'tracks') final  SpotifyPlaylistTracksModel? tracks;
 final  List<SpotifyPlaylistImageModel> _images;
@override@JsonKey(name: 'images') List<SpotifyPlaylistImageModel> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}


/// Create a copy of SpotifyPlaylistModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpotifyPlaylistModelCopyWith<_SpotifyPlaylistModel> get copyWith => __$SpotifyPlaylistModelCopyWithImpl<_SpotifyPlaylistModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SpotifyPlaylistModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpotifyPlaylistModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.tracks, tracks) || other.tracks == tracks)&&const DeepCollectionEquality().equals(other._images, _images));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,tracks,const DeepCollectionEquality().hash(_images));

@override
String toString() {
  return 'SpotifyPlaylistModel(id: $id, name: $name, tracks: $tracks, images: $images)';
}


}

/// @nodoc
abstract mixin class _$SpotifyPlaylistModelCopyWith<$Res> implements $SpotifyPlaylistModelCopyWith<$Res> {
  factory _$SpotifyPlaylistModelCopyWith(_SpotifyPlaylistModel value, $Res Function(_SpotifyPlaylistModel) _then) = __$SpotifyPlaylistModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'tracks') SpotifyPlaylistTracksModel? tracks,@JsonKey(name: 'images') List<SpotifyPlaylistImageModel> images
});


@override $SpotifyPlaylistTracksModelCopyWith<$Res>? get tracks;

}
/// @nodoc
class __$SpotifyPlaylistModelCopyWithImpl<$Res>
    implements _$SpotifyPlaylistModelCopyWith<$Res> {
  __$SpotifyPlaylistModelCopyWithImpl(this._self, this._then);

  final _SpotifyPlaylistModel _self;
  final $Res Function(_SpotifyPlaylistModel) _then;

/// Create a copy of SpotifyPlaylistModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? tracks = freezed,Object? images = null,}) {
  return _then(_SpotifyPlaylistModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,tracks: freezed == tracks ? _self.tracks : tracks // ignore: cast_nullable_to_non_nullable
as SpotifyPlaylistTracksModel?,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<SpotifyPlaylistImageModel>,
  ));
}

/// Create a copy of SpotifyPlaylistModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpotifyPlaylistTracksModelCopyWith<$Res>? get tracks {
    if (_self.tracks == null) {
    return null;
  }

  return $SpotifyPlaylistTracksModelCopyWith<$Res>(_self.tracks!, (value) {
    return _then(_self.copyWith(tracks: value));
  });
}
}


/// @nodoc
mixin _$SpotifyPlaylistTracksModel {

 int? get total;
/// Create a copy of SpotifyPlaylistTracksModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpotifyPlaylistTracksModelCopyWith<SpotifyPlaylistTracksModel> get copyWith => _$SpotifyPlaylistTracksModelCopyWithImpl<SpotifyPlaylistTracksModel>(this as SpotifyPlaylistTracksModel, _$identity);

  /// Serializes this SpotifyPlaylistTracksModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpotifyPlaylistTracksModel&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total);

@override
String toString() {
  return 'SpotifyPlaylistTracksModel(total: $total)';
}


}

/// @nodoc
abstract mixin class $SpotifyPlaylistTracksModelCopyWith<$Res>  {
  factory $SpotifyPlaylistTracksModelCopyWith(SpotifyPlaylistTracksModel value, $Res Function(SpotifyPlaylistTracksModel) _then) = _$SpotifyPlaylistTracksModelCopyWithImpl;
@useResult
$Res call({
 int? total
});




}
/// @nodoc
class _$SpotifyPlaylistTracksModelCopyWithImpl<$Res>
    implements $SpotifyPlaylistTracksModelCopyWith<$Res> {
  _$SpotifyPlaylistTracksModelCopyWithImpl(this._self, this._then);

  final SpotifyPlaylistTracksModel _self;
  final $Res Function(SpotifyPlaylistTracksModel) _then;

/// Create a copy of SpotifyPlaylistTracksModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = freezed,}) {
  return _then(_self.copyWith(
total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [SpotifyPlaylistTracksModel].
extension SpotifyPlaylistTracksModelPatterns on SpotifyPlaylistTracksModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpotifyPlaylistTracksModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpotifyPlaylistTracksModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpotifyPlaylistTracksModel value)  $default,){
final _that = this;
switch (_that) {
case _SpotifyPlaylistTracksModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpotifyPlaylistTracksModel value)?  $default,){
final _that = this;
switch (_that) {
case _SpotifyPlaylistTracksModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpotifyPlaylistTracksModel() when $default != null:
return $default(_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? total)  $default,) {final _that = this;
switch (_that) {
case _SpotifyPlaylistTracksModel():
return $default(_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? total)?  $default,) {final _that = this;
switch (_that) {
case _SpotifyPlaylistTracksModel() when $default != null:
return $default(_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SpotifyPlaylistTracksModel implements SpotifyPlaylistTracksModel {
  const _SpotifyPlaylistTracksModel({this.total});
  factory _SpotifyPlaylistTracksModel.fromJson(Map<String, dynamic> json) => _$SpotifyPlaylistTracksModelFromJson(json);

@override final  int? total;

/// Create a copy of SpotifyPlaylistTracksModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpotifyPlaylistTracksModelCopyWith<_SpotifyPlaylistTracksModel> get copyWith => __$SpotifyPlaylistTracksModelCopyWithImpl<_SpotifyPlaylistTracksModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SpotifyPlaylistTracksModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpotifyPlaylistTracksModel&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total);

@override
String toString() {
  return 'SpotifyPlaylistTracksModel(total: $total)';
}


}

/// @nodoc
abstract mixin class _$SpotifyPlaylistTracksModelCopyWith<$Res> implements $SpotifyPlaylistTracksModelCopyWith<$Res> {
  factory _$SpotifyPlaylistTracksModelCopyWith(_SpotifyPlaylistTracksModel value, $Res Function(_SpotifyPlaylistTracksModel) _then) = __$SpotifyPlaylistTracksModelCopyWithImpl;
@override @useResult
$Res call({
 int? total
});




}
/// @nodoc
class __$SpotifyPlaylistTracksModelCopyWithImpl<$Res>
    implements _$SpotifyPlaylistTracksModelCopyWith<$Res> {
  __$SpotifyPlaylistTracksModelCopyWithImpl(this._self, this._then);

  final _SpotifyPlaylistTracksModel _self;
  final $Res Function(_SpotifyPlaylistTracksModel) _then;

/// Create a copy of SpotifyPlaylistTracksModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = freezed,}) {
  return _then(_SpotifyPlaylistTracksModel(
total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$SpotifyPlaylistImageModel {

 String get url; int? get width; int? get height;
/// Create a copy of SpotifyPlaylistImageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpotifyPlaylistImageModelCopyWith<SpotifyPlaylistImageModel> get copyWith => _$SpotifyPlaylistImageModelCopyWithImpl<SpotifyPlaylistImageModel>(this as SpotifyPlaylistImageModel, _$identity);

  /// Serializes this SpotifyPlaylistImageModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpotifyPlaylistImageModel&&(identical(other.url, url) || other.url == url)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,width,height);

@override
String toString() {
  return 'SpotifyPlaylistImageModel(url: $url, width: $width, height: $height)';
}


}

/// @nodoc
abstract mixin class $SpotifyPlaylistImageModelCopyWith<$Res>  {
  factory $SpotifyPlaylistImageModelCopyWith(SpotifyPlaylistImageModel value, $Res Function(SpotifyPlaylistImageModel) _then) = _$SpotifyPlaylistImageModelCopyWithImpl;
@useResult
$Res call({
 String url, int? width, int? height
});




}
/// @nodoc
class _$SpotifyPlaylistImageModelCopyWithImpl<$Res>
    implements $SpotifyPlaylistImageModelCopyWith<$Res> {
  _$SpotifyPlaylistImageModelCopyWithImpl(this._self, this._then);

  final SpotifyPlaylistImageModel _self;
  final $Res Function(SpotifyPlaylistImageModel) _then;

/// Create a copy of SpotifyPlaylistImageModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? width = freezed,Object? height = freezed,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [SpotifyPlaylistImageModel].
extension SpotifyPlaylistImageModelPatterns on SpotifyPlaylistImageModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpotifyPlaylistImageModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpotifyPlaylistImageModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpotifyPlaylistImageModel value)  $default,){
final _that = this;
switch (_that) {
case _SpotifyPlaylistImageModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpotifyPlaylistImageModel value)?  $default,){
final _that = this;
switch (_that) {
case _SpotifyPlaylistImageModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  int? width,  int? height)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpotifyPlaylistImageModel() when $default != null:
return $default(_that.url,_that.width,_that.height);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  int? width,  int? height)  $default,) {final _that = this;
switch (_that) {
case _SpotifyPlaylistImageModel():
return $default(_that.url,_that.width,_that.height);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  int? width,  int? height)?  $default,) {final _that = this;
switch (_that) {
case _SpotifyPlaylistImageModel() when $default != null:
return $default(_that.url,_that.width,_that.height);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SpotifyPlaylistImageModel implements SpotifyPlaylistImageModel {
  const _SpotifyPlaylistImageModel({required this.url, this.width, this.height});
  factory _SpotifyPlaylistImageModel.fromJson(Map<String, dynamic> json) => _$SpotifyPlaylistImageModelFromJson(json);

@override final  String url;
@override final  int? width;
@override final  int? height;

/// Create a copy of SpotifyPlaylistImageModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpotifyPlaylistImageModelCopyWith<_SpotifyPlaylistImageModel> get copyWith => __$SpotifyPlaylistImageModelCopyWithImpl<_SpotifyPlaylistImageModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SpotifyPlaylistImageModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpotifyPlaylistImageModel&&(identical(other.url, url) || other.url == url)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,width,height);

@override
String toString() {
  return 'SpotifyPlaylistImageModel(url: $url, width: $width, height: $height)';
}


}

/// @nodoc
abstract mixin class _$SpotifyPlaylistImageModelCopyWith<$Res> implements $SpotifyPlaylistImageModelCopyWith<$Res> {
  factory _$SpotifyPlaylistImageModelCopyWith(_SpotifyPlaylistImageModel value, $Res Function(_SpotifyPlaylistImageModel) _then) = __$SpotifyPlaylistImageModelCopyWithImpl;
@override @useResult
$Res call({
 String url, int? width, int? height
});




}
/// @nodoc
class __$SpotifyPlaylistImageModelCopyWithImpl<$Res>
    implements _$SpotifyPlaylistImageModelCopyWith<$Res> {
  __$SpotifyPlaylistImageModelCopyWithImpl(this._self, this._then);

  final _SpotifyPlaylistImageModel _self;
  final $Res Function(_SpotifyPlaylistImageModel) _then;

/// Create a copy of SpotifyPlaylistImageModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? width = freezed,Object? height = freezed,}) {
  return _then(_SpotifyPlaylistImageModel(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
