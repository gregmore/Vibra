// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spotify_artist_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SpotifyArtistModel {

 String get id; String get name; List<String> get genres;@JsonKey(name: 'followers') SpotifyFollowersModel? get followers;@JsonKey(name: 'images') List<SpotifyImageModel> get images; int? get popularity;
/// Create a copy of SpotifyArtistModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpotifyArtistModelCopyWith<SpotifyArtistModel> get copyWith => _$SpotifyArtistModelCopyWithImpl<SpotifyArtistModel>(this as SpotifyArtistModel, _$identity);

  /// Serializes this SpotifyArtistModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpotifyArtistModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.genres, genres)&&(identical(other.followers, followers) || other.followers == followers)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.popularity, popularity) || other.popularity == popularity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(genres),followers,const DeepCollectionEquality().hash(images),popularity);

@override
String toString() {
  return 'SpotifyArtistModel(id: $id, name: $name, genres: $genres, followers: $followers, images: $images, popularity: $popularity)';
}


}

/// @nodoc
abstract mixin class $SpotifyArtistModelCopyWith<$Res>  {
  factory $SpotifyArtistModelCopyWith(SpotifyArtistModel value, $Res Function(SpotifyArtistModel) _then) = _$SpotifyArtistModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<String> genres,@JsonKey(name: 'followers') SpotifyFollowersModel? followers,@JsonKey(name: 'images') List<SpotifyImageModel> images, int? popularity
});


$SpotifyFollowersModelCopyWith<$Res>? get followers;

}
/// @nodoc
class _$SpotifyArtistModelCopyWithImpl<$Res>
    implements $SpotifyArtistModelCopyWith<$Res> {
  _$SpotifyArtistModelCopyWithImpl(this._self, this._then);

  final SpotifyArtistModel _self;
  final $Res Function(SpotifyArtistModel) _then;

/// Create a copy of SpotifyArtistModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? genres = null,Object? followers = freezed,Object? images = null,Object? popularity = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,followers: freezed == followers ? _self.followers : followers // ignore: cast_nullable_to_non_nullable
as SpotifyFollowersModel?,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<SpotifyImageModel>,popularity: freezed == popularity ? _self.popularity : popularity // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of SpotifyArtistModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpotifyFollowersModelCopyWith<$Res>? get followers {
    if (_self.followers == null) {
    return null;
  }

  return $SpotifyFollowersModelCopyWith<$Res>(_self.followers!, (value) {
    return _then(_self.copyWith(followers: value));
  });
}
}


