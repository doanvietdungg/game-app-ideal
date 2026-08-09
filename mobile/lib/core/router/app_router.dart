import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('KidTime Splash', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
      ),
    ),
    GoRoute(
      path: '/role-selection',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Chọn vai trò', style: TextStyle(fontSize: 20)),
        ),
      ),
    ),
    GoRoute(
      path: '/login-parent',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Đăng nhập Phụ huynh', style: TextStyle(fontSize: 20)),
        ),
      ),
    ),
    GoRoute(
      path: '/login-child',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Đăng nhập Bé', style: TextStyle(fontSize: 20)),
        ),
      ),
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
