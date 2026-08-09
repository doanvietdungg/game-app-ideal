import 'package:flutter/material.dart';
import '../../data/reward_repository.dart';

class RedeemModal extends StatelessWidget {
  final RewardItem reward;
  final VoidCallback onConfirm;

  const RedeemModal({super.key, required this.reward, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Xác nhận đổi quà 🎁', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Bạn có chắc muốn dùng ${reward.starCost} ⭐ để đổi lấy:'),
          const SizedBox(height: 12),
          Text(
            reward.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: const Text('Đổi ngay ⭐'),
        ),
      ],
    );
  }
}
