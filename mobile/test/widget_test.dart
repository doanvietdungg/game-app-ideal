import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/features/home/presentation/home_screen.dart';
import 'package:mobile/features/tasks/presentation/task_list_screen.dart';
import 'package:mobile/features/tasks/presentation/task_detail_screen.dart';

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
  });

  testWidgets('TaskListScreen mounts and displays tasks by categories', (WidgetTester tester) async {
    // Build the TaskListScreen directly in a MaterialApp wrapper
    await tester.pumpWidget(const MaterialApp(
      home: TaskListScreen(),
    ));

    // Verify app bar title
    expect(find.text('📋 Nhiệm vụ của con'), findsOneWidget);

    // Verify category tabs are present
    expect(find.text('Tất cả'), findsOneWidget);
    expect(find.text('🏠 Việc nhà'), findsOneWidget);
  });

  testWidgets('TaskDetailScreen mounts and displays task information for Photo task', (WidgetTester tester) async {
    final mockTaskData = {
      'id': 1,
      'title': 'Dọn dẹp phòng ngủ',
      'stars': 5,
      'category': 'housework',
      'emoji': '🏠',
      'desc': 'Hãy dọn đồ chơi gọn gàng vào hộp con nhé!'
    };

    // Build the TaskDetailScreen
    await tester.pumpWidget(MaterialApp(
      home: TaskDetailScreen(taskId: 1, taskData: mockTaskData),
    ));

    // Verify task details
    expect(find.text('Dọn dẹp phòng ngủ'), findsOneWidget);
    expect(find.text('+5 Sao ⭐'), findsOneWidget);
    expect(find.text('Ảnh chụp'), findsOneWidget);
    expect(find.text('Chụp ảnh kết quả của con'), findsOneWidget);
  });

  testWidgets('TaskDetailScreen mounts and displays task information for PIN task', (WidgetTester tester) async {
    final mockTaskData = {
      'id': 2,
      'title': 'Đọc sách 20 phút',
      'stars': 10,
      'category': 'study',
      'emoji': '📚',
      'desc': 'Đọc cuốn sách con thích nhất.'
    };

    // Build the TaskDetailScreen
    await tester.pumpWidget(MaterialApp(
      home: TaskDetailScreen(taskId: 2, taskData: mockTaskData),
    ));

    // Verify task details
    expect(find.text('Đọc sách 20 phút'), findsOneWidget);
    expect(find.text('+10 Sao ⭐'), findsOneWidget);
    expect(find.text('Mã PIN'), findsOneWidget);
    expect(find.text('Yêu cầu Bố mẹ xác nhận'), findsOneWidget);
  });
}
