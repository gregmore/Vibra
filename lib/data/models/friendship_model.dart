import 'package:freezed_annotation/freezed_annotation.dart';

part 'friendship_model.freezed.dart';
part 'friendship_model.g.dart';

@freezed
abstract class FriendshipModel with _$FriendshipModel {
  const factory FriendshipModel({
    required String id,
    @JsonKey(name: 'requester_id') required String requesterId,
    @JsonKey(name: 'receiver_id') required String receiverId,
    required String status, // pending|accepted|rejected
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _FriendshipModel;

  factory FriendshipModel.fromJson(Map<String, dynamic> json) =>
      _$FriendshipModelFromJson(json);
}
