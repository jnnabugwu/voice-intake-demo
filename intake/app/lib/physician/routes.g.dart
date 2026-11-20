// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$reviewRoute];

RouteBase get $reviewRoute => GoRouteData.$route(
  path: '/physician',
  hasOverriddenOnExit: false,
  factory: $ReviewRoute._fromState,
  routes: [GoRouteData.$route(path: 'cases/:caseId', hasOverriddenOnExit: false, factory: $CaseRoute._fromState)],
);

mixin $ReviewRoute on GoRouteData {
  static ReviewRoute _fromState(GoRouterState state) => const ReviewRoute();

  @override
  String get location => GoRouteData.$location('/physician');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $CaseRoute on GoRouteData {
  static CaseRoute _fromState(GoRouterState state) => CaseRoute(caseId: state.pathParameters['caseId']!);

  CaseRoute get _self => this as CaseRoute;

  @override
  String get location => GoRouteData.$location('/physician/cases/${Uri.encodeComponent(_self.caseId)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
