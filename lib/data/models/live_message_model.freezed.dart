// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'live_message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LiveMessageModel {

 String get id;@JsonKey(name: 'event_id') String get eventId;@JsonKey(name: 'user_id') String get userId; String get content;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of LiveMessageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveMessageModelCopyWith<LiveMessageModel> get copyWith => _$LiveMessageModelCopyWithImpl<LiveMessageModel>(this as LiveMessageModel, _$identity);

  /// Serializes this LiveMessageModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveMessageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,userId,content,createdAt);

@override
String toString() {
  return 'LiveMessageModel(id: $id, eventId: $eventId, userId: $userId, content: $content, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $LiveMessageModelCopyWith<$Res>  {
  factory $LiveMessageModelCopyWith(LiveMessageModel value, $Res Function(LiveMessageModel) _then) = _$LiveMessageModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'event_id') String eventId,@JsonKey(name: 'user_id') String userId, String content,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$LiveMessageModelCopyWithImpl<$Res>
    implements $LiveMessageModelCopyWith<$Res> {
  _$LiveMessageModelCopyWithImpl(this._self, this._then);

  final LiveMessageModel _self;
  final $Res Function(LiveMessageModel) _then;

/// Create a copy of LiveMessageModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? eventId = null,Object? userId = null,Object? content = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [LiveMessageModel].
extension LiveMessageModelPatterns on LiveMessageModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveMessageModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveMessageModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveMessageModel value)  $default,){
final _that = this;
switch (_that) {
case _LiveMessageModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveMessageModel value)?  $default,){
final _that = this;
switch (_that) {
case _LiveMessageModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'event_id')  String eventId, @JsonKey(name: 'user_id')  String userId,  String content, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveMessageModel() when $default != null:
return $default(_that.id,_that.eventId,_that.userId,_that.content,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'event_id')  String eventId, @JsonKey(name: 'user_id')  String userId,  String content, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _LiveMessageModel():
return $default(_that.id,_that.eventId,_that.userId,_that.content,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'event_id')  String eventId, @JsonKey(name: 'user_id')  String userId,  String content, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _LiveMessageModel() when $default != null:
return $default(_that.id,_that.eventId,_that.userId,_that.content,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LiveMessageModel implements LiveMessageModel {
  const _LiveMessageModel({required this.id, @JsonKey(name: 'event_id') required this.eventId, @JsonKey(name: 'user_id') required this.userId, required this.content, @JsonKey(name: 'created_at') this.createdAt});
  factory _LiveMessageModel.fromJson(Map<String, dynamic> json) => _$LiveMessageModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'event_id') final  String eventId;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String content;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of LiveMessageModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveMessageModelCopyWith<_LiveMessageModel> get copyWith => __$LiveMessageModelCopyWithImpl<_LiveMessageModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiveMessageModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveMessageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,userId,content,createdAt);

@override
String toString() {
  return 'LiveMessageModel(id: $id, eventId: $eventId, userId: $userId, content: $content, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$LiveMessageModelCopyWith<$Res> implements $LiveMessageModelCopyWith<$Res> {
  factory _$LiveMessageModelCopyWith(_LiveMessageModel value, $Res Function(_LiveMessageModel) _then) = __$LiveMessageModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'event_id') String eventId,@JsonKey(name: 'user_id') String userId, String content,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$LiveMessageModelCopyWithImpl<$Res>
    implements _$LiveMessageModelCopyWith<$Res> {
  __$LiveMessageModelCopyWithImpl(this._self, this._then);

  final _LiveMessageModel _self;
  final $Res Function(_LiveMessageModel) _then;

/// Create a copy of LiveMessageModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? eventId = null,Object? userId = null,Object? content = null,Object? createdAt = freezed,}) {
  return _then(_LiveMessageModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
