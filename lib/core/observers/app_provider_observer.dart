import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';

/// Observer globale per Riverpod.
/// Utile in produzione per fare logging di state mutations, memory leaks, o eccezioni non gestite.
class AppProviderObserver extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    VibraLogger.debug('Provider aggiunto: ${provider.name ?? provider.runtimeType}', tag: 'Riverpod');
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    VibraLogger.debug('Provider smaltito: ${provider.name ?? provider.runtimeType}', tag: 'Riverpod');
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // Evita di loggare stream di posizione o timer se troppo rumorosi.
    if (provider.name == 'locationProvider') return;
    
    VibraLogger.debug(
      'Provider aggiornato: ${provider.name ?? provider.runtimeType}',
      tag: 'Riverpod',
    );
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    VibraLogger.error(
      'Eccezione sollevata dal Provider: ${provider.name ?? provider.runtimeType}',
      error: error,
      stackTrace: stackTrace,
      tag: 'Riverpod',
    );
    // In produzione: FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}
