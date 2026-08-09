import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('KidTimeApp mounts and displays splash screen text', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KidTimeApp());

    // Verify that our splash screen is displayed.
    expect(find.text('KidTime Splash'), findsOneWidget);
  });
}
