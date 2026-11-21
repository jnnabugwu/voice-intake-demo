import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intake/shared/core/ids.dart';
import 'package:intake/worker/features/speech/domain/speech_engine.dart';
import 'package:intake/worker/features/speech/presentation/speech_bloc.dart';
import 'package:intake/worker/worker_screen.dart';

part 'routes.g.dart';

@TypedGoRoute<WorkerRoute>(path: '/worker')
class WorkerRoute extends GoRouteData with $WorkerRoute {
  const WorkerRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => BlocProvider(
    create: (context) => SpeechBloc(context.read<SpeechEngine>(), context.read<IdGenerator>()),
    child: const WorkerScreen(),
  );
}
