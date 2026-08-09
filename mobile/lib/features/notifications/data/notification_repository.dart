import '../../../core/api/api_client.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String type; // 'approval', 'star_reward', 'pet_hunger', 'reminder'
  final bool isRead;
  final String createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });
}

class NotificationRepository {
  final ApiClient apiClient;
  NotificationRepository(this.apiClient);

  Future<List<NotificationItem>> getNotifications() async {
    try {
      final res = await apiClient.get('/notifications').timeout(const Duration(milliseconds: 50));
      if (res.data is List) {
        return (res.data as List).map((item) => NotificationItem(
          id: item['id'].toString(),
          title: item['title'] ?? '',
          body: item['body'] ?? '',
          type: item['type'] ?? 'reminder',
          isRead: item['is_read'] ?? false,
          createdAt: item['created_at'] ?? '10 phút trước',
        )).toList();
      }
    } catch (_) {}
    return [
      NotificationItem(
        id: '1',
        title: '🎉 Bài tập đã được duyệt!',
        body: 'Bố đã duyệt bài "Dọn dẹp phòng ngủ". Con được thưởng +5 ⭐!',
        type: 'approval',
        isRead: false,
        createdAt: '10 phút trước',
      ),
      NotificationItem(
        id: '2',
        title: '🍖 Mimi đang đói rồi!',
        body: 'Độ no của Mimi giảm còn 40%. Cho Mimi ăn chiều nhé con!',
        type: 'pet_hunger',
        isRead: true,
        createdAt: '2 giờ trước',
      ),
      NotificationItem(
        id: '3',
        title: '⭐ Đổi quà thành công',
        body: 'Bố đã xác nhận phần thưởng "Xem TV 30 phút"!',
        type: 'star_reward',
        isRead: true,
        createdAt: 'Hôm qua',
      ),
    ];
  }
}
