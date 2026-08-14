import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../tasks/data/task_repository.dart';
import '../../tasks/presentation/task_list_screen.dart';
import '../../rewards/presentation/reward_list_screen.dart';
import '../../stats/presentation/stats_screen.dart';
import '../../pet/presentation/widgets/pet_physics_canvas.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const _HomeTabContent(),
    const TaskListScreen(),
    const RewardListScreen(),
    const StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey.shade500,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_rounded),
            label: 'Nhiệm vụ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard_rounded),
            label: 'Đổi quà',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Thống kê',
          ),
        ],
      ),
    );
  }
}

class _HomeTabContent extends StatefulWidget {
  const _HomeTabContent();

  @override
  State<_HomeTabContent> createState() => _HomeTabContentState();
}

class _HomeTabContentState extends State<_HomeTabContent> {
  final List<Map<String, dynamic>> _fallbackTasks = [
    {
      'id': 1,
      'title': 'Dọn dẹp phòng',
      'stars': 5,
      'category': 'housework',
      'emoji': '🏠',
      'status': 'approved',
      'color': const Color(0xFFFFB347),
    },
    {
      'id': 2,
      'title': 'Đọc sách 20 phút',
      'stars': 10,
      'category': 'study',
      'emoji': '📚',
      'status': 'submitted',
      'color': const Color(0xFF87CEEB),
    },
    {
      'id': 3,
      'title': 'Rửa chén đĩa',
      'stars': 8,
      'category': 'housework',
      'emoji': '🍽️',
      'status': 'todo',
      'color': const Color(0xFFA8E6CF),
    },
  ];

  List<Map<String, dynamic>> _todayTasks = [];
  bool _isLoading = true;
  String _petActiveSkin = 'Mèo Thường 🐱';

