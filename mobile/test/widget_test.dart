import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('KidTimeApp mounts and displays splash screen subtitle', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KidTimeApp());

    // Verify that our splash screen subtitle is displayed.
    expect(find.text('Nhiệm vụ nhỏ · Niềm vui to'), findsOneWidget);

    // Let the redirection timer run and settle before finishing the test.
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
