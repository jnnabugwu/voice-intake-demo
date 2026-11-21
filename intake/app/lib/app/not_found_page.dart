import 'package:flutter/widgets.dart';
import 'package:intake/shared/ui/ui.dart';
import 'package:intake/worker/routes.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.tokens.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Page not found', style: context.type.h3),
            const SizedBox(height: 16),
            AppButton.primary(label: 'Go to the intake', onPressed: () => const WorkerRoute().go(context)),
          ],
        ),
      ),
    );
  }
}
