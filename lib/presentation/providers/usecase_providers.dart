import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/calculate_event_recommendation_score_usecase.dart';
import '../../domain/usecases/calculate_user_compatibility_usecase.dart';
import '../../domain/usecases/events_usecases.dart';
import '../../domain/usecases/events/log_event_interaction_usecase.dart';
import '../../domain/usecases/live_usecases.dart';
import '../../domain/usecases/notifications_usecases.dart';
import '../../domain/usecases/profile_usecases.dart';
import '../../domain/usecases/social_usecases.dart';
import 'core_providers.dart';

final getMyProfileUseCaseProvider = Provider<GetMyProfileUseCase>((ref) {
  return GetMyProfileUseCase(ref.watch(profileRepositoryProvider));
});

final upsertMyProfileUseCaseProvider = Provider<UpsertMyProfileUseCase>((ref) {
  return UpsertMyProfileUseCase(ref.watch(profileRepositoryProvider));
});

final getMyMusicProfileUseCaseProvider =
    Provider<GetMyMusicProfileUseCase>((ref) {
  return GetMyMusicProfileUseCase(ref.watch(profileRepositoryProvider));
});

final searchNearbyEventsUseCaseProvider =
    Provider<SearchNearbyEventsUseCase>((ref) {
  return SearchNearbyEventsUseCase(ref.watch(eventsRepositoryProvider));
});

final searchEventsByArtistUseCaseProvider =
    Provider<SearchEventsByArtistUseCase>((ref) {
  return SearchEventsByArtistUseCase(ref.watch(eventsRepositoryProvider));
});

final getStoredEventsUseCaseProvider = Provider<GetStoredEventsUseCase>((ref) {
  return GetStoredEventsUseCase(ref.watch(eventsRepositoryProvider));
});

final getStoredNearbyEventsUseCaseProvider =
    Provider<GetStoredNearbyEventsUseCase>((ref) {
  return GetStoredNearbyEventsUseCase(ref.watch(eventsRepositoryProvider));
});

final setEventAttendanceUseCaseProvider =
    Provider<SetEventAttendanceUseCase>((ref) {
  return SetEventAttendanceUseCase(ref.watch(eventsRepositoryProvider));
});

final getEventAttendeesUseCaseProvider =
    Provider<GetEventAttendeesUseCase>((ref) {
  return GetEventAttendeesUseCase(ref.watch(eventsRepositoryProvider));
});

final logEventInteractionUseCaseProvider = Provider<LogEventInteractionUseCase>((ref) {
  return LogEventInteractionUseCase(ref.watch(eventsRepositoryProvider));
});

final requestFriendshipUseCaseProvider =
    Provider<RequestFriendshipUseCase>((ref) {
  return RequestFriendshipUseCase(ref.watch(socialRepositoryProvider));
});

final respondFriendshipUseCaseProvider =
    Provider<RespondFriendshipUseCase>((ref) {
  return RespondFriendshipUseCase(ref.watch(socialRepositoryProvider));
});

final listFriendshipsUseCaseProvider = Provider<ListFriendshipsUseCase>((ref) {
  return ListFriendshipsUseCase(ref.watch(socialRepositoryProvider));
});

final sendDirectMessageUseCaseProvider =
    Provider<SendDirectMessageUseCase>((ref) {
  return SendDirectMessageUseCase(ref.watch(socialRepositoryProvider));
});

final getConversationUseCaseProvider = Provider<GetConversationUseCase>((ref) {
  return GetConversationUseCase(ref.watch(socialRepositoryProvider));
});

final streamConversationUseCaseProvider =
    Provider<StreamConversationUseCase>((ref) {
  return StreamConversationUseCase(ref.watch(socialRepositoryProvider));
});

final blockUserUseCaseProvider = Provider<BlockUserUseCase>((ref) {
  return BlockUserUseCase(ref.watch(socialRepositoryProvider));
});

final reportUserUseCaseProvider = Provider<ReportUserUseCase>((ref) {
  return ReportUserUseCase(ref.watch(socialRepositoryProvider));
});

final softDeleteChatUseCaseProvider = Provider<SoftDeleteChatUseCase>((ref) {
  return SoftDeleteChatUseCase(ref.watch(socialRepositoryProvider));
});

final reactToMessageUseCaseProvider = Provider<ReactToMessageUseCase>((ref) {
  return ReactToMessageUseCase(ref.watch(socialRepositoryProvider));
});

final streamLiveMessagesUseCaseProvider =
    Provider<StreamLiveMessagesUseCase>((ref) {
  return StreamLiveMessagesUseCase(ref.watch(liveRepositoryProvider));
});

final sendLiveMessageUseCaseProvider = Provider<SendLiveMessageUseCase>((ref) {
  return SendLiveMessageUseCase(ref.watch(liveRepositoryProvider));
});

final listNotificationsUseCaseProvider =
    Provider<ListNotificationsUseCase>((ref) {
  return ListNotificationsUseCase(ref.watch(notificationsRepositoryProvider));
});

final markNotificationAsReadUseCaseProvider =
    Provider<MarkNotificationAsReadUseCase>((ref) {
  return MarkNotificationAsReadUseCase(
    ref.watch(notificationsRepositoryProvider),
  );
});

final calculateUserCompatibilityUseCaseProvider =
    Provider<CalculateUserCompatibilityUseCase>((ref) {
  return const CalculateUserCompatibilityUseCase();
});

final calculateEventRecommendationScoreUseCaseProvider =
    Provider<CalculateEventRecommendationScoreUseCase>((ref) {
  return const CalculateEventRecommendationScoreUseCase();
});

