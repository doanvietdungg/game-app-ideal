import '../../../core/api/api_client.dart';

class PraiseItem {
  final String id;
  final String taskTitle;
  final String photoUrl;
  final int starsEarned;
  final String stickerEmoji;
  final String stickerText;
  final String parentComment;
  final String completedAt;

  PraiseItem({
    required this.id,
    required this.taskTitle,
    required this.photoUrl,
    required this.starsEarned,
    required this.stickerEmoji,
    required this.stickerText,
    required this.parentComment,
    required this.completedAt,
  });
}

class GalleryRepository {
  final ApiClient apiClient;
  GalleryRepository(this.apiClient);

  Future<List<PraiseItem>> getPraiseItems() async {
    try {
      final res = await apiClient.get('/gallery/praises').timeout(const Duration(milliseconds: 50));
      if (res.data is List) {
        return (res.data as List).map((item) => PraiseItem(
          id: item['id'].toString(),
          taskTitle: item['task_title'] ?? '',
          photoUrl: item['photo_url'] ?? '',
          starsEarned: item['stars_earned'] ?? 5,
          stickerEmoji: item['sticker_emoji'] ?? '🌟',
          stickerText: item['sticker_text'] ?? 'Xuất sắc!',
          parentComment: item['parent_comment'] ?? '',
          completedAt: item['completed_at'] ?? 'Hôm nay',
        )).toList();
      }
    } catch (_) {}
    return [
      PraiseItem(
        id: '1',
        taskTitle: 'Dọn dẹp phòng ngủ 🏠',
        photoUrl: 'https://via.placeholder.com/300',
        starsEarned: 5,
        stickerEmoji: '🌟',
        stickerText: 'Xuất sắc!',
        parentComment: 'Phòng con gọn gàng và ngăn nắp lắm!',
        completedAt: 'Hôm nay, 14:30',
      ),
      PraiseItem(
        id: '2',
        taskTitle: 'Đọc sách 20 phút 📚',
        photoUrl: 'https://via.placeholder.com/300',
        starsEarned: 10,
        stickerEmoji: '🎓',
        stickerText: 'Siêu chăm chỉ!',
        parentComment: 'Con đọc sách rất tập trung, bố mẹ tự hào về con!',
        completedAt: 'Hôm qua, 19:00',
      ),
    ];
  }
}
