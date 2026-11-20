import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:intake/shared/ui/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class IntakeApp extends StatelessWidget {
  const IntakeApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return ShadApp.router(
      title: 'Voice intake (demo)',
      routerConfig: router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      supportedLocales: const [Locale('en', 'US'), Locale('es', 'US')],
    );
  }
}
