import 'dart:convert';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intake/internal/features/bench/domain/bench.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/core/result.dart';
import 'package:intake/shared/features/speech/domain/speech_engine.dart';

part 'bench_bloc.freezed.dart';

/// One class, no exclusive phases: the line, the live read, and every take so far.
@freezed
abstract class BenchState with _$BenchState {
  const factory BenchState({
    BenchScript? script,
    @Default(0) int speakerIndex,

    /// 0-based, clamped to the script.
    @Default(0) int index,
    @Default(false) bool listening,
    @Default('') String partial,
    @Default(<int, BenchTake>{}) Map<int, BenchTake> takes,
    String? error,
  }) = _BenchState;

  const BenchState._();

  BenchSpeaker? get speaker => script?.speakers[speakerIndex];
  BenchLine? get line => script?.lines[index];
  String? get lineText => switch ((line, speaker?.language)) {
    (final BenchLine l, Language.es) => l.es,
    (final BenchLine l, _) => l.en,
    _ => null,
  };
}

sealed class BenchEvent {
  const BenchEvent();
}

final class BenchOpened extends BenchEvent {
  const BenchOpened();
}

final class BenchSpeakerChanged extends BenchEvent {
  const BenchSpeakerChanged(this.index);
  final int index;
}

final class BenchLineMoved extends BenchEvent {
  const BenchLineMoved(this.by);
  final int by;
}

final class BenchReadStarted extends BenchEvent {
  const BenchReadStarted();
}

final class BenchReadStopped extends BenchEvent {
  const BenchReadStopped();
}

final class BenchExportRequested extends BenchEvent {
  const BenchExportRequested();
}

/// The live Chrome bench: show line n, record what the engine heard and when
/// (mic on, first partial, final), export the session as JSON for `npm run bench`.
class BenchBloc extends Bloc<BenchEvent, BenchState> {
  BenchBloc(this._engine, this._scripts, this._exporter, {required this.startLine, int Function()? nowMs})
    : _nowMs = nowMs ?? Stopwatch().elapsedMillisecondsStarted,
      super(const BenchState()) {
    on<BenchOpened>(_onOpened);
    on<BenchSpeakerChanged>(_onSpeakerChanged);
    on<BenchLineMoved>(_onLineMoved);
    on<BenchReadStarted>(_onReadStarted, transformer: droppable());
    on<BenchReadStopped>((_, _) => _engine.stop());
    on<BenchExportRequested>(_onExport, transformer: droppable());
  }

  final SpeechEngine _engine;
  final BenchScriptRepository _scripts;
  final BenchExporter _exporter;

  /// 1-based line to open on, from `/bench?line=`.
  final int startLine;
  final int Function() _nowMs;

  Future<void> _onOpened(BenchOpened event, Emitter<BenchState> emit) async {
    switch (await _scripts.load()) {
      case Ok(:final value):
        emit(state.copyWith(script: value, index: (startLine - 1).clamp(0, value.lines.length - 1)));
      case Err(:final failure):
        emit(state.copyWith(error: 'Could not load the bench script ($failure).'));
    }
  }

  void _onSpeakerChanged(BenchSpeakerChanged event, Emitter<BenchState> emit) {
    if (state.listening || event.index == state.speakerIndex) return;
    // Takes belong to one speaker; switching starts a new session.
    emit(state.copyWith(speakerIndex: event.index, takes: const {}, partial: ''));
  }

  void _onLineMoved(BenchLineMoved event, Emitter<BenchState> emit) {
    final lines = state.script?.lines.length ?? 0;
    if (state.listening || lines == 0) return;
    emit(state.copyWith(index: (state.index + event.by).clamp(0, lines - 1), partial: ''));
  }

  Future<void> _onReadStarted(BenchReadStarted event, Emitter<BenchState> emit) async {
    final speaker = state.speaker;
    final line = state.line;
    if (speaker == null || line == null) return;
    final micOn = _nowMs();
    int? firstPartial;
    emit(state.copyWith(listening: true, partial: ''));
    await emit.forEach<SpeechResult>(
      _engine.listen(localeId: speaker.locale),
      onData: (r) {
        switch (r) {
          case SpeechPartial(:final text):
            firstPartial ??= _nowMs();
            return state.copyWith(partial: text, error: null);
          case SpeechCompleted(:final text):
            final take = BenchTake(
              n: line.n,
              transcript: text.isEmpty ? state.partial : text,
              micOnMs: micOn,
              firstPartialMs: firstPartial,
              finalMs: _nowMs(),
            );
            return state.copyWith(listening: false, partial: '', takes: {...state.takes, line.n: take});
          case SpeechFailed(:final failure):
            return state.copyWith(listening: false, error: 'The mic stopped ($failure).');
        }
      },
    );
    if (state.listening) emit(state.copyWith(listening: false));
  }

  Future<void> _onExport(BenchExportRequested event, Emitter<BenchState> emit) async {
    final speaker = state.speaker;
    if (speaker == null || state.takes.isEmpty) return;
    final date = DateTime.now().toUtc().toIso8601String();
    await _exporter.save(
      'chrome_${speaker.id}_${date.substring(0, 10)}.json',
      exportJson(speaker, _exporter.browser, date),
    );
  }

  /// The format `bench/lib/chrome.ts` reads.
  String exportJson(BenchSpeaker speaker, String browser, String date) => const JsonEncoder.withIndent('  ').convert({
    'engine': 'chrome-web-speech',
    'speaker': speaker.id,
    'locale': speaker.locale,
    'browser': browser,
    'date': date,
    'lines': [
      for (final t in state.takes.values.toList()..sort((a, b) => a.n.compareTo(b.n)))
        {
          'n': t.n,
          'transcript': t.transcript,
          'micOnMs': t.micOnMs,
          'firstPartialMs': t.firstPartialMs,
          'finalMs': t.finalMs,
        },
    ],
  });

  @override
  Future<void> close() async {
    await _engine.stop();
    return super.close();
  }
}

extension on Stopwatch {
  int Function() get elapsedMillisecondsStarted {
    start();
    return () => elapsedMilliseconds;
  }
}
