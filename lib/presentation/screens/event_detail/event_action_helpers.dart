import 'package:intl/intl.dart';

import '../../../core/utils/geography.dart';
import '../../../domain/entities/event.dart';

Uri? eventTicketUri(Event event) {
  if (const {'canceled', 'cancelled', 'offsale'}.contains(event.status)) {
    return null;
  }
  final uri = Uri.tryParse(event.ticketUrl?.trim() ?? '');
  if (uri == null ||
      !const {'http', 'https'}.contains(uri.scheme) ||
      uri.host.isEmpty) {
    return null;
  }
  return uri;
}

({double latitude, double longitude})? eventCoordinates(Event event) {
  final latitude = event.latitude;
  final longitude = event.longitude;
  if (!areValidCoordinates(latitude, longitude)) {
    return null;
  }
  return (latitude: latitude!, longitude: longitude!);
}

Uri? eventDirectionsUri(Event event) {
  final coordinates = eventCoordinates(event);
  final address = [event.venueName, event.city, event.country]
      .whereType<String>()
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .join(', ');
  final destination = coordinates == null
      ? address
      : '${coordinates.latitude},${coordinates.longitude}';
  if (destination.isEmpty) return null;
  return Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': destination,
  });
}

String eventPlaceLabel(Event event) => [event.venueName, event.city]
    .whereType<String>()
    .map((value) => value.trim())
    .where((value) => value.isNotEmpty)
    .join(' · ');

String eventDetailsText(Event event, String locale) {
  final place = eventPlaceLabel(event);
  final tickets = eventTicketUri(event);
  return [
    event.name,
    if (place.isNotEmpty) place,
    DateFormat.yMMMd(locale).format(event.eventDate.toLocal()),
    if (tickets != null) tickets.toString(),
  ].join('\n');
}
