// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_attendee_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventAttendeeModel {

 String get id;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'event_id') String get eventId; String get status;// going|maybe|not_going
@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of EventAttendeeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventAttendeeModelCopyWith<EventAttendeeModel> get copyWith => _$EventAttendeeModelCopyWithImpl<EventAttendeeModel>(this as EventAttendeeModel, _$identity);

  /// Serializes this EventAttendeeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventAttendeeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,eventId,status,createdAt);

@override
String toString() {
  return 'EventAttendeeModel(id: $id, userId: $userId, eventId: $eventId, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $EventAttendeeModelCopyWith<$Res>  {
  factory $EventAttendeeModelCopyWith(EventAttendeeModel value, $Res Function(EventAttendeeModel) _then) = _$EventAttendeeModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'event_id') String eventId, String status,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$EventAttendeeModelCopyWithImpl<$Res>
    implements $EventAttendeeModelCopyWith<$Res> {
  _$EventAttendeeModelCopyWithImpl(this._self, this._then);

  final EventAttendeeModel _self;
  final $Res Function(EventAttendeeModel) _then;

/// Create a copy of EventAttendeeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? eventId = null,Object? status = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventAttendeeModel].
extension EventAttendeeModelPatterns on EventAttendeeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventAttendeeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventAttendeeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventAttendeeModel value)  $default,){
final _that = this;
switch (_that) {
case _EventAttendeeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventAttendeeModel value)?  $default,){
final _that = this;
switch (_that) {
case _EventAttendeeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'event_id')  String eventId,  String status, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventAttendeeModel() when $default != null:
return $default(_that.id,_that.userId,_that.eventId,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'event_id')  String eventId,  String status, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _EventAttendeeModel():
return $default(_that.id,_that.userId,_that.eventId,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'event_id')  String eventId,  String status, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _EventAttendeeModel() when $default != null:
return $default(_that.id,_that.userId,_that.eventId,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventAttendeeModel implements EventAttendeeModel {
  const _EventAttendeeModel({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'event_id') required this.eventId, required this.status, @JsonKey(name: 'created_at') this.createdAt});
  factory _EventAttendeeModel.fromJson(Map<String, dynamic> json) => _$EventAttendeeModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'event_id') final  String eventId;
@override final  String status;
// going|maybe|not_going
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of EventAttendeeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventAttendeeModelCopyWith<_EventAttendeeModel> get copyWith => __$EventAttendeeModelCopyWithImpl<_EventAttendeeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventAttendeeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventAttendeeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,eventId,status,createdAt);

@override
String toString() {
  return 'EventAttendeeModel(id: $id, userId: $userId, eventId: $eventId, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$EventAttendeeModelCopyWith<$Res> implements $EventAttendeeModelCopyWith<$Res> {
  factory _$EventAttendeeModelCopyWith(_EventAttendeeModel value, $Res Function(_EventAttendeeModel) _then) = __$EventAttendeeModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'event_id') String eventId, String status,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$EventAttendeeModelCopyWithImpl<$Res>
    implements _$EventAttendeeModelCopyWith<$Res> {
  __$EventAttendeeModelCopyWithImpl(this._self, this._then);

  final _EventAttendeeModel _self;
  final $Res Function(_EventAttendeeModel) _then;

/// Create a copy of EventAttendeeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? eventId = null,Object? status = null,Object? createdAt = freezed,}) {
  return _then(_EventAttendeeModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
