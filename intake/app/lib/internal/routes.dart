import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:intake/internal/features/bench/presentation/bench_page.dart';

part 'routes.g.dart';

/// Lines in the bench script (`bench/references.json`).
const benchLineCount = 21;

@TypedGoRoute<BenchRoute>(path: '/bench')
class BenchRoute extends GoRouteData with $BenchRoute {
  const BenchRoute({this.line});

  /// Query parameter `/bench?line=7`. Bad or out-of-range values degrade to
  /// the nearest valid line instead of crashing.
  final int? line;

  int get startLine => (line ?? 1).clamp(1, benchLineCount);

  @override
  Widget build(BuildContext context, GoRouterState state) => BenchPage(startLine: startLine);
}
