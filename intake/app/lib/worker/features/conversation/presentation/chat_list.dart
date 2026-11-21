import 'package:flutter/widgets.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/ui/ui.dart';
import 'package:intake/worker/features/conversation/domain/turn.dart';
import 'package:intake/worker/features/conversation/presentation/conversation_state.dart';
import 'package:intake/worker/features/conversation/presentation/conversation_strings.dart';

/// The conversation, oldest first, with the streaming reply last.
class ChatList extends StatelessWidget {
  const ChatList({super.key, required this.state, required this.language});

  final ConversationState state;
  final Language language;

  @override
  Widget build(BuildContext context) {
    final strings = ConversationStrings.of(language);
    final phase = state.phase;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReplyBubble(text: strings.greeting, label: strings.assistant),
        for (final turn in state.turns)
          turn.speaker == Speaker.worker
              ? WorkerBubble(text: turn.text, label: strings.you)
              : ReplyBubble(text: turn.text, label: strings.assistant),
        if (phase is Streaming) ReplyBubble(text: phase.reply, label: strings.assistant, streaming: true),
      ],
    );
  }
}

class WorkerBubble extends StatelessWidget {
  const WorkerBubble({super.key, required this.text, required this.label});

  final String text;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 48, top: 8),
      child: Semantics(
        label: label,
        child: AppCard(child: Text(text, style: context.type.p)),
      ),
    );
  }
}

/// An assistant message. While [streaming], a caret shows instead of a spinner.
class ReplyBubble extends StatelessWidget {
  const ReplyBubble({super.key, required this.text, required this.label, this.streaming = false});

  final String text;
  final String label;
  final bool streaming;

  @override
  Widget build(BuildContext context) {
    final style = context.type.p;
    return Padding(
      padding: const EdgeInsets.only(right: 48, top: 8),
      child: Semantics(
        label: label,
        liveRegion: !streaming,
        child: AppCard(
          muted: true,
          child: Text.rich(
            TextSpan(
              text: text,
              children: [
                if (streaming)
                  TextSpan(
                    text: ' ▍',
                    style: style.copyWith(color: context.tokens.listening),
                  ),
              ],
            ),
            style: style,
          ),
        ),
      ),
    );
  }
}
