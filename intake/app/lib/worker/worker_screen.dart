import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intake/shared/core/failure.dart';
import 'package:intake/shared/ui/ui.dart';
import 'package:intake/worker/features/conversation/presentation/chat_list.dart';
import 'package:intake/worker/features/conversation/presentation/conversation_bloc.dart';
import 'package:intake/worker/features/conversation/presentation/conversation_strings.dart';
import 'package:intake/worker/features/next_step/presentation/next_step_bloc.dart';
import 'package:intake/worker/features/next_step/presentation/next_step_card.dart';
import 'package:intake/worker/features/speech/presentation/language_toggle.dart';
import 'package:intake/worker/features/speech/presentation/live_transcript.dart';
import 'package:intake/worker/features/speech/presentation/mic_button.dart';
import 'package:intake/worker/features/speech/presentation/speech_bloc.dart';
import 'package:intake/worker/features/speech/presentation/typed_fallback.dart';

/// The worker's one page: mic, chat, next step and escalation card. It
/// composes this side's features and holds the one hand-off between them.
class WorkerScreen extends StatelessWidget {
  const WorkerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // The only Bloc-to-Bloc hand-off: a finished utterance becomes a message.
        BlocListener<SpeechBloc, SpeechState>(
          listenWhen: (previous, current) =>
              current.lastUtterance != null && previous.lastUtterance?.id != current.lastUtterance!.id,
          listener: (context, state) {
            final utterance = state.lastUtterance!;
            context.read<ConversationBloc>().add(
              UtteranceSubmitted(utteranceId: utterance.id, text: utterance.text, language: utterance.language),
            );
          },
        ),
        // Speech that finished while a reply streamed waits, then goes in once
        // the conversation takes input again. Already-answered IDs are ignored.
        BlocListener<ConversationBloc, ConversationState>(
          listenWhen: (previous, current) => previous.phase is Streaming && current.phase is! Streaming,
          listener: (context, state) {
            final utterance = context.read<SpeechBloc>().state.lastUtterance;
            if (utterance == null || state.turns.any((t) => t.id == utterance.id)) return;
            context.read<ConversationBloc>().add(
              UtteranceSubmitted(utteranceId: utterance.id, text: utterance.text, language: utterance.language),
            );
          },
        ),
        BlocListener<ConversationBloc, ConversationState>(
          listenWhen: (previous, current) => previous.phase != current.phase && current.phase is ReplyFailed,
          listener: (context, state) {
            final failure = (state.phase as ReplyFailed).failure;
            if (failure is SpendCapFailure) return; // shown inline, not as a toast
            final strings = ConversationStrings.of(context.read<SpeechBloc>().state.language);
            showAppToast(
              context,
              strings.failureToast(failure),
              retryLabel: strings.retry,
              onRetry: () => context.read<ConversationBloc>().add(const ReplyRetryRequested()),
            );
          },
        ),
      ],
      child: const _WorkerBody(),
    );
  }
}

class _WorkerBody extends StatelessWidget {
  const _WorkerBody();

  @override
  Widget build(BuildContext context) {
    final speech = context.watch<SpeechBloc>().state;
    final conversation = context.watch<ConversationBloc>().state;
    final speechBloc = context.read<SpeechBloc>();
    final conversationBloc = context.read<ConversationBloc>();
    final language = speech.language;
    final strings = ConversationStrings.of(language);
    final phase = conversation.phase;
    final spendCapped = phase is ReplyFailed && phase.failure is SpendCapFailure;
    final canSend = phase is Gathering || (phase is ReplyFailed && !spendCapped);
    final micLive = speech.phase is SpeechStarting || speech.phase is SpeechListening;
    final finished = phase is Finished;
    final speechFailure = switch (speech.phase) {
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
                language: language,
                enabled: !finished,
                onChanged: (language) => speechBloc.add(SpeechLanguageChanged(language)),
              ),
            ),
            const SizedBox(height: 8),
            ChatList(state: conversation, language: language),
            if (spendCapped) ...[
              const SizedBox(height: 16),
              AppAlert.info(icon: LucideIcons.pause, title: strings.spendCapTitle, description: strings.spendCapBody),
            ],
            const SizedBox(height: 24),
            if (phase is SubmitFailed) ...[
              AppAlert.danger(title: strings.submitFailed),
              const SizedBox(height: 12),
              AppButton.primary(
                label: strings.tryAgain,
                icon: LucideIcons.refreshCw,
                expand: true,
                onPressed: () => conversationBloc.add(const FinishRequested()),
              ),
            ] else if (finished) ...[
              AppAlert.info(icon: LucideIcons.send, title: strings.finished),
              const SizedBox(height: 16),
              NextStepCard(state: context.watch<NextStepBloc>().state, language: language),
            ] else ...[
              LiveTranscript(phase: speech.phase, language: language),
              const SizedBox(height: 16),
              Center(
                child: MicButton(
                  phase: speech.phase,
                  language: language,
                  enabled: canSend,
                  onStart: () => speechBloc.add(const SpeechStarted()),
                  onStop: () => speechBloc.add(const SpeechStopped()),
                ),
              ),
              const SizedBox(height: 24),
              TypedFallback(
                language: language,
                reason: speechFailure,
                enabled: canSend,
                onSubmitted: (text) => conversationBloc.add(TypedMessageSubmitted(text: text, language: language)),
              ),
              if (conversation.turns.isNotEmpty) ...[
                const SizedBox(height: 16),
                AppButton.outline(
                  label: strings.finish,
                  icon: LucideIcons.check,
                  expand: true,
                  onPressed: phase is Gathering && !micLive
                      ? () => conversationBloc.add(const FinishRequested())
                      : null,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
