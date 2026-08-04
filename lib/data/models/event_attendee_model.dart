import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_attendee_model.freezed.dart';
part 'event_attendee_model.g.dart';

@freezed
abstract class EventAttendeeModel with _$EventAttendeeModel {
  const factory EventAttendeeModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'event_id') required String eventId,
    required String status, // going|maybe|not_going
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _EventAttendeeModel;

  factory EventAttendeeModel.fromJson(Map<String, dynamic> json) =>
      _$EventAttendeeModelFromJson(json);
}
