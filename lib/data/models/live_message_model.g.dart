// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LiveMessageModel _$LiveMessageModelFromJson(Map<String, dynamic> json) =>
    _LiveMessageModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$LiveMessageModelToJson(_LiveMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event_id': instance.eventId,
      'user_id': instance.userId,
      'content': instance.content,
      'created_at': instance.createdAt?.toIso8601String(),
    };
