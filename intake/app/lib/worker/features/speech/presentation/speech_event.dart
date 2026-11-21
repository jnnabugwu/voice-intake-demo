import 'package:intake/shared/core/language.dart';

sealed class SpeechEvent {
  const SpeechEvent();
}

/// The worker tapped the mic to start. A second tap while it starts does nothing.
final class SpeechStarted extends SpeechEvent {
  const SpeechStarted();
}

/// The worker tapped the mic to stop. What was heard becomes the utterance.
final class SpeechStopped extends SpeechEvent {
  const SpeechStopped();
}

final class SpeechLanguageChanged extends SpeechEvent {
  const SpeechLanguageChanged(this.language);

  final Language language;
}
