import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intake/shared/core/ids.dart';
import 'package:intake/shared/features/intake_case/domain/case_repository.dart';
import 'package:intake/shared/features/intake_case/domain/summary_repository.dart';
import 'package:intake/worker/features/conversation/domain/submit_intake.dart';
import 'package:intake/worker/features/next_step/presentation/next_step_bloc.dart';
import 'package:intake/worker/features/conversation/domain/chat_repository.dart';
import 'package:intake/worker/features/conversation/presentation/conversation_bloc.dart';
import 'package:intake/shared/features/speech/domain/speech_engine.dart';
import 'package:intake/worker/features/speech/presentation/speech_bloc.dart';
import 'package:intake/worker/worker_screen.dart';

part 'routes.g.dart';

@TypedGoRoute<WorkerRoute>(path: '/worker')
class WorkerRoute extends GoRouteData with $WorkerRoute {
  const WorkerRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => SpeechBloc(context.read<SpeechEngine>(), context.read<IdGenerator>())),
      BlocProvider(
        create: (context) => ConversationBloc(
          context.read<ChatRepository>(),
          context.read<IdGenerator>(),
          SubmitIntake(context.read<SummaryRepository>(), context.read<CaseRepository>()),
        ),
      ),
      BlocProvider(
        create: (context) => NextStepBloc(context.read<CaseRepository>())..add(const NextStepWatchStarted()),
      ),
    ],
    child: const WorkerScreen(),
  );
}
