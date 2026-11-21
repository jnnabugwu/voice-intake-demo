import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intake/internal/features/bench/presentation/bench_bloc.dart';
import 'package:intake/shared/ui/ui.dart';

/// Internal: Jordan reads each line aloud in Chrome; the page records what
/// Web Speech heard and when, then exports the session for `npm run bench`.
class BenchPage extends StatelessWidget {
  const BenchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BenchBloc>().state;
    final bloc = context.read<BenchBloc>();
    final script = state.script;
    final tokens = context.tokens;
    return ColoredBox(
      color: tokens.background,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Speech bench (internal)', style: context.type.h3),
              const SizedBox(height: 4),
              Text(
                'Read each line as written, then stop. Export when done and save the file to bench/chrome/.',
                style: context.type.muted,
              ),
              const SizedBox(height: 16),
              if (state.error != null) ...[AppAlert.danger(title: state.error!), const SizedBox(height: 12)],
              if (script == null)
                const SizedBox.shrink()
              else ...[
                AppSegmented<int>(
                  semanticLabel: 'Speaker',
                  enabled: !state.listening,
                  selected: state.speakerIndex,
                  onChanged: (i) => bloc.add(BenchSpeakerChanged(i)),
                  options: [for (final (i, s) in script.speakers.indexed) (i, s.id)],
                ),
                const SizedBox(height: 12),
                AppProgress(value: (state.index + 1) / script.lines.length),
                const SizedBox(height: 4),
                Text(
                  'Line ${state.index + 1} of ${script.lines.length} · ${state.takes.length} read',
                  style: context.type.small,
                ),
                const SizedBox(height: 12),
                AppCard(child: Text(state.lineText ?? '', style: context.type.large)),
                const SizedBox(height: 16),
                Center(
                  child: AppIconButton(
                    icon: state.listening ? LucideIcons.square : LucideIcons.mic,
                    semanticLabel: state.listening ? 'Stop reading' : 'Start reading',
                    highlighted: state.listening,
                    onPressed: () => bloc.add(state.listening ? const BenchReadStopped() : const BenchReadStarted()),
                  ),
                ),
                const SizedBox(height: 12),
                if (state.listening)
                  Text(
                    state.partial.isEmpty ? 'Listening…' : state.partial,
                    style: context.type.muted,
                    textAlign: TextAlign.center,
                  )
                else if (state.takes[state.line?.n] case final take?)
                  AppCard(
                    title: 'Heard',
                    description:
                        'first word ${_ms(take.firstPartialMs, take.micOnMs)} · final ${_ms(take.finalMs, take.micOnMs)} after mic on',
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(take.transcript, style: context.type.p),
                    ),
                  ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    AppButton.secondary(
                      label: 'Previous',
                      icon: LucideIcons.chevronLeft,
                      onPressed: state.listening || state.index == 0 ? null : () => bloc.add(const BenchLineMoved(-1)),
                    ),
                    AppButton.secondary(
                      label: 'Next',
                      icon: LucideIcons.chevronRight,
                      onPressed: state.listening || state.index == script.lines.length - 1
                          ? null
                          : () => bloc.add(const BenchLineMoved(1)),
                    ),
                    AppButton.outline(
                      label: 'Export JSON',
                      icon: LucideIcons.download,
                      onPressed: state.takes.isEmpty || state.listening
                          ? null
                          : () => bloc.add(const BenchExportRequested()),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _ms(int? at, int from) => at == null ? 'n/a' : '${((at - from) / 1000).toStringAsFixed(2)} s';
}
