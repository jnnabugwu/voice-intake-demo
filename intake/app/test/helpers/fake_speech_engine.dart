import 'dart:async';

import 'package:intake/worker/features/speech/domain/speech_engine.dart';

/// A [SpeechEngine] the test drives by hand.
class FakeSpeechEngine implements SpeechEngine {
  final requestedLocales = <String>[];
  StreamController<SpeechResult>? _session;
  int stopCalls = 0;

  /// What [stop] sends before closing; null closes without a terminal value.
  SpeechResult? Function()? onStop;

  @override
  Stream<SpeechResult> listen({required String localeId}) {
    requestedLocales.add(localeId);
    _session = StreamController<SpeechResult>();
    return _session!.stream;
  }

  void emit(SpeechResult result) => _session!.add(result);

  Future<void> end([SpeechResult? last]) async {
    if (last != null) _session!.add(last);
    await _session!.close();
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    final session = _session;
    if (session == null || session.isClosed) return;
    final last = onStop?.call();
    if (last != null) session.add(last);
    await session.close();
  }
}
