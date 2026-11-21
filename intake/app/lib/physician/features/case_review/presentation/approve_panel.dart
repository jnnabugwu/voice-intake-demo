import 'package:flutter/widgets.dart';
import 'package:intake/shared/features/intake_case/domain/intake_case.dart';
import 'package:intake/shared/ui/ui.dart';

/// The next step the worker will see, written or edited by the physician.
/// Nothing reaches the worker until Approve.
class ApprovePanel extends StatefulWidget {
  const ApprovePanel({
    super.key,
    required this.caseId,
    required this.status,
    required this.draft,
    required this.approving,
    required this.onDraftChanged,
    required this.onApprove,
  });

  final String caseId;
  final CaseStatus status;
  final String draft;
  final bool approving;
  final ValueChanged<String> onDraftChanged;
  final VoidCallback onApprove;

  @override
  State<ApprovePanel> createState() => _ApprovePanelState();
}

class _ApprovePanelState extends State<ApprovePanel> {
  late final _controller = TextEditingController(text: widget.draft);

  @override
  void didUpdateWidget(ApprovePanel old) {
    super.didUpdateWidget(old);
    if (old.caseId != widget.caseId || (widget.draft != _controller.text && !widget.approving)) {
      _controller.text = widget.draft;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final approved = widget.status is Approved;
    final unchanged = switch (widget.status) {
      Approved(:final nextStep) => nextStep == widget.draft.trim(),
      AwaitingReview() => false,
    };
    return AppCard(
      title: 'Next step for the worker',
      description: approved
          ? 'Approved. The worker sees this now. Edit and approve again to change it.'
          : 'The worker sees nothing until you approve.',
      footer: AppButton.primary(
        label: approved ? 'Approve changes' : 'Approve',
        icon: LucideIcons.check,
        onPressed: widget.approving || widget.draft.trim().isEmpty || unchanged ? null : widget.onApprove,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: AppTextArea(controller: _controller, onChanged: widget.onDraftChanged, enabled: !widget.approving),
      ),
    );
  }
}
