import 'dart:async';

/// Keeps token acquisition retryable while APNs or the network is warming up.
class PushTokenRegistration {
  PushTokenRegistration({
    required this.readToken,
    required this.persistToken,
    required this.isActive,
    required this.onError,
    this.retryDelay = const Duration(seconds: 3),
    this.maxAttempts = 20,
  });

  final Future<String?> Function() readToken;
  final Future<void> Function(String) persistToken;
  final bool Function() isActive;
  final void Function(Object, StackTrace) onError;
  final Duration retryDelay;
  final int maxAttempts;
  Timer? _retry;
  Future<void>? _pending;
  bool _disposed = false;
  int _attempts = 0;

  Future<void> synchronize() {
    if (_disposed) return Future.value();
    _retry?.cancel();
    _attempts = 0;
    return _run();
  }

  Future<void> _run() {
    if (_disposed || !isActive()) return Future.value();
    return _pending ??= _register().whenComplete(() => _pending = null);
  }

  Future<void> _register() async {
    _attempts++;
    try {
      final token = await readToken();
      if (_disposed || !isActive()) return;
      if (token != null && token.isNotEmpty) {
        await persistToken(token);
        return;
      }
    } catch (error, stackTrace) {
      if (!_disposed) onError(error, stackTrace);
    }
    if (!_disposed && isActive() && _attempts < maxAttempts) {
      _retry = Timer(retryDelay, _run);
    }
  }

  void dispose() {
    _disposed = true;
    _retry?.cancel();
  }
}
