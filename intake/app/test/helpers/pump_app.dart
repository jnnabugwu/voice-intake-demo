import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intake/app/app.dart';
import 'package:intake/app/app_mode.dart';
import 'package:intake/app/router.dart';
import 'package:intake/internal/features/bench/data/bench_exporter_stub.dart';
import 'package:intake/internal/features/bench/domain/bench.dart';
import 'package:intake/shared/core/ids.dart';
import 'package:intake/shared/features/intake_case/data/demo_summary_repository.dart';
import 'package:intake/shared/features/intake_case/data/in_memory_case_repository.dart';
import 'package:intake/shared/features/intake_case/domain/case_repository.dart';
import 'package:intake/shared/features/intake_case/domain/summary_repository.dart';
import 'package:intake/worker/features/conversation/data/demo_chat_repository.dart';
import 'package:intake/worker/features/conversation/domain/chat_repository.dart';
import 'package:intake/shared/features/speech/domain/speech_engine.dart';

import 'fake_speech_engine.dart';
import 'file_bench_script.dart';
import 'sequential_ids.dart';

/// The whole app at [location], with fakes in place of every repository.
Future<void> pumpApp(
  WidgetTester tester, {
  String location = '/worker',
  AppMode mode = AppMode.demo,
  SpeechEngine? speech,
  ChatRepository? chat,
  CaseRepository? cases,
}) async {
  // A tall phone-shaped window, so the whole worker column is built.
  tester.view.physicalSize = const Size(1080, 4000);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppMode>.value(value: mode),
        RepositoryProvider<IdGenerator>.value(value: SequentialIds()),
        RepositoryProvider<SpeechEngine>.value(value: speech ?? FakeSpeechEngine()),
        RepositoryProvider<ChatRepository>.value(value: chat ?? DemoChatRepository(wordDelay: Duration.zero)),
        RepositoryProvider<SummaryRepository>.value(value: const DemoSummaryRepository()),
        RepositoryProvider<CaseRepository>.value(value: cases ?? InMemoryCaseRepository()),
        RepositoryProvider<BenchScriptRepository>.value(value: FileBenchScriptRepository()),
        RepositoryProvider<BenchExporter>.value(value: DownloadBenchExporter()),
      ],
      child: IntakeApp(router: createRouter(initialLocation: location)),
    ),
  );
  await tester.pumpAndSettle();
}
