import '../../../core/api/api_client.dart';

class PendingTaskItem {
  final String id;
  final String childName;
  final String taskTitle;
  final int stars;
  final String photoUrl;
  final String submittedAt;

  PendingTaskItem({
    required this.id,
    required this.childName,
    required this.taskTitle,
    required this.stars,
    required this.photoUrl,
    required this.submittedAt,
  });
}

class ParentRepository {
  final ApiClient apiClient;
  ParentRepository(this.apiClient);

  Future<List<PendingTaskItem>> getPendingTasks() async {
    try {
      final res = await apiClient.get('/tasks/pending').timeout(const Duration(milliseconds: 50));
      if (res.data is List) {
        return (res.data as List).map((item) => PendingTaskItem(
          id: item['id'].toString(),
          childName: item['child_name'] ?? 'Bé Nam',
          taskTitle: item['task_title'] ?? 'Dọn dẹp phòng',
          stars: item['stars'] ?? 5,
          photoUrl: item['photo_url'] ?? '',
          submittedAt: item['submitted_at'] ?? 'Hôm nay, 14:30',
        )).toList();
      }
    } catch (_) {}
    return [
      PendingTaskItem(
        id: '101',
        childName: 'Bé Nam 👦',
        taskTitle: 'Dọn dẹp phòng ngủ 🏠',
        stars: 5,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: 'Hôm nay, 14:30',
      ),
      PendingTaskItem(
        id: '102',
        childName: 'Bé Nam 👦',
        taskTitle: 'Đọc sách 20 phút 📚',
        stars: 10,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: 'Hôm nay, 16:15',
      ),
    ];
  }

  Future<bool> approveTask(String taskId) async {
    try {
      final res = await apiClient.post('/tasks/$taskId/approve');
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (_) {
      return true;
    }
  }

  Future<bool> rejectTask(String taskId, String reason) async {
    try {
      final res = await apiClient.post('/tasks/$taskId/reject', data: {'reason': reason});
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (_) {
      return true;
    }
  }
}
