import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intake/shared/ui/ui.dart';
import 'package:intake/worker/features/speech/presentation/language_toggle.dart';
import 'package:intake/worker/features/speech/presentation/live_transcript.dart';
import 'package:intake/worker/features/speech/presentation/mic_button.dart';
import 'package:intake/worker/features/speech/presentation/speech_bloc.dart';
import 'package:intake/worker/features/speech/presentation/typed_fallback.dart';

/// The worker's one page: mic, chat, next step and escalation card. It
/// composes this side's features.
class WorkerScreen extends StatelessWidget {
  const WorkerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final speech = context.watch<SpeechBloc>().state;
    final bloc = context.read<SpeechBloc>();
    final failure = switch (speech.phase) {
      SpeechUnavailable(:final failure) => failure,
      _ => null,
    };
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: LanguageToggle(
                language: speech.language,
                onChanged: (language) => bloc.add(SpeechLanguageChanged(language)),
              ),
            ),
            if (speech.lastUtterance case final utterance?) ...[
              const SizedBox(height: 16),
              AppCard(child: Text(utterance.text, style: context.type.large)),
            ],
            const SizedBox(height: 24),
            LiveTranscript(phase: speech.phase, language: speech.language),
            const SizedBox(height: 16),
            Center(
              child: MicButton(
                phase: speech.phase,
                language: speech.language,
                onStart: () => bloc.add(const SpeechStarted()),
                onStop: () => bloc.add(const SpeechStopped()),
              ),
            ),
            const SizedBox(height: 24),
            TypedFallback(language: speech.language, reason: failure, onSubmitted: (_) {}),
          ],
        ),
      ),
    );
  }
}
