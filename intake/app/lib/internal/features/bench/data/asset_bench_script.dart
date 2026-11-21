import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:intake/internal/features/bench/domain/bench.dart';
import 'package:intake/shared/core/failure.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/core/result.dart';

/// Reads `assets/bench/references.json`, a copy of `bench/references.json`
/// made by `tool/sync_bench_script.sh` and checked by a test.
class AssetBenchScriptRepository implements BenchScriptRepository {
  const AssetBenchScriptRepository([this._bundle]);

  final AssetBundle? _bundle;

  @override
  Future<Result<BenchScript>> load() async {
    try {
      final raw = await (_bundle ?? rootBundle).loadString('assets/bench/references.json');
      return Ok(parseScript(raw));
    } catch (e) {
      return Err(UnknownFailure('bench_script: $e'));
    }
  }

  static BenchScript parseScript(String raw) {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return BenchScript(
      speakers: [
        for (final s in (json['speakers'] as List).cast<Map<String, dynamic>>())
          BenchSpeaker(
            id: s['id'] as String,
            locale: s['lang'] as String,
            language: (s['lang'] as String).startsWith('es') ? Language.es : Language.en,
          ),
      ],
      lines: [
        for (final l in (json['lines'] as List).cast<Map<String, dynamic>>())
          BenchLine(
            n: l['n'] as int,
            en: (l['en'] as Map<String, dynamic>)['text'] as String,
            es: (l['es'] as Map<String, dynamic>)['text'] as String,
          ),
      ],
    );
  }
}
