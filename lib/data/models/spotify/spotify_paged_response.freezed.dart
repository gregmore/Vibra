// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spotify_paged_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SpotifyPagedResponse {

 List<dynamic> get items; int? get total; int? get limit; int? get offset; String? get next; String? get previous;
/// Create a copy of SpotifyPagedResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpotifyPagedResponseCopyWith<SpotifyPagedResponse> get copyWith => _$SpotifyPagedResponseCopyWithImpl<SpotifyPagedResponse>(this as SpotifyPagedResponse, _$identity);

  /// Serializes this SpotifyPagedResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpotifyPagedResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.total, total) || other.total == total)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.next, next) || other.next == next)&&(identical(other.previous, previous) || other.previous == previous));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),total,limit,offset,next,previous);

@override
String toString() {
  return 'SpotifyPagedResponse(items: $items, total: $total, limit: $limit, offset: $offset, next: $next, previous: $previous)';
}


}

/// @nodoc
abstract mixin class $SpotifyPagedResponseCopyWith<$Res>  {
  factory $SpotifyPagedResponseCopyWith(SpotifyPagedResponse value, $Res Function(SpotifyPagedResponse) _then) = _$SpotifyPagedResponseCopyWithImpl;
@useResult
$Res call({
 List<dynamic> items, int? total, int? limit, int? offset, String? next, String? previous
});




}
/// @nodoc
class _$SpotifyPagedResponseCopyWithImpl<$Res>
    implements $SpotifyPagedResponseCopyWith<$Res> {
  _$SpotifyPagedResponseCopyWithImpl(this._self, this._then);

  final SpotifyPagedResponse _self;
  final $Res Function(SpotifyPagedResponse) _then;

/// Create a copy of SpotifyPagedResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = freezed,Object? limit = freezed,Object? offset = freezed,Object? next = freezed,Object? previous = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<dynamic>,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,offset: freezed == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int?,next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as String?,previous: freezed == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SpotifyPagedResponse].
extension SpotifyPagedResponsePatterns on SpotifyPagedResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpotifyPagedResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpotifyPagedResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpotifyPagedResponse value)  $default,){
final _that = this;
switch (_that) {
case _SpotifyPagedResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpotifyPagedResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SpotifyPagedResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<dynamic> items,  int? total,  int? limit,  int? offset,  String? next,  String? previous)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpotifyPagedResponse() when $default != null:
return $default(_that.items,_that.total,_that.limit,_that.offset,_that.next,_that.previous);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<dynamic> items,  int? total,  int? limit,  int? offset,  String? next,  String? previous)  $default,) {final _that = this;
switch (_that) {
case _SpotifyPagedResponse():
return $default(_that.items,_that.total,_that.limit,_that.offset,_that.next,_that.previous);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<dynamic> items,  int? total,  int? limit,  int? offset,  String? next,  String? previous)?  $default,) {final _that = this;
switch (_that) {
case _SpotifyPagedResponse() when $default != null:
return $default(_that.items,_that.total,_that.limit,_that.offset,_that.next,_that.previous);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SpotifyPagedResponse implements SpotifyPagedResponse {
  const _SpotifyPagedResponse({final  List<dynamic> items = const <dynamic>[], this.total, this.limit, this.offset, this.next, this.previous}): _items = items;
  factory _SpotifyPagedResponse.fromJson(Map<String, dynamic> json) => _$SpotifyPagedResponseFromJson(json);

 final  List<dynamic> _items;
@override@JsonKey() List<dynamic> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int? total;
@override final  int? limit;
@override final  int? offset;
@override final  String? next;
@override final  String? previous;

/// Create a copy of SpotifyPagedResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpotifyPagedResponseCopyWith<_SpotifyPagedResponse> get copyWith => __$SpotifyPagedResponseCopyWithImpl<_SpotifyPagedResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SpotifyPagedResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpotifyPagedResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.next, next) || other.next == next)&&(identical(other.previous, previous) || other.previous == previous));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total,limit,offset,next,previous);

@override
String toString() {
  return 'SpotifyPagedResponse(items: $items, total: $total, limit: $limit, offset: $offset, next: $next, previous: $previous)';
}


}

/// @nodoc
abstract mixin class _$SpotifyPagedResponseCopyWith<$Res> implements $SpotifyPagedResponseCopyWith<$Res> {
  factory _$SpotifyPagedResponseCopyWith(_SpotifyPagedResponse value, $Res Function(_SpotifyPagedResponse) _then) = __$SpotifyPagedResponseCopyWithImpl;
@override @useResult
$Res call({
 List<dynamic> items, int? total, int? limit, int? offset, String? next, String? previous
});




}
/// @nodoc
class __$SpotifyPagedResponseCopyWithImpl<$Res>
    implements _$SpotifyPagedResponseCopyWith<$Res> {
  __$SpotifyPagedResponseCopyWithImpl(this._self, this._then);

  final _SpotifyPagedResponse _self;
  final $Res Function(_SpotifyPagedResponse) _then;

/// Create a copy of SpotifyPagedResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = freezed,Object? limit = freezed,Object? offset = freezed,Object? next = freezed,Object? previous = freezed,}) {
  return _then(_SpotifyPagedResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<dynamic>,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,offset: freezed == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int?,next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as String?,previous: freezed == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
