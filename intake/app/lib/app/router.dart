import 'package:go_router/go_router.dart';
import 'package:intake/app/not_found_page.dart';
import 'package:intake/app/side_shell.dart';
import 'package:intake/internal/routes.dart' as internal;
import 'package:intake/physician/routes.dart' as physician;
import 'package:intake/worker/routes.dart' as worker;

/// The only place both sides meet. The shell declares no paths, so the typed
/// routes stay the only source of URLs.
GoRouter createRouter({String? initialLocation}) => GoRouter(
  initialLocation: initialLocation ?? const worker.WorkerRoute().location,
  redirect: (context, state) => state.uri.path == '/' ? const worker.WorkerRoute().location : null,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => SideShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [worker.$workerRoute]),
        StatefulShellBranch(routes: [physician.$reviewRoute]),
      ],
    ),
    internal.$benchRoute,
  ],
  errorBuilder: (context, state) => const NotFoundPage(),
);
