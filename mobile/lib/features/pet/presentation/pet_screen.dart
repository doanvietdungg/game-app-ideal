import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
  int _stars = 45;
  double _hunger = 0.6; // 0.0 is starving, 1.0 is full
  double _happiness = 0.8; // 0.0 is sad, 1.0 is happy
  String _petExpression = '🐱';
  String _statusMessage = 'Mimi đang vui vẻ 😊';

  void _feedPet() {
    if (_stars >= 2) {
      setState(() {
        _stars -= 2;
        _hunger = (_hunger + 0.15).clamp(0.0, 1.0);
        _petExpression = '😋';
        _statusMessage = 'Mimi ăn ngon miệng lắm! 🍖';
      });

      // Change back expression after 1.5 seconds
      Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _petExpression = '🐱';
            _statusMessage = _hunger > 0.85 ? 'Mimi no nê rồi! 💤' : 'Mimi đang vui vẻ 😊';
          });
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Con không đủ sao rồi! Hãy hoàn thành thêm nhiệm vụ nhé!'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }

  void _ticklePet() {
    setState(() {
      _happiness = (_happiness + 0.1).clamp(0.0, 1.0);
      _petExpression = '😸';
      _statusMessage = 'Hahaha, nhột quá chủ nhân ơi! 😂';
    });

    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _petExpression = '🐱';
          _statusMessage = 'Mimi đang vui vẻ 😊';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '🐾 Thú cưng ảo',
          style: TextStyle(color: AppTheme.text, fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.text),
          onPressed: () => context.pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFF2D6), width: 1.5),
            ),
            child: Row(
              children: [
                const Text('⭐ ', style: TextStyle(fontSize: 14)),
                Text(
                  '$_stars Sao',
                  style: const TextStyle(color: AppTheme.text, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Interactive Pet view
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(color: AppTheme.primary.withOpacity(0.2), width: 4),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _petExpression,
                          style: const TextStyle(fontSize: 100),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _statusMessage,
                          style: const TextStyle(
                            color: AppTheme.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Stat bars
              _buildProgressBar('🍖 Độ no nê', _hunger, AppTheme.primary),
              const SizedBox(height: 20),
              _buildProgressBar('❤️ Hạnh phúc', _happiness, AppTheme.accent),
              const SizedBox(height: 48),
              // Interaction Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.flatware_rounded,
                    label: 'Cho ăn (-2 ⭐)',
                    color: AppTheme.primary,
                    onTap: _feedPet,
                  ),
                  _buildActionButton(
                    icon: Icons.sentiment_very_satisfied_rounded,
                    label: 'Chọc nhột',
                    color: AppTheme.accent,
                    onTap: _ticklePet,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppTheme.text, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(color: AppTheme.textLight, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 12,
            backgroundColor: const Color(0xFFF1EDE5),
            valueColor: AlwaysStoppedAnimation<Color>(color == AppTheme.accent ? const Color(0xFFFF8DA1) : color),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final displayColor = color == AppTheme.accent ? const Color(0xFFFF8DA1) : color;
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: displayColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
      ),
    );
  }
}
