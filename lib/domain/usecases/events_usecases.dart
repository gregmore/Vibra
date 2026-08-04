import '../entities/event.dart';
import '../repositories/events_repository.dart';
import 'usecase.dart';

class SearchNearbyEventsParams {
  const SearchNearbyEventsParams({
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
  });

  final double latitude;
  final double longitude;
  final int radiusKm;
}

class SearchNearbyEventsUseCase
    implements UseCase<List<Event>, SearchNearbyEventsParams> {
  SearchNearbyEventsUseCase(this._repository);

  final EventsRepository _repository;

  @override
  Future<List<Event>> call(SearchNearbyEventsParams params) {
    return _repository.searchNearbyExternal(
      latitude: params.latitude,
      longitude: params.longitude,
      radiusKm: params.radiusKm,
    );
  }
}

class SearchEventsByArtistParams {
  const SearchEventsByArtistParams({
    required this.artistName,
    this.spotifyArtistId,
  });

  final String artistName;
  final String? spotifyArtistId;
}

class SearchEventsByArtistUseCase
    implements UseCase<List<Event>, SearchEventsByArtistParams> {
  SearchEventsByArtistUseCase(this._repository);

  final EventsRepository _repository;

  @override
  Future<List<Event>> call(SearchEventsByArtistParams params) {
    return _repository.searchByArtistExternal(
      artistName: params.artistName,
      spotifyArtistId: params.spotifyArtistId,
    );
  }
}

class GetStoredEventsUseCase implements UseCase<List<Event>, int> {
  GetStoredEventsUseCase(this._repository);

  final EventsRepository _repository;

  @override
  Future<List<Event>> call(int params) {
    return _repository.listEventsFromDb(limit: params);
  }
}

class GetStoredNearbyEventsParams {
  const GetStoredNearbyEventsParams({
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });

  final double latitude;
  final double longitude;
  final double radiusMeters;
}

class GetStoredNearbyEventsUseCase
    implements UseCase<List<Event>, GetStoredNearbyEventsParams> {
  GetStoredNearbyEventsUseCase(this._repository);

  final EventsRepository _repository;

  @override
  Future<List<Event>> call(GetStoredNearbyEventsParams params) {
    return _repository.listNearbyEventsFromDb(
      latitude: params.latitude,
      longitude: params.longitude,
      radiusMeters: params.radiusMeters,
    );
  }
}

class SetEventAttendanceParams {
  const SetEventAttendanceParams({required this.event, required this.status});

  final Event event;
  final String status;
}

class SetEventAttendanceUseCase
    implements UseCase<EventAttendee, SetEventAttendanceParams> {
  SetEventAttendanceUseCase(this._repository);

  final EventsRepository _repository;

  @override
  Future<EventAttendee> call(SetEventAttendanceParams params) {
    return _repository.setAttendance(
      event: params.event,
      status: params.status,
    );
  }
}

class GetEventAttendeesUseCase implements UseCase<List<EventAttendee>, String> {
  GetEventAttendeesUseCase(this._repository);

  final EventsRepository _repository;

  @override
  Future<List<EventAttendee>> call(String params) {
    return _repository.listAttendees(eventId: params);
  }
}