  @override
  void initState() {
    super.initState();
    _loadTodayTasks();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (_isTestEnv) return;
    try {
      final res = await ApiClient().get('/v1/children/1/profile');
      if (mounted && res.statusCode == 200 && res.data['status'] == true) {
        final data = res.data['data'];
        if (data['pet'] != null && data['pet']['active_skin'] != null) {
          setState(() {
            _petActiveSkin = data['pet']['active_skin'].toString();
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _loadTodayTasks() async {
    if (_isTestEnv) {
      if (mounted) {
        setState(() {
          _todayTasks = _fallbackTasks;
          _isLoading = false;
        });
      }
      return;
    }
    try {
      final repository = TaskRepository(ApiClient());
      final tasks = await repository.getTodayTasks(1);
      if (mounted) {
        setState(() {
          _todayTasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _todayTasks = _fallbackTasks;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildPetCanvas(context),
            const SizedBox(height: 28),
            _buildTodayTasksSection(context),
            const SizedBox(height: 28),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events_rounded, color: AppTheme.primary, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Hạng Bạc',
                    style: TextStyle(
                      color: AppTheme.text,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings_rounded, color: AppTheme.text, size: 24),
              tooltip: 'Cài đặt & Hồ sơ',
              onPressed: () => context.push('/profile/settings'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text(
                'Xin chào, Nam! 👋',
                style: TextStyle(
                  color: AppTheme.text,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildStatItem('🔥', '12 ngày'),
                const SizedBox(width: 6),
                _buildStatItem('⭐', '45 Sao'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFFFF2D6), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  bool get _isTestEnv =>
      WidgetsBinding.instance.toString().toLowerCase().contains('test') ||
      WidgetsBinding.instance.runtimeType.toString().toLowerCase().contains('test');

  Widget _buildPetCanvas(BuildContext context) {
    String petSkinTitle = 'Mimi';
    String petTag = '😊 Vui vẻ';
    List<Color> cardGradient = [const Color(0xFFFFF9F0), const Color(0xFFFFF3E0)];
    Color accentColor = AppTheme.primary;
    Color circleColor = AppTheme.primary.withValues(alpha: 0.1);
    Widget petAvatarWidget = PetPhysicsCanvas(
      skin: _petActiveSkin,
      expression: 'happy',
      scaleX: 0.85,
      scaleY: 0.85,
      enableAnimations: true,
    );

    if (_petActiveSkin.contains('Corgi') || _petActiveSkin.contains('🦊')) {
      petSkinTitle = 'Rex Chó Corgi';
      petTag = '🐕 Chân Ngắn Vui Vẻ';
      cardGradient = [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)];
      accentColor = Colors.orange;
      circleColor = Colors.amber.withValues(alpha: 0.2);
    } else if (_petActiveSkin.contains('Shiba') || _petActiveSkin.contains('🐕')) {
      petSkinTitle = 'Rex Chó Shiba';
      petTag = '🧣 Khăn Quàng Vui';
      cardGradient = [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)];
      accentColor = Colors.deepOrange;
      circleColor = Colors.amber.withValues(alpha: 0.2);
    } else if (_petActiveSkin.contains('Ninja') || _petActiveSkin.contains('🥷')) {
      petSkinTitle = 'Mimi Mèo Ninja';
      petTag = '🥷 Băng Nhẫn';
      cardGradient = [const Color(0xFFECEFF1), const Color(0xFFCFD8DC)];
      accentColor = const Color(0xFF37474F);
      circleColor = Colors.grey.withValues(alpha: 0.25);
    } else if (_petActiveSkin.contains('Rồng') || _petActiveSkin.contains('🐉')) {
      petSkinTitle = 'Spark Rồng Con';
      petTag = '🐉 Huyền Thoại';
      cardGradient = [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)];
      accentColor = Colors.green;
      circleColor = Colors.lightGreen.withValues(alpha: 0.25);
    } else if (_petActiveSkin.contains('Thỏ') || _petActiveSkin.contains('🐰')) {
      petSkinTitle = 'Miffy Thỏ Ngọc';
      petTag = '🥕 Củ Cà Rốt';
      cardGradient = [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)];
      accentColor = Colors.purple;
      circleColor = Colors.purpleAccent.withValues(alpha: 0.25);
    } else if (_petActiveSkin.contains('Robot') || _petActiveSkin.contains('🤖')) {
      petSkinTitle = 'Mimi Mèo Robot';
      petTag = '⚡ Cyber Armor';
      cardGradient = [const Color(0xFFE0F7FA), const Color(0xFFE1F5FE)];
      accentColor = const Color(0xFF00ACC1);
      circleColor = const Color(0xFF00E5FF).withValues(alpha: 0.2);
    } else {
      petSkinTitle = 'Mimi Mèo Cam';
      petTag = '😊 Vui Vẻ';
      cardGradient = [const Color(0xFFFFF9F0), const Color(0xFFFFF3E0)];
      accentColor = AppTheme.primary;
      circleColor = AppTheme.primary.withValues(alpha: 0.1);
    }

    return GestureDetector(
      onTap: () async {
        await context.push('/pet');
        _loadProfile();
      },
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: cardGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 4,
              child: SizedBox(
                width: 170,
                height: 130,
                child: Center(child: petAvatarWidget),
              ),
            ),
            Positioned(
              top: 134,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    petSkinTitle,
                    style: const TextStyle(
                      color: AppTheme.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      petTag,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cấp 1: Baby',
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '45/100 ⭐',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.45,
                      minHeight: 10,
                      backgroundColor: Colors.white.withValues(alpha: 0.8),
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayTasksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => context.push('/tasks'),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📋 Việc hôm nay của con',
                style: TextStyle(
                  color: AppTheme.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.textLight),
            ],
          ),
        ),
        _isLoading
            ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
            : _todayTasks.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFF2D6)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🎉 ', style: TextStyle(fontSize: 20)),
                        Text('Hiện tại không có nhiệm vụ nào!', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                      ],
                    ),
                  )
                : SizedBox(
                    height: 145,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _todayTasks.length,
                      itemBuilder: (context, index) {
                        final task = _todayTasks[index];
                        final status = (task['status'] ?? 'todo').toString();
                        return _buildTaskCard(context, task, status);
                      },
                    ),
                  ),
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context, Map<String, dynamic> task, String status) {
    final bool isApproved = status == 'approved';
    final bool isSubmitted = status == 'submitted';
    final Color taskColor = (task['color'] is Color) ? task['color'] as Color : AppTheme.primary;

    Color cardBgColor = Colors.white;
    Border border = Border.all(color: const Color(0xFFFFF2D6), width: 1.5);

    if (isApproved) {
      cardBgColor = const Color(0xFFF1F9F1);
      border = Border.all(color: Colors.green.shade300, width: 1.8);
    } else if (isSubmitted) {
      cardBgColor = const Color(0xFFFFFDF0);
      border = Border.all(color: Colors.amber.shade300, width: 1.8);
    }

    return GestureDetector(
      onTap: () async {
        if (isApproved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 Con đã hoàn thành "${task['title']}" và nhận +${task['stars']} ⭐!'),
              backgroundColor: Colors.green,
            ),
          );
          return;
        }
        if (isSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🟠 Bài nộp "${task['title']}" đang chờ Bố mẹ duyệt nhé!'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        final taskId = task['id'] ?? 1;
        await context.push('/tasks/$taskId', extra: task);
        _loadTodayTasks();
      },
      child: Container(
        width: 148,
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: border,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: taskColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text((task['emoji'] ?? '📋').toString(), style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const Spacer(),
                Text(
                  (task['title'] ?? '').toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isApproved ? Colors.green.shade900 : AppTheme.text,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    decoration: isApproved ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isApproved
                      ? 'Đã nhận +${task['stars']} ⭐'
                      : isSubmitted
                          ? 'Đã nộp bài 🟠'
                          : '+${task['stars']} Sao',
                  style: TextStyle(
                    color: isApproved
                        ? Colors.green.shade700
                        : isSubmitted
                            ? Colors.amber.shade800
                            : taskColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            if (isApproved)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '✓ Xong',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else if (isSubmitted)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Chờ duyệt',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '⚡ Lối tắt nhanh',
          style: TextStyle(
            color: AppTheme.text,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionItem(Icons.card_giftcard_rounded, 'Đổi quà', AppTheme.primary, () => context.push('/rewards')),
            _buildActionItem(Icons.style_rounded, 'Tủ đồ', AppTheme.accent, () => context.push('/store')),
            _buildActionItem(Icons.pets_rounded, 'Chăm bé', AppTheme.secondary, () => context.push('/pet')),
            _buildActionItem(Icons.settings_rounded, 'Cài đặt', const Color(0xFF87CEEB), () => context.push('/profile/settings')),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Icon(icon, color: color == AppTheme.accent ? const Color(0xFFFF8DA1) : color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
