import 'package:intake/shared/core/ids.dart';

/// Predictable IDs: `u_1`, `u_2`, ...
class SequentialIds extends IdGenerator {
  int _n = 0;

  @override
  String next(String prefix) => '${prefix}_${++_n}';
}
