// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$workerRoute];

RouteBase get $workerRoute =>
    GoRouteData.$route(path: '/worker', hasOverriddenOnExit: false, factory: $WorkerRoute._fromState);

mixin $WorkerRoute on GoRouteData {
  static WorkerRoute _fromState(GoRouterState state) => const WorkerRoute();

  @override
  String get location => GoRouteData.$location('/worker');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
