import 'package:freezed_annotation/freezed_annotation.dart';

part 'red_flag.freezed.dart';

/// Emergency: call 911. Crisis (self-harm, suicide): call or text 988.
enum RedFlagKind { emergency, crisis }

@freezed
abstract class RedFlag with _$RedFlag {
  /// [reason] is what triggered it, for the physician: the matched words or
  /// the summary's red-flag entry.
  const factory RedFlag({required RedFlagKind kind, required String reason}) = _RedFlag;
}
