import 'package:flutter/widgets.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/ui/ui.dart';
import 'package:intake/worker/features/speech/presentation/speech_state.dart';
import 'package:intake/worker/features/speech/presentation/speech_strings.dart';

/// The words being heard, large enough to read at arm's length. Partial words
/// are muted until they turn final.
class LiveTranscript extends StatelessWidget {
  const LiveTranscript({super.key, required this.phase, required this.language});

  final SpeechPhase phase;
  final Language language;

  @override
  Widget build(BuildContext context) {
    final strings = SpeechStrings.of(language);
    final large = context.type.large;
    final muted = large.copyWith(color: context.tokens.mutedForeground);
    final (text, style) = switch (phase) {
      SpeechListening(:final partial) when partial.isNotEmpty => (partial, muted),
      SpeechListening() || SpeechStarting() => (strings.listening, muted),
      SpeechIdle() || SpeechUnavailable() => (strings.tapToSpeak, muted),
    };
    return Semantics(
      liveRegion: phase is SpeechListening,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Text(text, style: style, textAlign: TextAlign.center),
      ),
    );
  }
}
