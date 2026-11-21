import 'package:flutter/widgets.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/ui/ui.dart';
import 'package:intake/worker/features/next_step/presentation/next_step_bloc.dart';

/// Locked: "waiting for a clinician" and no content. Unlocked: the approved step.
class NextStepCard extends StatelessWidget {
  const NextStepCard({super.key, required this.state, required this.language});

  final NextStepState state;
  final Language language;

  @override
  Widget build(BuildContext context) {
    final es = language == Language.es;
    final tokens = context.tokens;
    return switch (state) {
      // WorkerScreen shows the full-screen escalation card instead.
      NextStepNone() || NextStepEscalated() => const SizedBox.shrink(),
      NextStepLocked() => Semantics(
        liveRegion: true,
        child: AppCard(
          title: es ? 'Su siguiente paso' : 'Your next step',
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(LucideIcons.lock, color: tokens.pending, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    es
                        ? 'Esperando a un médico. Aparecerá aquí cuando lo apruebe.'
                        : 'Waiting for a clinician. It shows here once they approve it.',
                    style: context.type.p,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      NextStepUnlocked(:final nextStep) => Semantics(
        liveRegion: true,
        child: AppCard(
          title: es ? 'Su siguiente paso' : 'Your next step',
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBadge.outline(
                  label: es ? 'Aprobado por un médico' : 'Approved by a clinician',
                  icon: LucideIcons.circleCheck,
                  color: tokens.approved,
                ),
                const SizedBox(height: 8),
                Text(nextStep, style: context.type.large),
              ],
            ),
          ),
        ),
      ),
    };
  }
}
