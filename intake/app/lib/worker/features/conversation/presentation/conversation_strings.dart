import 'package:intake/shared/core/failure.dart';
import 'package:intake/shared/core/language.dart';

class ConversationStrings {
  const ConversationStrings._(this._es);

  factory ConversationStrings.of(Language language) => ConversationStrings._(language == Language.es);

  final bool _es;

  String get greeting =>
      _es ? 'Hola. Cuénteme qué le pasa, con sus propias palabras.' : "Hi. Tell me what's going on, in your own words.";
  String get connectClinician => _es ? 'Déjeme conectarlo con un médico.' : 'Let me connect you with a clinician.';
  String get finish => _es ? 'Terminar' : 'Finish';
  String get finished =>
      _es ? 'Listo. Un médico está revisando su información.' : 'Done. A clinician is reviewing what you shared.';
  String get you => _es ? 'Usted' : 'You';
  String get assistant => _es ? 'Asistente' : 'Assistant';
  String get retry => _es ? 'Reintentar' : 'Retry';
  String get spendCapTitle => _es ? 'La demo en vivo está en pausa por hoy' : 'The live demo is paused for today';
  String get spendCapBody => _es
      ? 'Llegó a su límite diario. Vuelva mañana, por favor.'
      : 'It reached its daily limit. Please come back tomorrow.';

  /// For a toast; the worker can retry these.
  String failureToast(Failure failure) => switch (failure) {
    NetworkFailure() => _es ? 'No se pudo conectar. Revise su conexión.' : "Couldn't connect. Check your connection.",
    RateLimitedFailure() => _es ? 'Demasiados mensajes. Espere un momento.' : 'Too many messages. Wait a moment.',
    _ => _es ? 'Algo salió mal con la respuesta.' : 'Something went wrong with the reply.',
  };
}
