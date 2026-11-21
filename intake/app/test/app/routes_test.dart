import 'package:flutter_test/flutter_test.dart';
import 'package:intake/internal/routes.dart';
import 'package:intake/physician/features/case_review/presentation/review_page.dart';
import 'package:intake/physician/routes.dart';
import 'package:intake/worker/routes.dart';

import '../helpers/pump_app.dart';

Future<void> pumpAt(WidgetTester tester, String location) => pumpApp(tester, location: location);

void main() {
  group('route locations', () {
    test('every route class builds its path', () {
      expect(const WorkerRoute().location, '/worker');
      expect(const ReviewRoute().location, '/physician');
      expect(const CaseRoute(caseId: 'c_1').location, '/physician/cases/c_1');
      expect(const BenchRoute(line: 7).location, '/bench?line=7');
      expect(const BenchRoute().location, '/bench');
    });

    test('bench line clamps to the script', () {
      expect(const BenchRoute().startLine, 1);
      expect(const BenchRoute(line: 99).startLine, benchLineCount);
      expect(const BenchRoute(line: 0).startLine, 1);
    });
  });

  group('router', () {
    testWidgets('/ redirects to the worker side', (tester) async {
      await pumpAt(tester, '/');
      expect(find.text('Start listening'), findsNothing); // label is semantic only
      expect(find.text('Tap the mic and speak'), findsOneWidget);
      expect(find.text("Demo, don't enter real health information."), findsOneWidget);
    });

    testWidgets('a case link parses back to the case', (tester) async {
      await pumpAt(tester, const CaseRoute(caseId: 'c_1').location);
      final page = tester.widget<ReviewPage>(find.byType(ReviewPage));
      expect(page.caseId, 'c_1');
    });

    testWidgets('/bench?line=abc falls back to line 1', (tester) async {
      await pumpAt(tester, '/bench?line=abc');
      expect(find.text('Line 1 of 21 · 0 read'), findsOneWidget);
    });

    testWidgets('/bench?line=99 opens the last line', (tester) async {
      await pumpAt(tester, '/bench?line=99');
      expect(find.text('Line $benchLineCount of 21 · 0 read'), findsOneWidget);
    });

    testWidgets('an unknown path shows the error page', (tester) async {
      await pumpAt(tester, '/nope');
      expect(find.text('Page not found'), findsOneWidget);
    });

    testWidgets('the switch moves between sides', (tester) async {
      await pumpAt(tester, '/worker');
      await tester.tap(find.text('Physician').first);
      await tester.pumpAndSettle();
      expect(find.text('No intake waiting for review'), findsOneWidget);
    });
  });
}
