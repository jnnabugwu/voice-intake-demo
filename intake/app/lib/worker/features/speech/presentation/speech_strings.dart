import 'package:intake/shared/core/failure.dart';
import 'package:intake/shared/core/language.dart';

/// The speech feature's words, in the conversation's language.
class SpeechStrings {
  const SpeechStrings._(this._es);

  factory SpeechStrings.of(Language language) => SpeechStrings._(language == Language.es);

  final bool _es;

  String get startListening => _es ? 'Empezar a escuchar' : 'Start listening';
  String get stopListening => _es ? 'Escuchando, toque para detener' : 'Listening, tap to stop';
  String get starting => _es ? 'Abriendo el micrófono…' : 'Opening the microphone…';
  String get tapToSpeak => _es ? 'Toque el micrófono y hable' : 'Tap the mic and speak';
  String get listening => _es ? 'Escuchando…' : 'Listening…';
  String get languageLabel => _es ? 'Idioma' : 'Language';
  String get typeInstead => _es ? 'Escriba su mensaje' : 'Type your message';
  String get send => _es ? 'Enviar' : 'Send';
  String get bestInChrome => _es ? 'Funciona mejor en Chrome en una computadora.' : 'Works best in Chrome on a laptop.';

  String unavailableTitle(Failure failure) => switch (failure) {
    MicPermissionFailure() => _es ? 'No hay acceso al micrófono' : 'No access to the microphone',
    SpeechUnavailableFailure() =>
      _es ? 'Este navegador no reconoce la voz' : "This browser doesn't support speech recognition",
    NetworkFailure() => _es ? 'El reconocimiento de voz necesita conexión' : 'Speech recognition needs a connection',
    _ => _es ? 'El micrófono se detuvo' : 'The microphone stopped',
  };

  String unavailableBody(Failure failure) => switch (failure) {
    MicPermissionFailure() =>
      _es
          ? 'Permita el micrófono en la barra de direcciones y toque el micrófono otra vez, o escriba abajo.'
          : 'Allow the microphone in the address bar and tap the mic again, or type below.',
    SpeechUnavailableFailure() =>
      _es
          ? 'Firefox, Brave y algunos navegadores dentro de apps no lo admiten. Abra el enlace en Chrome, o escriba abajo.'
          : "Firefox, Brave and some in-app browsers don't support it. Open the link in Chrome, or type below.",
    _ =>
      _es
          ? 'Toque el micrófono para intentarlo otra vez, o escriba abajo.'
          : 'Tap the mic to try again, or type below.',
  };
}
