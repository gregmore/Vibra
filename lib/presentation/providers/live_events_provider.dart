import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/db_tables.dart';
import '../../core/utils/geography.dart';
import '../../data/mappers/domain_mappers.dart';
import '../../data/models/event_model.dart';
import '../../domain/entities/event.dart';
import 'core_providers.dart';
import 'location_provider.dart';

/// Uses the same proximity and time window as the live-message RLS policy.
/// The Milano browsing fallback is never evidence of physical presence.
List<Event> eligibleLiveEvents({
  required Iterable<Event> events,
  required UserLocation location,
  required DateTime now,
}) {
  if (!location.isDeviceLocation ||
      !areValidCoordinates(location.latitude, location.longitude)) {
    return const [];
  }
  const distance = Distance(roundResult: false);
  final origin = LatLng(location.latitude, location.longitude);
  final window = const Duration(hours: AppConstants.liveChatExpirationHours);
  final eligible = events.where((event) {
    if (event.id.isEmpty ||
        !areValidCoordinates(event.latitude, event.longitude) ||
        const {'canceled', 'cancelled'}.contains(event.status) ||
        event.eventDate.isBefore(now.subtract(window)) ||
        event.eventDate.isAfter(now.add(window))) {
      return false;
    }
    return distance.as(
          LengthUnit.Meter,
          origin,
          LatLng(event.latitude!, event.longitude!),
        ) <=
        AppConstants.liveActivationRadiusMeters;
  }).toList();
  eligible.sort((a, b) {
    final aDistance = distance(origin, LatLng(a.latitude!, a.longitude!));
    final bDistance = distance(origin, LatLng(b.latitude!, b.longitude!));
    final order = aDistance.compareTo(bDistance);
    return order == 0 ? a.eventDate.compareTo(b.eventDate) : order;
  });
  return eligible;
}

final liveEventsProvider = FutureProvider.autoDispose<List<Event>>((ref) async {
  final location = await ref.watch(userLocationProvider.future);
  if (!location.isDeviceLocation) return const [];
  final now = DateTime.now().toUtc();
  const window = Duration(hours: AppConstants.liveChatExpirationHours);
  final rows = await ref
      .watch(supabaseDatasourceProvider)
      .client
      .from(DbTables.events)
      .select()
      .gte('event_date', now.subtract(window).toIso8601String())
      .lte('event_date', now.add(window).toIso8601String());
  return eligibleLiveEvents(
    events: rows.map((row) => EventModel.fromJson(row).toEntity()),
    location: location,
    now: now,
  );
});

final liveAttendanceProvider = FutureProvider.autoDispose
    .family<String?, String>((ref, eventId) async {
      final ds = ref.watch(supabaseDatasourceProvider);
      final user = ds.currentUser;
      if (user == null) return null;
      final row = await ds.client
          .from(DbTables.eventAttendees)
          .select('status')
          .eq('user_id', user.id)
          .eq('event_id', eventId)
          .maybeSingle();
      return row?['status'] as String?;
    });
