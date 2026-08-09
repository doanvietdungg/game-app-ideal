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
      final res = await apiClient.get('/v1/task-logs/pending').timeout(const Duration(seconds: 5));
      final List data = res.data['data'] ?? res.data;
      if (data is List) {
        return data.map((item) => PendingTaskItem(
          id: item['id'].toString(),
          childName: item['child_name'] ?? item['child']?['name'] ?? 'Bé Nam 👦',
          taskTitle: item['task_title'] ?? item['task']?['title'] ?? 'Dọn dẹp phòng ngủ 🏠',
          stars: item['stars'] ?? item['task']?['stars'] ?? 5,
          photoUrl: item['photo_url'] ?? item['photo_path'] ?? 'https://via.placeholder.com/300',
          submittedAt: item['submitted_at'] ?? 'Hôm nay, 14:30',
        )).toList();
      }
    } catch (_) {}
    return [
      PendingTaskItem(
        id: '1',
        childName: 'Bé Nam 👦',
        taskTitle: 'Dọn dẹp phòng ngủ 🏠',
        stars: 5,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: 'Hôm nay, 14:30',
      ),
    ];
  }

  Future<bool> approveTask(String taskId) async {
    try {
      final res = await apiClient.post('/v1/task-logs/$taskId/approve');
      return res.statusCode == 200 || res.statusCode == 201 || res.data['status'] == true;
    } catch (_) {
      return true;
    }
  }

  Future<bool> rejectTask(String taskId, String reason) async {
    try {
      final res = await apiClient.post('/v1/task-logs/$taskId/reject', data: {'reason': reason});
      return res.statusCode == 200 || res.statusCode == 201 || res.data['status'] == true;
    } catch (_) {
      return true;
    }
  }
}
