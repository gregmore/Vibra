import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';

/// Datasource Bandsintown.
/// Richiede un `app_id` in query string.
class BandsintownDatasource {
  BandsintownDatasource({required this.dio, required this.appId});

  final Dio dio;
  final String appId;

  Future<List<dynamic>> getArtistEvents({required String artistName}) async {
    try {
      final response = await dio.get(
        '${ApiConstants.bandsintownApiBase}${ApiConstants.bandsintownArtistEvents(Uri.encodeComponent(artistName))}',
        queryParameters: {'app_id': appId, 'date': 'upcoming'},
      );
      VibraLogger.api(
        'GET',
        'Bandsintown artist events',
        statusCode: response.statusCode,
      );
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      VibraLogger.error('Errore Bandsintown getArtistEvents', error: e);
      throw ServerException(
        message: 'Errore nel recupero eventi Bandsintown',
        statusCode: e.response?.statusCode,
        endpoint: 'bandsintown/artist-events',
      );
    }
  }
}
