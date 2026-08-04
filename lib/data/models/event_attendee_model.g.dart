// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_attendee_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventAttendeeModel _$EventAttendeeModelFromJson(Map<String, dynamic> json) =>
    _EventAttendeeModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      eventId: json['event_id'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$EventAttendeeModelToJson(_EventAttendeeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'event_id': instance.eventId,
      'status': instance.status,
      'created_at': instance.createdAt?.toIso8601String(),
    };
