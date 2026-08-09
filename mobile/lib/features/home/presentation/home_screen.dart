import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildPetCanvas(context),
              const SizedBox(height: 28),
              _buildTodayTasksSection(context),
              const SizedBox(height: 28),
              _buildQuickActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.emoji_events_rounded, color: AppTheme.primary, size: 16),
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
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Xin chào, Nam! 👋',
              style: TextStyle(
                color: AppTheme.text,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Streak
            _buildStatItem('🔥', '12 ngày'),
            const SizedBox(width: 12),
            // Stars
            _buildStatItem('⭐', '45 Sao'),
          ],
        )
      ],
    );
  }

  Widget _buildStatItem(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFFFF2D6), width: 1.5),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetCanvas(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/pet'),
      child: Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: AppTheme.primary.withOpacity(0.2), width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft circles
          Positioned(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Virtual Pet emoji placeholder (Sprint 1)
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🐱', // Custom pet emoji representation
                style: TextStyle(fontSize: 80),
              ),
              SizedBox(height: 12),
              Text(
                'Mimi đang vui vẻ 😊',
                style: TextStyle(
                  color: AppTheme.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          // Progress bar to evolution
          Positioned(
            bottom: 16,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
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
                        color: AppTheme.textLight,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    value: 0.45,
                    minHeight: 10,
                    backgroundColor: Color(0xFFF1EDE5),
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
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
    final List<Map<String, dynamic>> mockTasks = [
      {'title': 'Dọn dẹp phòng', 'stars': 5, 'emoji': '🏠', 'color': const Color(0xFFFFB347)},
      {'title': 'Đọc sách 20 phút', 'stars': 10, 'emoji': '📚', 'color': const Color(0xFF87CEEB)},
      {'title': 'Rửa chén đĩa', 'stars': 8, 'emoji': '🍽️', 'color': const Color(0xFFA8E6CF)},
    ];

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
        const SizedBox(height: 14),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: mockTasks.length,
            itemBuilder: (context, index) {
              final task = mockTasks[index];
              return _buildTaskCard(context, task);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context, Map<String, dynamic> task) {
    return GestureDetector(
      onTap: () => context.push('/tasks'),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFFFF2D6), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: task['color'].withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(task['emoji'], style: const TextStyle(fontSize: 18)),
            ),
          ),
          const Spacer(),
          Text(
            task['title'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '+${task['stars']} Sao',
            style: TextStyle(
              color: task['color'],
              fontSize: 12,
              fontWeight: FontWeight.w800,
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
            _buildActionItem(Icons.card_giftcard_rounded, 'Đổi quà', AppTheme.primary, () => context.push('/store')),
            _buildActionItem(Icons.style_rounded, 'Tủ đồ', AppTheme.accent, () => context.push('/store')),
            _buildActionItem(Icons.bookmark_rounded, 'Nhật ký', AppTheme.secondary, () {}),
            _buildActionItem(Icons.pie_chart_rounded, 'Thống kê', const Color(0xFF87CEEB), () {}),
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
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
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
