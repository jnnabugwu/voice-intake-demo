import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intake/app/app.dart';
import 'package:intake/app/app_mode.dart';
import 'package:intake/app/router.dart';
import 'package:intake/shared/core/ids.dart';
import 'package:intake/shared/features/intake_case/data/demo_summary_repository.dart';
import 'package:intake/shared/features/intake_case/data/in_memory_case_repository.dart';
import 'package:intake/shared/features/intake_case/data/proxy_summary_repository.dart';
import 'package:intake/shared/features/intake_case/domain/case_repository.dart';
import 'package:intake/shared/features/intake_case/domain/summary_repository.dart';
import 'package:intake/worker/features/conversation/data/demo_chat_repository.dart';
import 'package:intake/worker/features/conversation/data/proxy_chat_repository.dart';
import 'package:intake/worker/features/conversation/domain/chat_repository.dart';
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
        // Demo mode scripts the replies and the summary; live mode asks the proxy.
        RepositoryProvider<ChatRepository>(
          create: (_) => switch (mode) {
            AppMode.demo => DemoChatRepository(),
            AppMode.live => ProxyChatRepository(baseUrl: proxyUrl),
          },
        ),
        RepositoryProvider<SummaryRepository>(
          create: (_) => switch (mode) {
            AppMode.demo => const DemoSummaryRepository(),
            AppMode.live => ProxySummaryRepository(baseUrl: proxyUrl),
          },
        ),
        // Both sides read this one store, in both modes.
        RepositoryProvider<CaseRepository>(create: (_) => InMemoryCaseRepository()),
      ],
      child: IntakeApp(router: createRouter()),
    ),
  );
}
