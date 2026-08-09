import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/role_selection_screen.dart';
import '../../features/auth/presentation/parent_login_screen.dart';
import '../../features/auth/presentation/child_login_screen.dart';

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
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Màn hình chính của Bé', style: TextStyle(fontSize: 20)),
        ),
      ),
    ),
  ],
);
