import 'package:flutter_test/flutter_test.dart';
import 'package:teacher_assistant_app/main.dart';

void main() {
  testWidgets('Teacher Assistant App loads dashboard successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const TeacherAssistantApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify app bar title
    expect(find.text('Thalir'), findsOneWidget);

    // Verify Teacher greeting
    expect(find.textContaining('Ananya'), findsOneWidget);

    // Verify Class VIII-A
    expect(find.textContaining('Class VIII-A'), findsAtLeastNWidgets(1));

    // Verify Quick Actions
    expect(find.text('Scan Attendance'), findsOneWidget);
    expect(find.text('Scan Test Marks'), findsOneWidget);
    expect(find.text('Log Risk Signal'), findsOneWidget);
  });
}
