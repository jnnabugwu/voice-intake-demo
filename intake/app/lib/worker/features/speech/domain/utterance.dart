import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intake/shared/core/language.dart';

part 'utterance.freezed.dart';

/// One finished thing the worker said. The ID is made once, when the speech
/// ends, so a hand-off or a retry can't submit it twice.
@freezed
abstract class Utterance with _$Utterance {
  const factory Utterance({required String id, required String text, required Language language}) = _Utterance;
}
