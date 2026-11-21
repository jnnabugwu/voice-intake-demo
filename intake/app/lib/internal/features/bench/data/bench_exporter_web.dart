import 'dart:js_interop';

import 'package:intake/internal/features/bench/domain/bench.dart';
import 'package:web/web.dart' as web;

/// Downloads the export as a file, for `bench/chrome/`.
class DownloadBenchExporter implements BenchExporter {
  @override
  String get browser => web.window.navigator.userAgent;

  @override
  Future<void> save(String filename, String json) async {
    final blob = web.Blob([json.toJS].toJS, web.BlobPropertyBag(type: 'application/json'));
    final url = web.URL.createObjectURL(blob);
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = filename;
    anchor.click();
    web.URL.revokeObjectURL(url);
  }
}
