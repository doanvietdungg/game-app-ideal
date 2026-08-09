import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('KidTimeApp mounts and displays splash screen subtitle', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KidTimeApp());

    // Verify that our splash screen subtitle is displayed.
    expect(find.text('Nhiệm vụ nhỏ · Niềm vui to'), findsOneWidget);

    // Let the redirection timer run and settle before finishing the test.
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });

  testWidgets('HomeScreen mounts and displays child stats and pet details', (WidgetTester tester) async {
    // Build the HomeScreen directly in a MaterialApp wrapper
    await tester.pumpWidget(const MaterialApp(
      home: HomeScreen(),
    ));

    // Verify child welcome message
    expect(find.text('Xin chào, Nam! 👋'), findsOneWidget);

    // Verify stats
    expect(find.text('12 ngày'), findsOneWidget);
    expect(find.text('45 Sao'), findsOneWidget);

    // Verify virtual pet status
    expect(find.text('Mimi đang vui vẻ 😊'), findsOneWidget);

    // Verify quick action button labels
    expect(find.text('Đổi quà'), findsOneWidget);
    expect(find.text('Tủ đồ'), findsOneWidget);
  });
}
