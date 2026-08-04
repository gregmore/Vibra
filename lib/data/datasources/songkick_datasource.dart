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

  /// Cerca eventi per posizione (Songkick richiede prima un metro area id).
  /// Qui esponiamo la chiamata grezza; il mapping finale lo fa l'aggregatore.
  Future<Map<String, dynamic>> searchEvents({
    required double latitude,
    required double longitude,
    int radiusKm = 50,
    int page = 1,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.songkickApiBase}/events.json',
        queryParameters: {
          'apikey': apiKey,
          'location': 'geo:$latitude,$longitude',
          'radius': radiusKm,
          'page': page,
        },
      );
      VibraLogger.api(
        'GET',
        'Songkick events',
        statusCode: response.statusCode,
      );
      return response.data as Map<String, dynamic>;
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
