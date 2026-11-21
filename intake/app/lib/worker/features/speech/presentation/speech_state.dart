import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intake/shared/core/failure.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/worker/features/speech/domain/utterance.dart';

part 'speech_state.freezed.dart';

/// The language and the last utterance survive every phase, so they sit
/// beside the sealed [phase].
@freezed
abstract class SpeechState with _$SpeechState {
  const factory SpeechState({
    @Default(Language.en) Language language,

    /// The last finished utterance. `WorkerScreen` hands each new one to the
    /// conversation once (by ID).
    Utterance? lastUtterance,
    @Default(SpeechPhase.idle()) SpeechPhase phase,
  }) = _SpeechState;
}

@freezed
sealed class SpeechPhase with _$SpeechPhase {
  const factory SpeechPhase.idle() = SpeechIdle;
  const factory SpeechPhase.starting() = SpeechStarting;
  const factory SpeechPhase.listening({required String partial}) = SpeechListening;
  const factory SpeechPhase.unavailable({required Failure failure}) = SpeechUnavailable;
}
