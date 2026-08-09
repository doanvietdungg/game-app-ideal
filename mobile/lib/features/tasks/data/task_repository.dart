import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';

class TaskRepository {
  final ApiClient _apiClient;
  TaskRepository(this._apiClient);

  Future<List<Map<String, dynamic>>> getTodayTasks(int childId) async {
    try {
      final res = await _apiClient.get('/v1/children/$childId/tasks/today');
      return List<Map<String, dynamic>>.from(res.data['data']);
    } catch (e) {
      return [];
    }
  }

  Future<bool> submitTask(int taskId, int childId, {String? filePath}) async {
    try {
      final formData = FormData.fromMap({
        'task_id': taskId,
        'child_id': childId,
        if (filePath != null)
          'photo': await MultipartFile.fromFile(filePath, filename: 'proof.jpg'),
      });

      final res = await _apiClient.post('/v1/task-logs', data: formData);
      return res.data['status'] == true || res.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
