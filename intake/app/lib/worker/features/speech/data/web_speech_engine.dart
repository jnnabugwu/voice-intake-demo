import 'dart:async';

import 'package:intake/shared/core/failure.dart';
import 'package:intake/worker/features/speech/domain/speech_engine.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// [SpeechEngine] over `speech_to_text`, which on web is Chrome's Web Speech
/// API. Chrome's default recognition sends audio to Google, so this engine is
/// for demo data only.
class WebSpeechEngine implements SpeechEngine {
  WebSpeechEngine([SpeechToText? speech]) : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;
  void Function(SpeechResult)? _finishActive;

  /// How long to wait after the recognizer says "done" for its final result.
  static const _finalGrace = Duration(milliseconds: 400);

  @override
  Stream<SpeechResult> listen({required String localeId}) {
    final controller = StreamController<SpeechResult>();
    var heard = '';

    void finish(SpeechResult result) {
      if (controller.isClosed) return;
      controller.add(result);
      unawaited(controller.close());
      if (identical(_finishActive, finish)) _finishActive = null;
    }

    // A new session ends any older one first.
    _finishActive?.call(SpeechResult.completed(heard));
    _finishActive = finish;

    controller.onListen = () async {
      try {
        _speech.errorListener = (error) => finish(_resultForError(error, heard));
        _speech.statusListener = (status) {
          if (status == SpeechToText.doneStatus || status == 'doneNoResult') {
            Timer(_finalGrace, () => finish(SpeechResult.completed(heard)));
          }
        };
        final available = await _speech.initialize(onError: _speech.errorListener, onStatus: _speech.statusListener);
        if (!available) return finish(const SpeechResult.failed(SpeechUnavailableFailure()));
        if (controller.isClosed) return;

        await _speech.listen(
          onResult: (SpeechRecognitionResult result) {
            heard = result.recognizedWords;
            if (result.finalResult) {
              finish(SpeechResult.completed(heard));
            } else if (!controller.isClosed) {
              controller.add(SpeechResult.partial(heard));
            }
          },
          listenOptions: SpeechListenOptions(
            localeId: await _resolveLocale(localeId),
            partialResults: true,
            cancelOnError: true,
          ),
        );
      } catch (error) {
        finish(SpeechResult.failed(UnknownFailure('$error')));
      }
    };
    controller.onCancel = () async {
      // The listener went away mid-session (the screen closed).
      if (!controller.isClosed) await _speech.cancel();
    };
    return controller.stream;
  }

  @override
  Future<void> stop() async {
    try {
      await _speech.stop();
    } catch (_) {
      // Stopping is best effort; the session still ends through the status or timeout.
    }
  }

  /// The requested locale if offered, else another locale of the same
  /// language, else the request as is (Chrome accepts any BCP 47 tag but
  /// lists only its current one).
  Future<String> _resolveLocale(String requested) async {
    try {
      final offered = (await _speech.locales()).map((l) => l.localeId.replaceAll('_', '-')).toList();
      if (offered.contains(requested)) return requested;
      final language = requested.split('-').first;
      return offered.firstWhere((l) => l.split('-').first == language, orElse: () => requested);
    } catch (_) {
      return requested;
    }
  }

  /// Chrome's `SpeechRecognitionErrorEvent.error` codes, plus the plugin's own.
  static SpeechResult _resultForError(SpeechRecognitionError error, String heard) {
    return switch (error.errorMsg) {
      'no-speech' || 'aborted' || 'error_no_match' || 'error_speech_timeout' => SpeechResult.completed(heard),
      'not-allowed' ||
      'audio-capture' ||
      'error_permission' ||
      'error_audio_error' => const SpeechResult.failed(MicPermissionFailure()),
      'network' || 'error_network' || 'error_network_timeout' => const SpeechResult.failed(NetworkFailure()),
      'service-not-allowed' ||
      'language-not-supported' ||
      'not supported' ||
      'speech_not_supported' => const SpeechResult.failed(SpeechUnavailableFailure()),
      final code => SpeechResult.failed(UnknownFailure(code)),
    };
  }
}
