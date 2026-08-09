import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../data/stats_repository.dart';

class StatsScreen extends StatefulWidget {
  final ApiClient? apiClient;
  const StatsScreen({super.key, this.apiClient});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late final StatsRepository _repository;
  ChildStats? _stats;
  bool _isLoading = true;

  final List<String> _weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  void initState() {
    super.initState();
    _repository = StatsRepository(widget.apiClient ?? ApiClient());
    _loadStats();
  }

  Future<void> _loadStats() async {
    final data = await _repository.getChildStats();
    if (mounted) {
      setState(() {
        _stats = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo Cáo & Streak 🔥'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Streak Card
                  Card(
                    color: Colors.deepOrange.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text('🔥 STREAK LIÊN TỤC', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                          const SizedBox(height: 8),
                          Text(
                            '${_stats?.streakDays ?? 0} Ngày',
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                          ),
                          const SizedBox(height: 6),
                          const Text('Giữ vững phong độ mỗi ngày bé nhé!', style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text('Sao Tích Lũy Tuần Này ⭐', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Weekly Custom Bar Chart
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 180,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAlignment.end,
                          children: List.generate(7, (index) {
                            final count = _stats?.weeklyStars[index] ?? 0;
                            final heightRatio = (count / 12).clamp(0.1, 1.0);

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('$count', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                const SizedBox(height: 4),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 24,
                                  height: 120 * heightRatio,
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade600,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(_weekDays[index], style: const TextStyle(color: Colors.black54, fontSize: 12)),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text('Tổng Kết Thành Tích 🏆', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 32),
                                const SizedBox(height: 8),
                                Text('${_stats?.totalTasksCompleted ?? 0}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                const Text('Nhiệm vụ hoàn thành', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black54)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 32),
                                const SizedBox(height: 8),
                                Text('${_stats?.totalStarsEarned ?? 0}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                const Text('Tổng sao đã kiếm', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black54)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
