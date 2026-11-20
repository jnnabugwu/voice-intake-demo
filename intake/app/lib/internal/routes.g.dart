// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$benchRoute];

RouteBase get $benchRoute =>
    GoRouteData.$route(path: '/bench', hasOverriddenOnExit: false, factory: $BenchRoute._fromState);

mixin $BenchRoute on GoRouteData {
  static BenchRoute _fromState(GoRouterState state) =>
      BenchRoute(line: _$convertMapValue('line', state.uri.queryParameters, int.tryParse));

  BenchRoute get _self => this as BenchRoute;

  @override
  String get location =>
      GoRouteData.$location('/bench', queryParams: {if (_self.line != null) 'line': _self.line!.toString()});

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

T? _$convertMapValue<T>(String key, Map<String, String> map, T? Function(String) converter) {
  final value = map[key];
  return value == null ? null : converter(value);
}
