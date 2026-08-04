import '../../entities/event.dart';
import '../../repositories/events_repository.dart';

class LogEventInteractionUseCase {
  final EventsRepository repository;

  LogEventInteractionUseCase(this.repository);

  Future<void> execute({
    required Event event,
    required String interactionType,
    double? scoreAtTime,
    Map<String, dynamic>? metadata,
  }) {
    return repository.logInteraction(
      event: event,
      interactionType: interactionType,
      scoreAtTime: scoreAtTime,
      metadata: metadata,
    );
  }
}
