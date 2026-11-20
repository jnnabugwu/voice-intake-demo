import 'package:flutter/widgets.dart';
import 'package:intake/shared/ui/ui.dart';

/// The physician's review of one case. [caseId] null means the current case.
class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key, this.caseId});

  final String? caseId;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Physician', style: context.type.h3));
  }
}
