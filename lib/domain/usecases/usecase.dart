/// Contratto base opzionale per i use case.
abstract class UseCase<T, Params> {
  Future<T> call(Params params);
}

/// Segnaposto per use case senza parametri.
class NoParams {
  const NoParams();
}

