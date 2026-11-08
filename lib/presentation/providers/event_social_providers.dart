import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/concert_match.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/event_social.dart';
import 'core_providers.dart';

typedef EventRef = ({String id, String source, String externalId});

EventRef eventRefOf(Event e) =>
    (id: e.id, source: e.source, externalId: e.externalId);

/// Catalogue id for an event shown in the app (provider events may not be
/// stored yet: then nobody can have saved it).
final eventCatalogueIdProvider = FutureProvider.autoDispose
    .family<String?, EventRef>((ref, e) async {
      if (RegExp(r'^[0-9a-f-]{36}$').hasMatch(e.id)) return e.id;
      return ref
          .watch(supabaseEventSocialDatasourceProvider)
          .catalogueId(source: e.source, externalId: e.externalId);
    });

final eventSocialProvider = FutureProvider.autoDispose
    .family<EventSocial, String>(
      (ref, eventId) =>
          ref.watch(supabaseEventSocialDatasourceProvider).social(eventId),
    );

final myAttendanceProvider = FutureProvider.autoDispose
    .family<MyAttendance, String>(
      (ref, eventId) =>
          ref.watch(supabaseEventSocialDatasourceProvider).mine(eventId),
    );

final concertMatchProvider = FutureProvider.autoDispose
    .family<ConcertMatch, String>(
      (ref, eventId) => ref
          .watch(supabaseEventSocialDatasourceProvider)
          .concertMatches(eventId),
    );
