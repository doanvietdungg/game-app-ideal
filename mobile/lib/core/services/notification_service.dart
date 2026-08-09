import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    // Scaffold for push notifications & local scheduler initialization
  }

  Future<void> scheduleDailyTaskReminder() async {
    // Schedule 08:00 morning task check notification
  }

  Future<void> schedulePetFeedingReminder() async {
    // Schedule 17:00 afternoon pet feeding notification
  }

  void parseFcmPayload(Map<String, dynamic> payload, BuildContext context) {
    final title = payload['title'] ?? 'KidTime Thông báo';
    final body = payload['body'] ?? '';
    final route = payload['route'];

    // In-app alert handling
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title: $body'),
        action: route != null
            ? SnackBarAction(label: 'Xem', onPressed: () {})
            : null,
      ),
    );
  }
}
