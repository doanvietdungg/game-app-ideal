import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../data/reward_repository.dart';
import 'widgets/redeem_modal.dart';

class RewardListScreen extends StatefulWidget {
  final ApiClient? apiClient;
  const RewardListScreen({super.key, this.apiClient});

  @override
  State<RewardListScreen> createState() => _RewardListScreenState();
}

class _RewardListScreenState extends State<RewardListScreen> {
  late final RewardRepository _repository;
  List<RewardItem> _rewards = [];
  bool _isLoading = true;
  int _childStars = 35; // Demo current star count

  @override
  void initState() {
    super.initState();
    _repository = RewardRepository(widget.apiClient ?? ApiClient());
    _loadRewards();
  }

  Future<void> _loadRewards() async {
    setState(() => _isLoading = true);
    final items = await _repository.getRewards();
    if (mounted) {
      setState(() {
        _rewards = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRedeem(RewardItem item) async {
    showDialog(
      context: context,
      builder: (ctx) => RedeemModal(
        reward: item,
        onConfirm: () async {
          final success = await _repository.redeemReward(item.id);
          if (mounted && success) {
            setState(() {
              _childStars -= item.starCost;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã gửi yêu cầu đổi "${item.title}" thành công! 🎉')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cửa Hàng Đổi Quà 🎁'),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('⭐ ', style: TextStyle(fontSize: 16)),
                Text(
                  '$_childStars sao',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
                ),
              ],
            ),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rewards.isEmpty
              ? const Center(child: Text('Chưa có phần thưởng nào.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _rewards.length,
                  itemBuilder: (context, index) {
                    final item = _rewards[index];
                    final canAfford = _childStars >= item.starCost;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(item.description),
                        ),
                        trailing: ElevatedButton(
                          onPressed: canAfford ? () => _handleRedeem(item) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canAfford ? Colors.amber.shade700 : Colors.grey.shade300,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('${item.starCost} ⭐'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
