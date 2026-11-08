import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/logger.dart';

enum SupportFailure {
  authentication,
  descriptionTooShort,
  descriptionTooLong,
  screenshotTooLarge,
  screenshotUnsupported,
  rateLimited,
  unavailable,
}

class SupportSubmissionException implements Exception {
  const SupportSubmissionException(this.failure);
  final SupportFailure failure;
}

class SupportService {
  SupportService(this._client);

  static const minDescriptionLength = 8;
  static const maxDescriptionLength = 4000;
  static const maxScreenshotBytes = 5 * 1024 * 1024;
  static const _diagnosticsBudget = 24 * 1024;
  static const _metadataTimeout = Duration(seconds: 3);
  final SupabaseClient _client;
  bool _submitting = false;
  Uint8List? _uploadedScreenshot;
  String? _uploadedScreenshotPath;
  String? _uploadedScreenshotUser;

  String? get currentUserId => _client.auth.currentUser?.id;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Optional native metadata must never prevent delivery of the report.
  Future<Map<String, dynamic>> diagnostics() async {
    var appVersion = 'unavailable';
    var osVersion = Platform.operatingSystemVersion;
    try {
      final package = await PackageInfo.fromPlatform().timeout(
        _metadataTimeout,
      );
      appVersion = '${package.version}+${package.buildNumber}';
    } catch (_) {
      VibraLogger.warning('Support app metadata unavailable', tag: 'Support');
    }
    try {
      final device = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final info = await device.androidInfo.timeout(_metadataTimeout);
        osVersion = 'Android ${info.version.release}';
      } else if (Platform.isIOS) {
        final info = await device.iosInfo.timeout(_metadataTimeout);
        osVersion = 'iOS ${info.systemVersion}';
      }
    } catch (_) {
      VibraLogger.warning(
        'Support device metadata unavailable',
        tag: 'Support',
      );
    }
    return boundedDiagnostics({
      'app_version': appVersion,
      'os_version': osVersion,
      'platform': Platform.operatingSystem,
      'last_failed_endpoint': VibraLogger.lastFailedEndpoint,
      'recent_logs': VibraLogger.supportLogs,
    });
  }

  /// PostgreSQL limits diagnostics to 32 KiB, including JSON escaping. Keep a
  /// margin for jsonb formatting and bound each log, even with Unicode text.
  static Map<String, dynamic> boundedDiagnostics(Map<String, dynamic> data) {
    String bounded(Object? value) =>
        String.fromCharCodes(VibraLogger.redact('$value').runes.take(512));
    final logs = <Map<String, String>>[];
    final sourceLogs = data['recent_logs'];
    if (sourceLogs is List) {
      for (final entry in sourceLogs.reversed.take(30).toList().reversed) {
        if (entry is! Map) continue;
        logs.add({
          for (final key in ['timestamp', 'level', 'message'])
            if (entry[key] != null) key: bounded(entry[key]),
        });
      }
    }
    final result = <String, dynamic>{
      for (final key in ['app_version', 'os_version', 'platform'])
        if (data[key] != null) key: bounded(data[key]),
      'last_failed_endpoint': data['last_failed_endpoint'] == null
          ? null
          : bounded(data['last_failed_endpoint']),
      'recent_logs': logs,
    };
    while (logs.isNotEmpty &&
        utf8.encode(jsonEncode(result)).length > _diagnosticsBudget) {
      logs.removeAt(0);
    }
    return result;
  }

  static void validateDescription(String description) {
    // PostgreSQL char_length counts Unicode scalars, rather than UTF-16 units.
    final length = description.trim().runes.length;
    if (length < minDescriptionLength) {
      throw const SupportSubmissionException(
        SupportFailure.descriptionTooShort,
      );
    }
    if (length > maxDescriptionLength) {
      throw const SupportSubmissionException(SupportFailure.descriptionTooLong);
    }
  }

  static void validateScreenshot(Uint8List bytes) {
    if (bytes.length > maxScreenshotBytes) {
      throw const SupportSubmissionException(SupportFailure.screenshotTooLarge);
    }
    final jpeg =
        bytes.length >= 3 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[2] == 0xff;
    const pngHeader = [137, 80, 78, 71, 13, 10, 26, 10];
    final png =
        bytes.length >= pngHeader.length &&
        List.generate(
          pngHeader.length,
          (i) => bytes[i] == pngHeader[i],
        ).every((matches) => matches);
    if (!jpeg && !png) {
      throw const SupportSubmissionException(
        SupportFailure.screenshotUnsupported,
      );
    }
  }

  Future<void> submit({
    required String description,
    Uint8List? screenshotBytes,
    String? screenshotExtension,
  }) async {
    validateDescription(description);
    if (screenshotBytes != null) validateScreenshot(screenshotBytes);
    final user = _client.auth.currentUser;
    if (user == null || _client.auth.currentSession == null) {
      throw const SupportSubmissionException(SupportFailure.authentication);
    }
    if (_submitting) {
      throw const SupportSubmissionException(SupportFailure.unavailable);
    }
    _submitting = true;
    var sessionChanged = false;
    final subscription = _client.auth.onAuthStateChange.listen((state) {
      if (state.event == AuthChangeEvent.signedOut ||
          state.event == AuthChangeEvent.signedIn ||
          state.session?.user.id != user.id) {
        sessionChanged = true;
      }
    }, onError: (Object _, StackTrace _) {});
    String requireSession() {
      final session = _client.auth.currentSession;
      if (sessionChanged || session == null || session.user.id != user.id) {
        throw const SupportSubmissionException(SupportFailure.authentication);
      }
      return session.accessToken;
    }

    try {
      Map<String, dynamic> data;
      try {
        data = boundedDiagnostics(
          await diagnostics().timeout(const Duration(seconds: 7)),
        );
      } catch (_) {
        // Sending the user's description is still useful without plugins/logs.
        data = {
          'platform': Platform.operatingSystem,
          'recent_logs': <Object>[],
        };
        VibraLogger.warning('Support diagnostics unavailable', tag: 'Support');
      }
      requireSession();
      String? screenshotPath;
      if (screenshotBytes != null) {
        if (identical(screenshotBytes, _uploadedScreenshot) &&
            _uploadedScreenshotUser == user.id) {
          screenshotPath = _uploadedScreenshotPath;
        } else {
          final response = await _client.functions.invoke(
            'upload-image',
            queryParameters: {'bucket': 'support-attachments'},
            body: screenshotBytes,
            headers: {
              'Content-Type': 'application/octet-stream',
              'Authorization': 'Bearer ${requireSession()}',
            },
          );
          requireSession();
          final path = response.data is Map ? response.data['path'] : null;
          if (response.status != 200 ||
              path is! String ||
              !path.startsWith('${user.id}/') ||
              path.contains('..') ||
              path.split('/').length != 2 ||
              !path.endsWith('.png')) {
            throw const SupportSubmissionException(SupportFailure.unavailable);
          }
          screenshotPath = path;
          _uploadedScreenshot = screenshotBytes;
          _uploadedScreenshotPath = path;
          _uploadedScreenshotUser = user.id;
        }
      }
      // Support reports are unreadable under RLS: never request a returned row.
      // Pin the header so a later account switch cannot change the sender.
      await _client
          .from('support_reports')
          .insert({
            'user_id': user.id,
            'description': description.trim(),
            'screenshot_path': screenshotPath,
            'diagnostics': data,
          })
          .setHeader('Authorization', 'Bearer ${requireSession()}');
      requireSession();
      _uploadedScreenshot = null;
      _uploadedScreenshotPath = null;
      _uploadedScreenshotUser = null;
    } on SupportSubmissionException {
      rethrow;
    } catch (error) {
      requireSession();
      VibraLogger.endpointFailure('support_reports');
      final code = error is PostgrestException ? error.code : null;
      final status = error is FunctionException ? error.status : null;
      // Do not log report text, screenshots, server bodies or account IDs.
      VibraLogger.warning(
        'Support submission failed (${code ?? status ?? error.runtimeType})',
        tag: 'Support',
      );
      final failure = switch (code) {
        'PT429' => SupportFailure.rateLimited,
        'PT401' || 'PGRST301' || 'PGRST302' => SupportFailure.authentication,
        _ => switch (status) {
          401 || 403 => SupportFailure.authentication,
          413 => SupportFailure.screenshotTooLarge,
          415 => SupportFailure.screenshotUnsupported,
          429 => SupportFailure.rateLimited,
          _ => SupportFailure.unavailable,
        },
      };
      throw SupportSubmissionException(failure);
    } finally {
      await subscription.cancel();
      _submitting = false;
      if (sessionChanged) {
        _uploadedScreenshot = null;
        _uploadedScreenshotPath = null;
        _uploadedScreenshotUser = null;
      }
    }
  }
}
