import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/logger.dart';

class SupportService {
  SupportService(this._client);

  final SupabaseClient _client;

  Future<Map<String, dynamic>> diagnostics() async {
    final package = await PackageInfo.fromPlatform();
    final device = DeviceInfoPlugin();
    String osVersion = Platform.operatingSystemVersion;
    if (Platform.isAndroid) {
      final info = await device.androidInfo;
      osVersion = 'Android ${info.version.release}';
    } else if (Platform.isIOS) {
      final info = await device.iosInfo;
      osVersion = 'iOS ${info.systemVersion}';
    }
    return {
      'app_version': '${package.version}+${package.buildNumber}',
      'os_version': osVersion,
      'platform': Platform.operatingSystem,
      'last_failed_endpoint': VibraLogger.lastFailedEndpoint,
      // Gli eventi sono già ripuliti da token, password e identificativi UUID.
      'recent_logs': VibraLogger.supportLogs,
    };
  }

  Future<void> submit({
    required String description,
    Uint8List? screenshotBytes,
    String? screenshotExtension,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Devi accedere per inviare una segnalazione.');
    }

    String? screenshotPath;
    if (screenshotBytes != null) {
      final response = await _client.functions.invoke(
        'upload-image',
        queryParameters: {'bucket': 'support-attachments'},
        body: screenshotBytes,
        headers: {'Content-Type': 'application/octet-stream'},
      );
      if (response.status != 200 ||
          response.data is! Map ||
          response.data['path'] is! String) {
        throw StateError('Impossibile caricare lo screenshot.');
      }
      screenshotPath = response.data['path'] as String;
    }

    await _client.from('support_reports').insert({
      'user_id': user.id,
      'description': description.trim(),
      'screenshot_path': screenshotPath,
      'diagnostics': await diagnostics(),
    });
  }
}
