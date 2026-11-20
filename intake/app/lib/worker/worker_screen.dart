import 'package:flutter/widgets.dart';
import 'package:intake/shared/ui/ui.dart';

/// The worker's one page: mic, chat, next step and escalation card.
/// Composes this side's features; filled in by blocks 1–4.
class WorkerScreen extends StatelessWidget {
  const WorkerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Worker', style: context.type.h3));
  }
}
