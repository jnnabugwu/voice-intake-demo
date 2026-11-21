import 'package:flutter/widgets.dart';
import 'package:intake/shared/features/intake_case/domain/intake_case.dart';
import 'package:intake/shared/features/safety/domain/red_flag.dart';
import 'package:intake/shared/ui/components.dart';
import 'package:intake/shared/ui/theme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A case's status as a token, an icon and a word together, never color alone.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.awaitingLabel, this.approvedLabel});

  final CaseStatus status;

  /// Overrides for the worker's language; defaults are the physician's English.
  final String? awaitingLabel;
  final String? approvedLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return switch (status) {
      AwaitingReview() => AppBadge.outline(
        label: awaitingLabel ?? 'Waiting for a clinician',
        icon: LucideIcons.clock,
        color: tokens.pending,
      ),
      Approved() => AppBadge.outline(
        label: approvedLabel ?? 'Approved',
        icon: LucideIcons.circleCheck,
        color: tokens.approved,
      ),
    };
  }
}

/// Shown beside the status when the chat stopped on a red flag. It stays
/// after approval: the worker was shown 911 / 988 either way.
class EscalationBadge extends StatelessWidget {
  const EscalationBadge({super.key, required this.flag});

  final RedFlag flag;

  @override
  Widget build(BuildContext context) => AppBadge.outline(
    label: flag.kind == RedFlagKind.crisis ? 'Escalated: crisis (988 shown)' : 'Escalated: emergency (911 shown)',
    icon: LucideIcons.siren,
    color: context.tokens.escalation,
  );
}

/// A section that opens and closes, such as the full transcript.
class AppDisclosure extends StatelessWidget {
  const AppDisclosure({super.key, required this.title, required this.child, this.initiallyOpen = false});

  final String title;
  final Widget child;
  final bool initiallyOpen;

  @override
  Widget build(BuildContext context) {
    return ShadAccordion<String>(
      initialValue: initiallyOpen ? title : null,
      children: [ShadAccordionItem<String>(value: title, title: Text(title), child: child)],
    );
  }
}
