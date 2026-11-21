import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intake/app/app.dart';
import 'package:intake/app/app_mode.dart';
import 'package:intake/app/router.dart';

/// The composition root, and the only file that imports `data/`. It picks the
/// repositories once, from `PROXY_URL`, and hands them down.
void bootstrap() {
  const proxyUrl = String.fromEnvironment('PROXY_URL');
  const mode = proxyUrl == '' ? AppMode.demo : AppMode.live;

  runApp(
    MultiRepositoryProvider(
      providers: [RepositoryProvider<AppMode>.value(value: mode)],
      child: IntakeApp(router: createRouter()),
    ),
  );
}
