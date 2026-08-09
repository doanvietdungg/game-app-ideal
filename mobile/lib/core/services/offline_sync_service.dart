class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  final List<Map<String, dynamic>> _pendingQueue = [];

  void queueSubmission(Map<String, dynamic> data) {
    _pendingQueue.add(data);
  }

  Future<int> syncPendingSubmissions() async {
    final count = _pendingQueue.length;
    _pendingQueue.clear();
    return count;
  }

  int get pendingCount => _pendingQueue.length;
}
