import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intake/app/app_mode.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The chrome around both sides: the demo notice and, in the demo build, the
/// "Viewing as: Worker | Physician" switch. In production the switch goes
/// and the signed-in role picks the side.
class SideShell extends StatelessWidget {
  const SideShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final mode = context.read<AppMode>();
    return ColoredBox(
      color: theme.colorScheme.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.colorScheme.border)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Text('Viewing as:', style: theme.textTheme.small),
                    for (final (i, label, icon) in [
                      (0, 'Worker', LucideIcons.mic),
                      (1, 'Physician', LucideIcons.stethoscope),
                    ])
                      Semantics(
                        selected: shell.currentIndex == i,
                        child: shell.currentIndex == i
                            ? ShadButton.secondary(
                                height: 48,
                                leading: Icon(icon, size: 16),
                                onPressed: () => shell.goBranch(i),
                                child: Text(label),
                              )
                            : ShadButton.ghost(
                                height: 48,
                                leading: Icon(icon, size: 16),
                                onPressed: () => shell.goBranch(i, initialLocation: true),
                                child: Text(label),
                              ),
                      ),
                    const SizedBox(width: 8),
                    _DemoNotice(mode: mode),
                  ],
                ),
              ),
            ),
            Expanded(child: shell),
          ],
        ),
      ),
    );
  }
}

class _DemoNotice extends StatelessWidget {
  const _DemoNotice({required this.mode});

  final AppMode mode;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        switch (mode) {
          AppMode.demo => const ShadBadge.secondary(child: Text('Demo')),
          AppMode.live => const ShadBadge(child: Text('Live')),
        },
        Text("Demo, don't enter real health information.", style: theme.textTheme.small),
        Text('Best in Chrome on a laptop.', style: theme.textTheme.muted),
      ],
    );
  }
}
