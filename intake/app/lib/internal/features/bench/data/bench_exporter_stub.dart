import 'package:intake/internal/features/bench/domain/bench.dart';

/// Off the web there is nowhere to download to; the bench is a Chrome tool.
class DownloadBenchExporter implements BenchExporter {
  @override
  String get browser => 'not a browser';

  @override
  Future<void> save(String filename, String json) async {}
}
