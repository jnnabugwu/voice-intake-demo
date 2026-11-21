import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intake/app/app.dart';
import 'package:intake/app/app_mode.dart';
import 'package:intake/app/router.dart';
import 'package:intake/shared/core/ids.dart';
import 'package:intake/worker/features/speech/data/web_speech_engine.dart';
import 'package:intake/worker/features/speech/domain/speech_engine.dart';

/// The composition root, and the only file that imports `data/`. It picks the
/// repositories once, from `PROXY_URL`, and hands them down.
void bootstrap() {
  const proxyUrl = String.fromEnvironment('PROXY_URL');
  const mode = proxyUrl == '' ? AppMode.demo : AppMode.live;

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppMode>.value(value: mode),
        RepositoryProvider<IdGenerator>(create: (_) => IdGenerator()),
        RepositoryProvider<SpeechEngine>(create: (_) => WebSpeechEngine()),
      ],
      child: IntakeApp(router: createRouter()),
    ),
  );
}
