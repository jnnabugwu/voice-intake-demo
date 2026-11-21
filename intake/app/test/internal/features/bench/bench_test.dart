import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:intake/internal/features/bench/domain/bench.dart';
import 'package:intake/internal/features/bench/presentation/bench_bloc.dart';
import 'package:intake/shared/features/speech/domain/speech_engine.dart';

import '../../../helpers/fake_speech_engine.dart';
import '../../../helpers/file_bench_script.dart';

class _CapturingExporter implements BenchExporter {
  String? filename;
  String? json;

  @override
  String get browser => 'TestChrome/1.0';

  @override
  Future<void> save(String filename, String json) async {
    this.filename = filename;
    this.json = json;
  }
}

void main() {
  test("the app's copy of the bench script matches bench/references.json (run tool/sync_bench_script.sh)", () {
    expect(
      File('assets/bench/references.json').readAsStringSync(),
      File('../../bench/references.json').readAsStringSync(),
    );
  });

  test('a read records mic on, first partial and final, then exports the format npm run bench reads', () async {
    var clock = 1000;
    final engine = FakeSpeechEngine();
    final exporter = _CapturingExporter();
    final bloc = BenchBloc(engine, FileBenchScriptRepository(), exporter, startLine: 9, nowMs: () => clock)
      ..add(const BenchOpened());
    await pumpEventQueue();
    expect(bloc.state.line!.n, 9);
    expect(bloc.state.lineText, contains('lisinopril'));

    bloc.add(const BenchReadStarted());
    await pumpEventQueue();
    expect(engine.requestedLocales, ['en-US']);
    clock = 1400;
    engine.emit(const SpeechResult.partial('I take'));
    await pumpEventQueue();
    clock = 3200;
    await engine.end(const SpeechResult.completed('I take lisinopril ten milligrams'));
    await pumpEventQueue();

    expect(
      bloc.state.takes[9],
      const BenchTake(
        n: 9,
        transcript: 'I take lisinopril ten milligrams',
        micOnMs: 1000,
        firstPartialMs: 1400,
        finalMs: 3200,
      ),
    );

    bloc.add(const BenchExportRequested());
    await pumpEventQueue();
    final exported = jsonDecode(exporter.json!) as Map<String, dynamic>;
    expect(exporter.filename, startsWith('chrome_en_jn_'));
    expect(exported['engine'], 'chrome-web-speech');
    expect(exported['speaker'], 'en_jn');
    expect(exported['locale'], 'en-US');
    expect(exported['browser'], 'TestChrome/1.0');
    expect(exported['lines'], [
      {
        'n': 9,
        'transcript': 'I take lisinopril ten milligrams',
        'micOnMs': 1000,
        'firstPartialMs': 1400,
        'finalMs': 3200,
      },
    ]);
    await bloc.close();
  });

  test('lines clamp; a Spanish speaker reads the Spanish line with es-MX', () async {
    final engine = FakeSpeechEngine();
    final bloc = BenchBloc(engine, FileBenchScriptRepository(), _CapturingExporter(), startLine: 99)
      ..add(const BenchOpened());
    await pumpEventQueue();
    expect(bloc.state.line!.n, 21);
    bloc
      ..add(const BenchLineMoved(1))
      ..add(const BenchSpeakerChanged(2)); // es_mx
    await pumpEventQueue();
    expect(bloc.state.line!.n, 21);
    expect(bloc.state.lineText, startsWith('Hola, llamo por mi mamá'));
    bloc.add(const BenchReadStarted());
    await pumpEventQueue();
    expect(engine.requestedLocales, ['es-MX']);
    await engine.end(const SpeechResult.completed('hola'));
    await bloc.close();
  });
}
