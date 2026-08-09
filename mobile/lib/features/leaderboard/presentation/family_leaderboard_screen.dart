import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../data/leaderboard_repository.dart';

class FamilyLeaderboardScreen extends StatefulWidget {
  final ApiClient? apiClient;
  const FamilyLeaderboardScreen({super.key, this.apiClient});

  @override
  State<FamilyLeaderboardScreen> createState() => _FamilyLeaderboardScreenState();
}

class _FamilyLeaderboardScreenState extends State<FamilyLeaderboardScreen> {
  late final LeaderboardRepository _repository;
  List<LeaderboardMember> _members = [];
  FamilyChallenge? _challenge;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = LeaderboardRepository(widget.apiClient ?? ApiClient());
    _loadData();
  }

  Future<void> _loadData() async {
    final members = await _repository.getLeaderboard();
    final challenge = await _repository.getWeeklyChallenge();
    if (mounted) {
      setState(() {
        _members = members;
        _challenge = challenge;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Bảng Xếp Hạng Thi Đua 🏆'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Weekly Challenge Card
                  if (_challenge != null) ...[
                    Card(
                      color: Colors.amber.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      borderOnForeground: true,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🎯 THỬ THÁCH TUẦN CỦA CẢ NHÀ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                            const SizedBox(height: 8),
                            Text(_challenge!.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: _challenge!.currentProgress / _challenge!.targetProgress,
                                minHeight: 12,
                                backgroundColor: Colors.amber.shade200,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${_challenge!.currentProgress}/${_challenge!.targetProgress} trang', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('Thưởng: ${_challenge!.rewardDescription}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Podium Top 3
                  if (_members.length >= 3) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAlignment.end,
                      children: [
                        // Rank 2 (Silver)
                        _buildPodiumColumn(_members[1], 110, Colors.grey.shade300, '🥈'),
                        const SizedBox(width: 12),
                        // Rank 1 (Gold)
                        _buildPodiumColumn(_members[0], 140, Colors.amber.shade400, '🥇'),
                        const SizedBox(width: 12),
                        // Rank 3 (Bronze)
                        _buildPodiumColumn(_members[2], 90, Colors.orange.shade300, '🥉'),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Member Standings List
                  const Text('Dẫn Đầu Tuần Này 🌟', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _members.length,
                    itemBuilder: (context, index) {
                      final item = _members[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.amber.shade100,
                            child: Text(item.avatarEmoji, style: const TextStyle(fontSize: 20)),
                          ),
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('🔥 ${item.streakDays} ngày streak'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text('${item.weeklyStars} ⭐', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPodiumColumn(LeaderboardMember member, double height, Color color, String badge) {
    return Column(
      children: [
        Text(badge, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 4),
        Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Center(
            child: Text(
              '${member.weeklyStars} ⭐',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }
}
