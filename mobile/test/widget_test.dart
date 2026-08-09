import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/features/home/presentation/home_screen.dart';
import 'package:mobile/features/tasks/presentation/task_list_screen.dart';
import 'package:mobile/features/tasks/presentation/task_detail_screen.dart';
import 'package:mobile/features/pet/presentation/pet_screen.dart';
import 'package:mobile/features/pet/presentation/widgets/draggable_food.dart';
import 'package:mobile/features/pet/presentation/store_screen.dart';
import 'package:mobile/features/rewards/presentation/reward_list_screen.dart';
import 'package:mobile/features/stats/presentation/stats_screen.dart';
import 'package:mobile/features/parent/presentation/parent_approval_screen.dart';
import 'package:mobile/features/notifications/presentation/notification_center_screen.dart';
import 'package:mobile/core/services/app_blocking_service.dart';

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

    await tester.pump(const Duration(milliseconds: 100));

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

  testWidgets('PetScreen mounts and supports interactive feeding and tickling', (WidgetTester tester) async {
    // Build the PetScreen
    await tester.pumpWidget(const MaterialApp(
      home: PetScreen(),
    ));

    // Verify title and initial stars
    expect(find.text('🐾 Thú cưng ảo'), findsOneWidget);
    expect(find.text('45 Sao'), findsOneWidget);
    expect(find.text('Mimi đang vui vẻ 😊'), findsOneWidget);

    // Verify progress bars
    expect(find.text('🍖 Độ no nê'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);

    // Tap cho ăn (feeding costs 2 stars)
    await tester.ensureVisible(find.text('Cho ăn (-2 ⭐)'));
    await tester.tap(find.text('Cho ăn (-2 ⭐)'));
    await tester.pump();

    // Verify stats changed
    expect(find.text('43 Sao'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('Mimi ăn ngon miệng lắm! 🍖'), findsOneWidget);

    // Tap chọc nhột (tickle)
    await tester.ensureVisible(find.text('Chọc nhột'));
    await tester.tap(find.text('Chọc nhột'));
    await tester.pump();

    // Verify response changed
    expect(find.text('Hahaha, nhột quá chủ nhân ơi! 😂'), findsOneWidget);

    // Settle all delayed expressions timers
    await tester.pump(const Duration(seconds: 2));
  });


  testWidgets('StoreScreen mounts and supports unlocking premium skins', (WidgetTester tester) async {
    // Build the StoreScreen
    await tester.pumpWidget(const MaterialApp(
      home: StoreScreen(),
    ));

    // Verify app bar title
    expect(find.text('🛍️ Cửa hàng & Tủ đồ'), findsOneWidget);
    expect(find.text('45 Sao'), findsOneWidget);

    // Verify available premium skins in store
    expect(find.text('Mèo Robot 🤖'), findsOneWidget);
    expect(find.text('Mèo Ninja 🥷'), findsOneWidget);

    // Verify cost buttons
    expect(find.text('15'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);

    // Unlock Mèo Robot (costs 15 stars)
    await tester.tap(find.byIcon(Icons.star_rounded).first);
    await tester.pump();

    // Verify stars deducted to 30
    expect(find.text('30 Sao'), findsOneWidget);
  });

  testWidgets('RewardListScreen mounts and displays rewards', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: RewardListScreen(),
    ));

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Cửa Hàng Đổi Quà 🎁'), findsOneWidget);
    expect(find.text('35 sao'), findsOneWidget);
    expect(find.text('Xem TV 30 phút 📺'), findsOneWidget);
  });

  testWidgets('StatsScreen mounts and displays streak and chart', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: StatsScreen(),
    ));

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Báo Cáo & Streak 🔥'), findsOneWidget);
    expect(find.text('🔥 STREAK LIÊN TỤC'), findsOneWidget);
    expect(find.text('5 Ngày'), findsOneWidget);
  });

  testWidgets('ParentApprovalScreen mounts and displays pending tasks', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ParentApprovalScreen(),
    ));

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Phụ Huynh — Duyệt Bài 👨‍👩‍👧'), findsOneWidget);
    expect(find.text('Dọn dẹp phòng ngủ 🏠'), findsOneWidget);
    expect(find.text('Duyệt bài'), findsWidgets);
  });

  testWidgets('NotificationCenterScreen mounts and displays notifications', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: NotificationCenterScreen(),
    ));

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Thông Báo 🔔'), findsOneWidget);
    expect(find.text('🎉 Bài tập đã được duyệt!'), findsOneWidget);
  });

  test('AppBlockingService handles missing plugin gracefully in test env', () async {
    final service = AppBlockingService();
    final result = await service.syncBlockedApps(['com.example.game']);
    expect(result, true);
  });
}
