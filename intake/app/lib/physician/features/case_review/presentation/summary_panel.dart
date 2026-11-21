import 'package:flutter/widgets.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/features/intake_case/domain/intake_case.dart';
import 'package:intake/shared/ui/ui.dart';

/// The structured summary. A field the worker didn't mention reads "Not
/// mentioned" and is never left blank.
class SummaryPanel extends StatelessWidget {
  const SummaryPanel({super.key, required this.intakeCase});

  final IntakeCase intakeCase;

  @override
  Widget build(BuildContext context) {
    final summary = intakeCase.summary;
    final language = intakeCase.language == Language.es ? 'Spanish' : 'English';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (summary == null)
          const AppAlert.info(title: "The summary couldn't be built", description: 'Read the full transcript below.')
        else ...[
          if (summary.redFlags.isNotEmpty) ...[_RedFlags(flags: summary.redFlags), const SizedBox(height: 12)],
          AppCard(
            title: 'Chief complaint',
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _Value(summary.chiefComplaint, style: context.type.large),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _Field(label: 'How long', child: _Value(summary.duration)),
              _Field(label: 'How bad (1–10)', child: _Severity(summary.severity)),
              _Field(label: 'Language', child: _Value(language)),
            ],
          ),
          const SizedBox(height: 12),
          _ListCard(title: 'Symptoms', items: summary.symptoms),
          const SizedBox(height: 12),
          _ListCard(title: 'Medications', items: summary.medications),
          const SizedBox(height: 12),
          _ListCard(title: 'Allergies', items: summary.allergies),
          const SizedBox(height: 12),
          _ListCard(title: 'Still to ask', items: summary.openQuestions, emptyText: 'Nothing open'),
        ],
        const SizedBox(height: 12),
        AppDisclosure(
          title: 'Full transcript',
          initiallyOpen: summary == null,
          child: _Transcript(lines: intakeCase.transcript),
        ),
      ],
    );
  }
}

class _RedFlags extends StatelessWidget {
  const _RedFlags({required this.flags});

  final List<String> flags;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAlert.danger(title: 'Red flags', description: flags.join(' · ')),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [for (final f in flags) AppBadge.danger(label: f, icon: LucideIcons.siren)],
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 160),
      child: IntrinsicWidth(
        child: AppCard(
          title: label,
          child: Padding(padding: const EdgeInsets.only(top: 8), child: child),
        ),
      ),
    );
  }
}

class _Value extends StatelessWidget {
  const _Value(this.value, {this.style});

  final String? value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final v = value;
    if (v == null || v.trim().isEmpty) {
      return Text('Not mentioned', style: context.type.p.copyWith(color: context.tokens.mutedForeground));
    }
    return Text(v, style: style ?? context.type.p);
  }
}

class _Severity extends StatelessWidget {
  const _Severity(this.severity);

  final int? severity;

  @override
  Widget build(BuildContext context) {
    final s = severity;
    if (s == null) return const _Value(null);
    return Align(
      alignment: Alignment.centerLeft,
      child: s >= 8 ? AppBadge.danger(label: '$s / 10') : AppBadge(label: '$s / 10'),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({required this.title, required this.items, this.emptyText});

  final String title;
  final List<String> items;
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: title,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: items.isEmpty
            ? Text(emptyText ?? 'Not mentioned', style: context.type.p.copyWith(color: context.tokens.mutedForeground))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [for (final i in items) Text('• $i', style: context.type.p)],
              ),
      ),
    );
  }
}

class _Transcript extends StatelessWidget {
  const _Transcript({required this.lines});

  final List<TranscriptLine> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final l in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: l.speaker == TranscriptSpeaker.worker ? 'Worker: ' : 'Assistant: ',
                    style: context.type.small,
                  ),
                  TextSpan(text: l.text, style: context.type.p),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
