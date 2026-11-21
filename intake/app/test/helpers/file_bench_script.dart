import 'dart:io';

import 'package:intake/internal/features/bench/data/asset_bench_script.dart';
import 'package:intake/internal/features/bench/domain/bench.dart';
import 'package:intake/shared/core/result.dart';

/// The bench script read straight from `bench/references.json`. Widget tests
/// can't await rootBundle across tests (its cache outlives each test's zone).
class FileBenchScriptRepository implements BenchScriptRepository {
  @override
  Future<Result<BenchScript>> load() async =>
      Ok(AssetBenchScriptRepository.parseScript(File('../../bench/references.json').readAsStringSync()));
}
