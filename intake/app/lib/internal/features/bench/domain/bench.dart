import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/core/result.dart';

part 'bench.freezed.dart';

/// A speaker from the bench script (`en_jn`, `es_cu`, `es_mx`).
@freezed
abstract class BenchSpeaker with _$BenchSpeaker {
  const factory BenchSpeaker({required String id, required String locale, required Language language}) = _BenchSpeaker;
}

@freezed
abstract class BenchLine with _$BenchLine {
  const factory BenchLine({required int n, required String en, required String es}) = _BenchLine;
}

@freezed
abstract class BenchScript with _$BenchScript {
  const factory BenchScript({required List<BenchSpeaker> speakers, required List<BenchLine> lines}) = _BenchScript;
}

/// One read of one line. Times are milliseconds since the bench page opened.
@freezed
abstract class BenchTake with _$BenchTake {
  const factory BenchTake({
    required int n,
    required String transcript,
    required int micOnMs,
    int? firstPartialMs,
    int? finalMs,
  }) = _BenchTake;
}

/// The bench script, from a build-time copy of `bench/references.json`.
abstract interface class BenchScriptRepository {
  @useResult
  Future<Result<BenchScript>> load();
}

/// Saves the session as JSON for `npm run bench` (a browser download on web).
abstract interface class BenchExporter {
  /// The browser, recorded in the export.
  String get browser;

  Future<void> save(String filename, String json);
}
