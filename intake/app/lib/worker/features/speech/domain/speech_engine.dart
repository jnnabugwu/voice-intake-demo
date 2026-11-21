import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intake/shared/core/failure.dart';

part 'speech_engine.freezed.dart';

/// The seam for production speech: Chrome's Web Speech today, a BAA-covered
/// cloud engine or on-device recognition later. Only `data/` and
/// `bootstrap.dart` change when the engine does.
abstract interface class SpeechEngine {
  /// One listening session. The stream ends with exactly one terminal value,
  /// [SpeechCompleted] or [SpeechFailed], and never with an error.
  Stream<SpeechResult> listen({required String localeId});

  /// Ends the session; the stream then completes with what was heard.
  Future<void> stop();
}

@freezed
sealed class SpeechResult with _$SpeechResult {
  /// Words so far. Replaces the previous partial; it doesn't append to it.
  const factory SpeechResult.partial(String text) = SpeechPartial;

  /// The final text of the session. May be empty when nothing was heard.
  const factory SpeechResult.completed(String text) = SpeechCompleted;

  const factory SpeechResult.failed(Failure failure) = SpeechFailed;
}
