import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = false;

  final List<Map<String, String>> _categories = [
    {'key': 'all', 'label': 'Tất cả'},
    {'key': 'housework', 'label': '🏠 Việc nhà'},
    {'key': 'study', 'label': '📚 Học tập'},
    {'key': 'exercise', 'label': '🏃 Vận động'},
    {'key': 'eating', 'label': '🥦 Ăn uống'},
    {'key': 'sleep', 'label': '😴 Giấc ngủ'},
  ];

  // Mocked data for layout rendering fallback
  final List<Map<String, dynamic>> _mockTasks = [
    {
      'id': 1,
      'title': 'Dọn dẹp phòng ngủ 🏠',
      'stars': 5,
      'category': 'housework',
      'status': 'submitted',
      'emoji': '🏠',
      'desc': 'Hãy xếp gọn đồ chơi và gấp chăn màn ngăn nắp con nhé!'
    },
    {
      'id': 2,
      'title': 'Đọc sách 20 phút 📚',
      'stars': 10,
      'category': 'study',
      'status': 'todo',
      'emoji': '📚',
      'desc': 'Đọc tập trung 20 phút sách truyện con yêu thích.'
    },
    {
      'id': 3,
      'title': 'Tập thể dục buổi sáng 🏃',
      'stars': 5,
      'category': 'exercise',
      'status': 'approved',
      'emoji': '🏃',
      'desc': 'Chạy nhảy và tập các động tác vươn thở buổi sáng.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tasks = List.from(_mockTasks);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredTasks(String categoryKey) {
    if (categoryKey == 'all') return _tasks;
    return _tasks.where((t) => t['category'] == categoryKey).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          '📋 Nhiệm vụ của con',
          style: TextStyle(color: AppTheme.text, fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.text),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textLight,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: _categories.map((c) => Tab(text: c['label'])).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _categories.map((c) {
          final tasks = _getFilteredTasks(c['key']!);
          return _buildTaskListView(tasks);
        }).toList(),
      ),
    );
  }

  Widget _buildTaskListView(List<Map<String, dynamic>> tasks) {
    if (tasks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🎉', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text(
              'Con đã hoàn thành hết rồi!',
              style: TextStyle(
                color: AppTheme.textLight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task);
      },
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigate to task detail (Sprint 2)
          context.push('/tasks/${task['id']}', extra: task);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(task['emoji'], style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task['title'],
                      style: const TextStyle(
                        color: AppTheme.text,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+${task['stars']} Sao',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(task['status']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'submitted':
        color = Colors.orange;
        text = 'Chờ duyệt';
        break;
      case 'approved':
        color = AppTheme.secondary;
        text = 'Đã duyệt';
        break;
      default:
        color = AppTheme.textLight;
        text = 'Chưa làm';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color == AppTheme.secondary ? const Color(0xFF55B380) : color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