/// Adds pattern-matching-related methods to [SpotifyArtistModel].
extension SpotifyArtistModelPatterns on SpotifyArtistModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpotifyArtistModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpotifyArtistModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpotifyArtistModel value)  $default,){
final _that = this;
switch (_that) {
case _SpotifyArtistModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpotifyArtistModel value)?  $default,){
final _that = this;
switch (_that) {
case _SpotifyArtistModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<String> genres, @JsonKey(name: 'followers')  SpotifyFollowersModel? followers, @JsonKey(name: 'images')  List<SpotifyImageModel> images,  int? popularity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpotifyArtistModel() when $default != null:
return $default(_that.id,_that.name,_that.genres,_that.followers,_that.images,_that.popularity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<String> genres, @JsonKey(name: 'followers')  SpotifyFollowersModel? followers, @JsonKey(name: 'images')  List<SpotifyImageModel> images,  int? popularity)  $default,) {final _that = this;
switch (_that) {
case _SpotifyArtistModel():
return $default(_that.id,_that.name,_that.genres,_that.followers,_that.images,_that.popularity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<String> genres, @JsonKey(name: 'followers')  SpotifyFollowersModel? followers, @JsonKey(name: 'images')  List<SpotifyImageModel> images,  int? popularity)?  $default,) {final _that = this;
switch (_that) {
case _SpotifyArtistModel() when $default != null:
return $default(_that.id,_that.name,_that.genres,_that.followers,_that.images,_that.popularity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SpotifyArtistModel implements SpotifyArtistModel {
  const _SpotifyArtistModel({required this.id, required this.name, final  List<String> genres = const <String>[], @JsonKey(name: 'followers') this.followers, @JsonKey(name: 'images') final  List<SpotifyImageModel> images = const <SpotifyImageModel>[], this.popularity}): _genres = genres,_images = images;
  factory _SpotifyArtistModel.fromJson(Map<String, dynamic> json) => _$SpotifyArtistModelFromJson(json);

@override final  String id;
@override final  String name;
 final  List<String> _genres;
@override@JsonKey() List<String> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

@override@JsonKey(name: 'followers') final  SpotifyFollowersModel? followers;
 final  List<SpotifyImageModel> _images;
@override@JsonKey(name: 'images') List<SpotifyImageModel> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override final  int? popularity;

/// Create a copy of SpotifyArtistModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpotifyArtistModelCopyWith<_SpotifyArtistModel> get copyWith => __$SpotifyArtistModelCopyWithImpl<_SpotifyArtistModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SpotifyArtistModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpotifyArtistModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._genres, _genres)&&(identical(other.followers, followers) || other.followers == followers)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.popularity, popularity) || other.popularity == popularity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_genres),followers,const DeepCollectionEquality().hash(_images),popularity);

@override
String toString() {
  return 'SpotifyArtistModel(id: $id, name: $name, genres: $genres, followers: $followers, images: $images, popularity: $popularity)';
}


}

/// @nodoc
abstract mixin class _$SpotifyArtistModelCopyWith<$Res> implements $SpotifyArtistModelCopyWith<$Res> {
  factory _$SpotifyArtistModelCopyWith(_SpotifyArtistModel value, $Res Function(_SpotifyArtistModel) _then) = __$SpotifyArtistModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<String> genres,@JsonKey(name: 'followers') SpotifyFollowersModel? followers,@JsonKey(name: 'images') List<SpotifyImageModel> images, int? popularity
});


@override $SpotifyFollowersModelCopyWith<$Res>? get followers;

}
/// @nodoc
class __$SpotifyArtistModelCopyWithImpl<$Res>
    implements _$SpotifyArtistModelCopyWith<$Res> {
  __$SpotifyArtistModelCopyWithImpl(this._self, this._then);

  final _SpotifyArtistModel _self;
  final $Res Function(_SpotifyArtistModel) _then;

/// Create a copy of SpotifyArtistModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? genres = null,Object? followers = freezed,Object? images = null,Object? popularity = freezed,}) {
  return _then(_SpotifyArtistModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,followers: freezed == followers ? _self.followers : followers // ignore: cast_nullable_to_non_nullable
as SpotifyFollowersModel?,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<SpotifyImageModel>,popularity: freezed == popularity ? _self.popularity : popularity // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of SpotifyArtistModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpotifyFollowersModelCopyWith<$Res>? get followers {
    if (_self.followers == null) {
    return null;
  }

  return $SpotifyFollowersModelCopyWith<$Res>(_self.followers!, (value) {
    return _then(_self.copyWith(followers: value));
  });
}
}


/// @nodoc
mixin _$SpotifyFollowersModel {

 int? get total;
/// Create a copy of SpotifyFollowersModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpotifyFollowersModelCopyWith<SpotifyFollowersModel> get copyWith => _$SpotifyFollowersModelCopyWithImpl<SpotifyFollowersModel>(this as SpotifyFollowersModel, _$identity);

  /// Serializes this SpotifyFollowersModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpotifyFollowersModel&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total);

@override
String toString() {
  return 'SpotifyFollowersModel(total: $total)';
}


}

/// @nodoc
abstract mixin class $SpotifyFollowersModelCopyWith<$Res>  {
  factory $SpotifyFollowersModelCopyWith(SpotifyFollowersModel value, $Res Function(SpotifyFollowersModel) _then) = _$SpotifyFollowersModelCopyWithImpl;
@useResult
$Res call({
 int? total
});




}
/// @nodoc
class _$SpotifyFollowersModelCopyWithImpl<$Res>
    implements $SpotifyFollowersModelCopyWith<$Res> {
  _$SpotifyFollowersModelCopyWithImpl(this._self, this._then);

  final SpotifyFollowersModel _self;
  final $Res Function(SpotifyFollowersModel) _then;

/// Create a copy of SpotifyFollowersModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = freezed,}) {
  return _then(_self.copyWith(
total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [SpotifyFollowersModel].
extension SpotifyFollowersModelPatterns on SpotifyFollowersModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpotifyFollowersModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpotifyFollowersModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpotifyFollowersModel value)  $default,){
final _that = this;
switch (_that) {
case _SpotifyFollowersModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpotifyFollowersModel value)?  $default,){
final _that = this;
switch (_that) {
case _SpotifyFollowersModel() when $default != null:
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
case _SpotifyFollowersModel() when $default != null:
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
case _SpotifyFollowersModel():
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
case _SpotifyFollowersModel() when $default != null:
return $default(_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SpotifyFollowersModel implements SpotifyFollowersModel {
  const _SpotifyFollowersModel({this.total});
  factory _SpotifyFollowersModel.fromJson(Map<String, dynamic> json) => _$SpotifyFollowersModelFromJson(json);

@override final  int? total;

/// Create a copy of SpotifyFollowersModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpotifyFollowersModelCopyWith<_SpotifyFollowersModel> get copyWith => __$SpotifyFollowersModelCopyWithImpl<_SpotifyFollowersModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SpotifyFollowersModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpotifyFollowersModel&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total);

@override
String toString() {
  return 'SpotifyFollowersModel(total: $total)';
}


}

/// @nodoc
abstract mixin class _$SpotifyFollowersModelCopyWith<$Res> implements $SpotifyFollowersModelCopyWith<$Res> {
  factory _$SpotifyFollowersModelCopyWith(_SpotifyFollowersModel value, $Res Function(_SpotifyFollowersModel) _then) = __$SpotifyFollowersModelCopyWithImpl;
@override @useResult
$Res call({
 int? total
});




}
/// @nodoc
class __$SpotifyFollowersModelCopyWithImpl<$Res>
    implements _$SpotifyFollowersModelCopyWith<$Res> {
  __$SpotifyFollowersModelCopyWithImpl(this._self, this._then);

  final _SpotifyFollowersModel _self;
  final $Res Function(_SpotifyFollowersModel) _then;

/// Create a copy of SpotifyFollowersModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = freezed,}) {
  return _then(_SpotifyFollowersModel(
total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$SpotifyImageModel {

 String get url; int? get width; int? get height;
/// Create a copy of SpotifyImageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpotifyImageModelCopyWith<SpotifyImageModel> get copyWith => _$SpotifyImageModelCopyWithImpl<SpotifyImageModel>(this as SpotifyImageModel, _$identity);

  /// Serializes this SpotifyImageModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpotifyImageModel&&(identical(other.url, url) || other.url == url)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,width,height);

@override
String toString() {
  return 'SpotifyImageModel(url: $url, width: $width, height: $height)';
}


}

/// @nodoc
abstract mixin class $SpotifyImageModelCopyWith<$Res>  {
  factory $SpotifyImageModelCopyWith(SpotifyImageModel value, $Res Function(SpotifyImageModel) _then) = _$SpotifyImageModelCopyWithImpl;
@useResult
$Res call({
 String url, int? width, int? height
});




}
/// @nodoc
class _$SpotifyImageModelCopyWithImpl<$Res>
    implements $SpotifyImageModelCopyWith<$Res> {
  _$SpotifyImageModelCopyWithImpl(this._self, this._then);

  final SpotifyImageModel _self;
  final $Res Function(SpotifyImageModel) _then;

/// Create a copy of SpotifyImageModel
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


/// Adds pattern-matching-related methods to [SpotifyImageModel].
extension SpotifyImageModelPatterns on SpotifyImageModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpotifyImageModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpotifyImageModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpotifyImageModel value)  $default,){
final _that = this;
switch (_that) {
case _SpotifyImageModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpotifyImageModel value)?  $default,){
final _that = this;
switch (_that) {
case _SpotifyImageModel() when $default != null:
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
case _SpotifyImageModel() when $default != null:
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
case _SpotifyImageModel():
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
case _SpotifyImageModel() when $default != null:
return $default(_that.url,_that.width,_that.height);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SpotifyImageModel implements SpotifyImageModel {
  const _SpotifyImageModel({required this.url, this.width, this.height});
  factory _SpotifyImageModel.fromJson(Map<String, dynamic> json) => _$SpotifyImageModelFromJson(json);

@override final  String url;
@override final  int? width;
@override final  int? height;

/// Create a copy of SpotifyImageModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpotifyImageModelCopyWith<_SpotifyImageModel> get copyWith => __$SpotifyImageModelCopyWithImpl<_SpotifyImageModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SpotifyImageModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpotifyImageModel&&(identical(other.url, url) || other.url == url)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,width,height);

@override
String toString() {
  return 'SpotifyImageModel(url: $url, width: $width, height: $height)';
}


}

/// @nodoc
abstract mixin class _$SpotifyImageModelCopyWith<$Res> implements $SpotifyImageModelCopyWith<$Res> {
  factory _$SpotifyImageModelCopyWith(_SpotifyImageModel value, $Res Function(_SpotifyImageModel) _then) = __$SpotifyImageModelCopyWithImpl;
@override @useResult
$Res call({
 String url, int? width, int? height
});




}
/// @nodoc
class __$SpotifyImageModelCopyWithImpl<$Res>
    implements _$SpotifyImageModelCopyWith<$Res> {
  __$SpotifyImageModelCopyWithImpl(this._self, this._then);

  final _SpotifyImageModel _self;
  final $Res Function(_SpotifyImageModel) _then;

/// Create a copy of SpotifyImageModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? width = freezed,Object? height = freezed,}) {
  return _then(_SpotifyImageModel(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
