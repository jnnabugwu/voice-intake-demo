import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:intake/worker/worker_screen.dart';

part 'routes.g.dart';

@TypedGoRoute<WorkerRoute>(path: '/worker')
class WorkerRoute extends GoRouteData with $WorkerRoute {
  const WorkerRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const WorkerScreen();
}
