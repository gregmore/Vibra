import 'dart:async';

import 'exceptions.dart';

/// True when [error] means the device could not reach the network (no
/// connection, DNS failure, timeout), as opposed to a server or data error.
///
/// Used by `VibraErrorView` to show the offline state instead of a generic
/// failure (docs/ui-architecture.md). No connectivity plugin is needed: the
/// failed request itself tells us, on every platform. Supabase wraps
/// transport failures (`AuthRetryableFetchException`, `ClientException`,
/// `SocketException`), so the type name and message are checked too; dart:io
/// is not imported, so this also works on the web.
bool isOfflineError(Object? error) {
  if (error == null) return false;
  if (error is NetworkException || error is TimeoutException) return true;
  final type = error.runtimeType.toString();
  if (const {
    'SocketException',
    'ClientException',
    'HandshakeException',
    'HttpException',
    'AuthRetryableFetchException',
  }.contains(type)) {
    return true;
  }
  final text = error.toString().toLowerCase();
  return const [
    'socketexception',
    'clientexception',
    'failed host lookup',
    'network is unreachable',
    'connection refused',
    'connection reset',
    'connection closed',
    'connection failed',
    'xmlhttprequest error',
    'failed to fetch',
  ].any(text.contains);
}
