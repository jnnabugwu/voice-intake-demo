import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intake/physician/features/case_review/presentation/review_bloc.dart';
import 'package:intake/shared/features/intake_case/domain/case_repository.dart';
import 'package:intake/physician/features/case_review/presentation/review_page.dart';

part 'routes.g.dart';

@TypedGoRoute<ReviewRoute>(
  path: '/physician',
  routes: [TypedGoRoute<CaseRoute>(path: 'cases/:caseId')],
)
class ReviewRoute extends GoRouteData with $ReviewRoute {
  const ReviewRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => BlocProvider(
    create: (context) => ReviewBloc(context.read<CaseRepository>())..add(const ReviewOpened()),
    child: const ReviewPage(),
  );
}

class CaseRoute extends GoRouteData with $CaseRoute {
  const CaseRoute({required this.caseId});

  final String caseId;

  @override
  Widget build(BuildContext context, GoRouterState state) => BlocProvider(
    create: (context) => ReviewBloc(context.read<CaseRepository>())..add(ReviewOpened(caseId)),
    child: ReviewPage(caseId: caseId),
  );
}
