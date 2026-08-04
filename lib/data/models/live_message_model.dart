import 'package:freezed_annotation/freezed_annotation.dart';

part 'live_message_model.freezed.dart';
part 'live_message_model.g.dart';

@freezed
abstract class LiveMessageModel with _$LiveMessageModel {
  const factory LiveMessageModel({
    required String id,
    @JsonKey(name: 'event_id') required String eventId,
    @JsonKey(name: 'user_id') required String userId,
    required String content,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _LiveMessageModel;

  factory LiveMessageModel.fromJson(Map<String, dynamic> json) =>
      _$LiveMessageModelFromJson(json);
}
