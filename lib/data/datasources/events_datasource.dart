import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';

/// Datasource astratto per la ricerca eventi.
/// Le implementazioni concrete interrogano Ticketmaster, Songkick e Bandsintown.
abstract class EventsDatasource {
  /// Cerca eventi per posizione geografica.
  Future<List<Map<String, dynamic>>> searchByLocation({
    required double latitude,
    required double longitude,
    required int radiusKm,
    int page,
    int pageSize,
  });

  /// Cerca eventi per nome artista.
  Future<List<Map<String, dynamic>>> searchByArtist({
    required String artistName,
    String? spotifyArtistId,
  });

  /// Recupera i dettagli di un singolo evento.
  Future<Map<String, dynamic>> getEventDetails(String externalId);
}

/// Implementazione del datasource eventi usando l'API Ticketmaster Discovery.
/// Fonte principale per la ricerca di concerti ed eventi musicali.
class TicketmasterDatasource implements EventsDatasource {
  final Dio _dio;
  final String _apiKey;

  TicketmasterDatasource({
    required Dio dio,
    required String apiKey,
  })  : _dio = dio, // ignore: prefer_initializing_formals
        _apiKey = apiKey; // ignore: prefer_initializing_formals

  @override
  Future<List<Map<String, dynamic>>> searchByLocation({
    required double latitude,
    required double longitude,
    required int radiusKm,
    int page = 0,
    int pageSize = 200,
  }) async {
    final List<Map<String, dynamic>> allEvents = [];
    int currentPage = page;
    int totalPages = 1;

    try {
      while (currentPage < totalPages && currentPage < 5) {
        final response = await _dio.get(
          '${ApiConstants.ticketmasterApiBase}${ApiConstants.ticketmasterEvents}',
          queryParameters: {
            'apikey': _apiKey,
            'latlong': '$latitude,$longitude',
            'radius': radiusKm,
            'unit': 'km',
            'locale': '*',
            'segmentId': 'KZFzniwnSyZfZ7v7nJ', // Music segment
            'sort': 'date,asc',
            'page': currentPage,
            'size': pageSize,
          },
        );

        VibraLogger.api('GET', 'Ticketmaster events by location (page $currentPage)',
            statusCode: response.statusCode);

        final data = response.data as Map<String, dynamic>?;
        if (data == null) break;

        final pageInfo = data['page'] as Map<String, dynamic>?;
        if (pageInfo != null) {
          totalPages = (pageInfo['totalPages'] as num?)?.toInt() ?? 1;
        }

        final embedded = data['_embedded'] as Map<String, dynamic>?;
        if (embedded != null) {
          final events = embedded['events'] as List?;
          if (events != null) {
            allEvents.addAll(List<Map<String, dynamic>>.from(events));
          }
        }

        currentPage++;
      }

      return allEvents;
    } on DioException catch (e) {
      VibraLogger.error('Errore Ticketmaster searchByLocation', error: e);
      throw ServerException(
        message: 'Errore nella ricerca eventi Ticketmaster',
        statusCode: e.response?.statusCode,
        endpoint: 'ticketmaster/events',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchByArtist({
    required String artistName,
    String? spotifyArtistId,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.ticketmasterApiBase}${ApiConstants.ticketmasterEvents}',
        queryParameters: {
          'apikey': _apiKey,
          'keyword': artistName,
          'locale': '*',
          'segmentId': 'KZFzniwnSyZfZ7v7nJ', // Music segment
          'sort': 'date,asc',
          'size': 200,
        },
      );

      VibraLogger.api('GET', 'Ticketmaster events by artist',
          statusCode: response.statusCode);

      final embedded = response.data['_embedded'] as Map<String, dynamic>?;
      if (embedded == null) return [];

      return List<Map<String, dynamic>>.from(
        embedded['events'] as List? ?? [],
      );
    } on DioException catch (e) {
      VibraLogger.error('Errore Ticketmaster searchByArtist', error: e);
      throw ServerException(
        message: 'Errore nella ricerca eventi per artista',
        statusCode: e.response?.statusCode,
        endpoint: 'ticketmaster/events',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getEventDetails(String externalId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.ticketmasterApiBase}/events/$externalId.json',
        queryParameters: {'apikey': _apiKey, 'locale': '*'},
      );

      VibraLogger.api('GET', 'Ticketmaster event detail: $externalId',
          statusCode: response.statusCode);

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      VibraLogger.error('Errore Ticketmaster getEventDetails', error: e);
      throw ServerException(
        message: 'Errore nel recupero dettagli evento',
        statusCode: e.response?.statusCode,
        endpoint: 'ticketmaster/events/$externalId',
      );
    }
  }
}
