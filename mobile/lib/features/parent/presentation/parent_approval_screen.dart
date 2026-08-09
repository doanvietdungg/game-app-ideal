import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../data/parent_repository.dart';

class ParentApprovalScreen extends StatefulWidget {
  final ApiClient? apiClient;
  const ParentApprovalScreen({super.key, this.apiClient});

  @override
  State<ParentApprovalScreen> createState() => _ParentApprovalScreenState();
}

class _ParentApprovalScreenState extends State<ParentApprovalScreen> {
  late final ParentRepository _repository;
  List<PendingTaskItem> _pendingTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = ParentRepository(widget.apiClient ?? ApiClient());
    _loadPendingTasks();
  }

  Future<void> _loadPendingTasks() async {
    setState(() => _isLoading = true);
    final items = await _repository.getPendingTasks();
    if (mounted) {
      setState(() {
        _pendingTasks = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleApprove(PendingTaskItem task) async {
    final success = await _repository.approveTask(task.id);
    if (mounted && success) {
      setState(() {
        _pendingTasks.removeWhere((item) => item.id == task.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã duyệt nhiệm vụ "${task.taskTitle}"! +${task.stars}⭐ cho bé! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleReject(PendingTaskItem task) async {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yêu cầu làm lại ✍️'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Nhập lý do (ví dụ: Ảnh chụp chưa rõ)',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await _repository.rejectTask(task.id, reasonController.text);
              if (mounted && success) {
                setState(() {
                  _pendingTasks.removeWhere((item) => item.id == task.id);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã gửi yêu cầu làm lại cho bé! 📝')),
                );
              }
            },
            child: const Text('Gửi yêu cầu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Phụ Huynh — Duyệt Bài 👨‍👩‍👧'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.go('/role-selection'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingTasks.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 64, color: Colors.green),
                      SizedBox(height: 12),
                      Text('Tuyệt vời! Không còn bài nào chờ duyệt.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingTasks.length,
                  itemBuilder: (context, index) {
                    final item = _pendingTasks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item.childName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(item.submittedAt, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(item.taskTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('+${item.stars} ⭐ khi hoàn thành', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _handleReject(item),
                                    icon: const Icon(Icons.close_rounded, color: Colors.red),
                                    label: const Text('Làm lại', style: TextStyle(color: Colors.red)),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.red),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _handleApprove(item),
                                    icon: const Icon(Icons.check_rounded, color: Colors.white),
                                    label: const Text('Duyệt bài'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
