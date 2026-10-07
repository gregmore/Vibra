import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';

/// Datasource Songkick.
/// Nota: la Discovery API di Songkick usa key via query param `apikey`.
class SongkickDatasource {
  SongkickDatasource({required this.dio, required this.apiKey});

  final Dio dio;
  final String apiKey;

  /// Cerca eventi per posizione e combina fino a cinque pagine di risultati.
  /// Songkick localizza le coordinate in una metro area e non supporta un
  /// raggio chilometrico per questo endpoint.
  Future<Map<String, dynamic>> searchEvents({
    required double latitude,
    required double longitude,
    int page = 1,
  }) async {
    try {
      const perPage = 50;
      const maxPages = 5;
      final events = <dynamic>[];
      var currentPage = page;
      var totalEntries = 0;

      while (currentPage < page + maxPages) {
        final response = await dio.get(
          '${ApiConstants.songkickApiBase}/events.json',
          queryParameters: {
            'apikey': apiKey,
            'location': 'geo:$latitude,$longitude',
            'page': currentPage,
            'per_page': perPage,
          },
        );
        VibraLogger.api(
          'GET',
          'Songkick events (page $currentPage)',
          statusCode: response.statusCode,
        );

        final data = response.data as Map<String, dynamic>;
        final resultsPage = data['resultsPage'] as Map<String, dynamic>?;
        final results = resultsPage?['results'] as Map<String, dynamic>?;
        final pageEvents = results?['event'] as List<dynamic>? ?? const [];
        totalEntries = (resultsPage?['totalEntries'] as num?)?.toInt() ?? 0;
        events.addAll(pageEvents);

        if (pageEvents.length < perPage || events.length >= totalEntries) {
          break;
        }
        currentPage++;
      }

      return {
        'resultsPage': {
          'results': {'event': events},
          'totalEntries': totalEntries,
          'perPage': perPage,
          'page': page,
          'status': 'ok',
        },
      };
    } on DioException catch (e) {
      VibraLogger.error('Errore Songkick searchEvents', error: e);
      throw ServerException(
        message: 'Errore nella ricerca eventi Songkick',
        statusCode: e.response?.statusCode,
        endpoint: 'songkick/events',
      );
    }
  }
}
