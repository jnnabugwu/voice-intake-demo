import 'dart:async';

import 'package:intake/shared/core/failure.dart';
import 'package:intake/worker/features/speech/domain/speech_engine.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// [SpeechEngine] over `speech_to_text`, which on web is Chrome's Web Speech
/// API. Chrome's default recognition sends audio to Google, so this engine is
/// for demo data only.
///
/// How a session ends, on web: the plugin reports only partial results. After
/// [stop], its own final timeout ([_finalTimeout]) promotes the last partial
/// to a final result, then reports `done`. When Chrome ends the session by
/// itself after partials, the plugin holds back `done`, so a fallback timer
/// after `notListening` ends the session with what was heard.
class WebSpeechEngine implements SpeechEngine {
  WebSpeechEngine([SpeechToText? speech]) : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;
  _Session? _active;

  /// The plugin's wait, after a stop, before it turns the last partial final.
  static const _finalTimeout = Duration(milliseconds: 700);

  /// How long to wait for a final result once the recognizer has stopped
  /// listening, before ending with what was heard. Longer than [_finalTimeout].
  static const fallback = Duration(milliseconds: 1500);

  @override
  Stream<SpeechResult> listen({required String localeId}) {
    final controller = StreamController<SpeechResult>();
    final session = _Session(controller);
    // A new session ends any older one first, with what that one heard, and
    // stops its recognizer so two browser sessions never race.
    final previous = _active;
    final previousLive = previous != null && !previous.ended;
    previous?.finish();
    _active = session;

    controller.onListen = () async {
      try {
        if (previousLive) await _speech.cancel();
        _speech.errorListener = (error) => session.finish(_resultForError(error, session.heard));
        _speech.statusListener = (status) {
          if (status == SpeechToText.doneStatus) {
            session.finish();
          } else if (status == SpeechToText.notListeningStatus) {
            session.armFallback(fallback);
          }
        };
        final available = await _speech.initialize(
          onError: _speech.errorListener,
          onStatus: _speech.statusListener,
          finalTimeout: _finalTimeout,
        );
        if (!available) return session.finish(const SpeechResult.failed(SpeechUnavailableFailure()));
        // Stopped, replaced or abandoned while the mic was starting: don't open it.
        if (session.ended || session.stopRequested || !controller.hasListener) return session.finish();

        await _speech.listen(
          onResult: (SpeechRecognitionResult result) {
            if (result.finalResult) {
              session.finish(SpeechResult.completed(result.recognizedWords));
            } else {
              session.partial(result.recognizedWords);
            }
          },
          listenOptions: SpeechListenOptions(
            localeId: await _resolveLocale(localeId),
            partialResults: true,
            cancelOnError: true,
          ),
        );
      } catch (error) {
        session.finish(SpeechResult.failed(UnknownFailure('$error')));
      }
    };
    controller.onCancel = () async {
      // The listener went away mid-session (the screen closed).
      if (session.ended) return;
      session.finish();
      await _speech.cancel();
    };
    return controller.stream;
  }

  @override
  Future<void> stop() async {
    final session = _active;
    session?.stopRequested = true;
    // If the plugin never reports back, the session still ends.
    session?.armFallback(_finalTimeout + fallback);
    try {
      await _speech.stop();
    } catch (_) {
      // Best effort; the fallback ends the session.
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

/// One listening session: its own transcript, its own end.
class _Session {
  _Session(this._controller);

  final StreamController<SpeechResult> _controller;
  String heard = '';
  bool stopRequested = false;
  Timer? _fallback;

  bool get ended => _controller.isClosed;

  void partial(String text) {
    if (ended) return;
    heard = text;
    _controller.add(SpeechResult.partial(text));
  }

  /// Ends the session once; later calls do nothing. Without [result], it ends
  /// with what was heard.
  void finish([SpeechResult? result]) {
    if (ended) return;
    _fallback?.cancel();
    _controller.add(result ?? SpeechResult.completed(heard));
    unawaited(_controller.close());
  }

  void armFallback(Duration after) {
    if (ended) return;
    _fallback?.cancel();
    _fallback = Timer(after, finish);
  }
}
