import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../data/notification_repository.dart';

class NotificationCenterScreen extends StatefulWidget {
  final ApiClient? apiClient;
  const NotificationCenterScreen({super.key, this.apiClient});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  late final NotificationRepository _repository;
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = NotificationRepository(widget.apiClient ?? ApiClient());
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final items = await _repository.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = items;
        _isLoading = false;
      });
    }
  }

  Widget _getIconForType(String type) {
    switch (type) {
      case 'approval':
        return const Text('🎉', style: TextStyle(fontSize: 24));
      case 'star_reward':
        return const Text('⭐', style: TextStyle(fontSize: 24));
      case 'pet_hunger':
        return const Text('🍖', style: TextStyle(fontSize: 24));
      default:
        return const Text('🔔', style: TextStyle(fontSize: 24));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Thông Báo 🔔'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text('Chưa có thông báo nào.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final item = _notifications[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: item.isRead ? Colors.white : Colors.amber.shade50,
                      elevation: item.isRead ? 1 : 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: _getIconForType(item.type),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: item.isRead ? FontWeight.bold : FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.body, style: const TextStyle(color: Colors.black87)),
                              const SizedBox(height: 6),
                              Text(item.createdAt, style: const TextStyle(color: Colors.black45, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
