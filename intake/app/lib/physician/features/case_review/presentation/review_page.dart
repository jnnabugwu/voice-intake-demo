import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intake/physician/features/case_review/presentation/approve_panel.dart';
import 'package:intake/physician/features/case_review/presentation/review_bloc.dart';
import 'package:intake/physician/features/case_review/presentation/summary_panel.dart';
import 'package:intake/shared/features/intake_case/domain/intake_case.dart';
import 'package:intake/shared/features/safety/domain/red_flag.dart';
import 'package:intake/shared/ui/ui.dart';

/// The physician's review of one case. [caseId] null means the current case.
class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key, this.caseId});

  final String? caseId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReviewBloc, ReviewState>(
      listenWhen: (previous, current) =>
          previous is ReviewReady && previous.approving && current is ReviewReady && !current.approving,
      listener: (context, state) {
        final ready = state as ReviewReady;
        showAppToast(
          context,
          ready.approveFailure == null ? 'Approved. The worker can see the next step.' : "Couldn't approve. Try again.",
        );
      },
      child: BlocBuilder<ReviewBloc, ReviewState>(
        builder: (context, state) => switch (state) {
          ReviewLoading() => const SizedBox.shrink(),
          ReviewNoCase() => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: AppAlert.info(
                icon: LucideIcons.inbox,
                title: 'No intake waiting for review',
                description: 'Switch to Worker, run an intake and tap Finish. It shows up here.',
              ),
            ),
          ),
          ReviewReady(:final intakeCase, :final draft, :final approving) => _Ready(
            intakeCase: intakeCase,
            draft: draft,
            approving: approving,
          ),
        },
      ),
    );
  }
}

class _Ready extends StatelessWidget {
  const _Ready({required this.intakeCase, required this.draft, required this.approving});

  final IntakeCase intakeCase;
  final String draft;
  final bool approving;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ReviewBloc>();
    final approve = ApprovePanel(
      caseId: intakeCase.id,
      status: intakeCase.status,
      draft: draft,
      approving: approving,
      onDraftChanged: (text) => bloc.add(NextStepDraftChanged(text)),
      onApprove: () => bloc.add(const ApproveRequested()),
    );
    final escalation = switch (intakeCase.status) {
      Escalated(:final flag) => AppAlert.danger(
        title: 'The chat stopped on a red flag',
        description:
            'The worker was shown ${flag.kind == RedFlagKind.crisis ? '988 and 911' : '911 and 988'}. Trigger: "${flag.reason}". Follow up directly.',
      ),
      _ => null,
    };
    final header = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        Text('Intake review', style: context.type.h3),
        StatusBadge(status: intakeCase.status),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop or tablet: summary and decision side by side. Phone: stacked, summary first.
        if (constraints.maxWidth >= 900) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                if (escalation != null) ...[const SizedBox(height: 12), escalation],
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: SummaryPanel(intakeCase: intakeCase)),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: approve),
                  ],
                ),
              ],
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            header,
            if (escalation != null) ...[const SizedBox(height: 12), escalation],
            const SizedBox(height: 16),
            SummaryPanel(intakeCase: intakeCase),
            const SizedBox(height: 16),
            approve,
          ],
        );
      },
    );
  }
}
