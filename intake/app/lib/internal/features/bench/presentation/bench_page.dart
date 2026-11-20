import 'package:flutter/widgets.dart';
import 'package:intake/shared/ui/ui.dart';

/// The live Chrome bench (block 6). Internal; demo build only.
class BenchPage extends StatelessWidget {
  const BenchPage({super.key, required this.startLine});

  /// 1-based, already clamped to the script.
  final int startLine;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Bench, line $startLine', style: context.type.h3));
  }
}
