import 'package:connectivity_plus/connectivity_plus.dart';

/// Verifica la connettività di rete del dispositivo.
abstract class NetworkInfo {
  /// Restituisce true se il dispositivo è connesso a internet.
  Future<bool> get isConnected;
}

/// Implementazione di [NetworkInfo] usando il plugin connectivity_plus.
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  const NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    // ConnectivityResult.none indica assenza di connessione
    return !result.contains(ConnectivityResult.none);
  }
}
