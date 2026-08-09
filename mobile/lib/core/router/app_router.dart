import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/role_selection_screen.dart';
import '../../features/auth/presentation/parent_login_screen.dart';
import '../../features/auth/presentation/child_login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/tasks/presentation/task_list_screen.dart';
import '../../features/tasks/presentation/task_detail_screen.dart';
import '../../features/pet/presentation/pet_screen.dart';
import '../../features/pet/presentation/store_screen.dart';
import '../../features/rewards/presentation/reward_list_screen.dart';
import '../../features/stats/presentation/stats_screen.dart';
import '../../features/parent/presentation/parent_approval_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/login-parent',
      builder: (context, state) => const ParentLoginScreen(),
    ),
    GoRoute(
      path: '/login-child',
      builder: (context, state) => const ChildLoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/tasks',
      builder: (context, state) => const TaskListScreen(),
    ),
    GoRoute(
      path: '/tasks/:id',
      builder: (context, state) {
        final taskId = int.parse(state.pathParameters['id']!);
        final taskData = state.extra as Map<String, dynamic>;
        return TaskDetailScreen(taskId: taskId, taskData: taskData);
      },
    ),
    GoRoute(
      path: '/pet',
      builder: (context, state) => const PetScreen(),
    ),
    GoRoute(
      path: '/store',
      builder: (context, state) => const StoreScreen(),
    ),
    GoRoute(
      path: '/rewards',
      builder: (context, state) => const RewardListScreen(),
    ),
    GoRoute(
      path: '/stats',
      builder: (context, state) => const StatsScreen(),
    ),
    GoRoute(
      path: '/parent/approval',
      builder: (context, state) => const ParentApprovalScreen(),
    ),
  ],
);



