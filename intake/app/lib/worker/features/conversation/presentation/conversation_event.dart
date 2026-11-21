import 'package:intake/shared/core/language.dart';

sealed class ConversationEvent {
  const ConversationEvent();
}

/// The worker finished speaking. [utteranceId] makes a repeated hand-off a no-op.
final class UtteranceSubmitted extends ConversationEvent {
  const UtteranceSubmitted({required this.utteranceId, required this.text, required this.language});

  final String utteranceId;
  final String text;
  final Language language;
}

final class TypedMessageSubmitted extends ConversationEvent {
  const TypedMessageSubmitted({required this.text, required this.language});

  final String text;
  final Language language;
}

/// Try the failed reply again, with the same turn ID.
final class ReplyRetryRequested extends ConversationEvent {
  const ReplyRetryRequested();
}

/// The worker tapped Finish.
final class FinishRequested extends ConversationEvent {
  const FinishRequested();
}
