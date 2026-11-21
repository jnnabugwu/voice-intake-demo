import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intake/shared/core/language.dart';

part 'turn.freezed.dart';

enum Speaker { worker, assistant }

/// One message in the conversation. Its ID is made once, when it is first
/// submitted; a retry reuses it.
@freezed
abstract class Turn with _$Turn {
  const factory Turn({required String id, required Speaker speaker, required String text, required Language language}) =
      _Turn;
}
