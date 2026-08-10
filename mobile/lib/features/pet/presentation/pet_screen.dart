import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/pet_physics_canvas.dart';
import 'widgets/particle_overlay.dart';
import 'widgets/draggable_food.dart';

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> with TickerProviderStateMixin {
  int _stars = 45;
  double _hunger = 0.6;
  double _happiness = 0.8;
  String _statusMessage = 'Mimi đang vui vẻ 😊';
  String _expression = 'happy';
  String _activeSkin = 'Mèo Thường 🐱';

  Offset? _touchOffset;
  bool _isMouthOpen = false;
  final GlobalKey _petKey = GlobalKey();

  final List<ParticleItem> _particles = [];

  double _scaleX = 1.0;
  double _scaleY = 1.0;

  bool get _isTestEnv => WidgetsBinding.instance.runtimeType.toString().contains('Test');

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final res = await ApiClient().get('/v1/children/1/profile').timeout(const Duration(milliseconds: 500));
      if (mounted && res.statusCode == 200 && res.data['status'] == true) {
        final data = res.data['data'];
        setState(() {
          _stars = data['available_stars'] ?? _stars;
          if (data['pet'] != null && data['pet']['active_skin'] != null) {
            _activeSkin = data['pet']['active_skin'].toString();
            if (_activeSkin.contains('Robot') || _activeSkin.contains('🤖')) {
              _statusMessage = 'Mimi Mèo Robot đang sẵn sàng! 🤖';
            } else if (_activeSkin.contains('Ninja') || _activeSkin.contains('🥷')) {
              _statusMessage = 'Mimi Mèo Ninja đang tuần tra! 🥷';
            } else if (_activeSkin.contains('Quý Tộc') || _activeSkin.contains('👑')) {
              _statusMessage = 'Mimi Mèo Quý Tộc kiêu hãnh! 👑';
            }
          }
        });
      }
    } catch (_) {}
  }

  void _triggerBounce() {
    setState(() {
      _scaleX = 1.15;
      _scaleY = 0.85;
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _scaleX = 0.95;
          _scaleY = 1.05;
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _scaleX = 1.0;
          _scaleY = 1.0;
        });
      }
    });
  }

  void _spawnParticles(Offset pos, String emoji, int count) {
    final random = Random();
    for (int i = 0; i < count; i++) {
      _particles.add(
        ParticleItem(
          x: pos.dx + random.nextDouble() * 40 - 20,
          y: pos.dy + random.nextDouble() * 40 - 20,
          vx: (random.nextDouble() - 0.5) * 4,
          vy: -random.nextDouble() * 4 - 2,
          emoji: emoji,
        ),
      );
    }
  }

  void _feedPet() {
    if (_stars >= 2) {
      setState(() {
        _stars -= 2;
        _hunger = (_hunger + 0.15).clamp(0.0, 1.0);
        _expression = 'eating';
        _statusMessage = 'Mimi ăn ngon miệng lắm! 🍖';
        _isMouthOpen = false;
      });

      _triggerBounce();
      _spawnParticles(Offset(MediaQuery.of(context).size.width / 2 - 20, 260), '⭐', 8);

      Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _expression = 'happy';
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

  void _ticklePet(TapDownDetails details) {
    setState(() {
      _happiness = (_happiness + 0.1).clamp(0.0, 1.0);
      _expression = 'tickled';
      _statusMessage = 'Hahaha, nhột quá chủ nhân ơi! 😂';
    });

    _triggerBounce();
    _spawnParticles(details.globalPosition, '💖', 10);

    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _expression = 'happy';
          _statusMessage = 'Mimi đang vui vẻ 😊';
        });
      }
    });
  }

  void _checkMagnetAttraction(Offset dragPos) {
    final RenderBox? box = _petKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final petPos = box.localToGlobal(Offset.zero);
      final petCenter = Offset(petPos.dx + box.size.width / 2, petPos.dy + box.size.height / 2);
      final distance = (dragPos - petCenter).distance;

      setState(() {
        _touchOffset = dragPos;
        _isMouthOpen = distance < 100;
      });
    }
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('⭐ ', style: TextStyle(fontSize: 16)),
                Text(
                  '$_stars Sao',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.deepOrange),
                ),
              ],
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Status message bubble
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Text(
                    _statusMessage,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.text),
                  ),
                ),

                const SizedBox(height: 30),

                // Interactive Physics Canvas Center
                GestureDetector(
                  key: _petKey,
                  onTapDown: _ticklePet,
                  onPanUpdate: (details) {
                    setState(() => _touchOffset = details.globalPosition);
                  },
                  onPanEnd: (_) {
                    setState(() => _touchOffset = null);
                  },
                  child: Container(
                    height: 240,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: PetPhysicsCanvas(
                      touchOffset: _touchOffset,
                      expression: _expression,
                      skin: _activeSkin,
                      scaleX: _scaleX,
                      scaleY: _scaleY,
                      isMouthOpen: _isMouthOpen,
                      enableAnimations: true,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Drag and drop prompt
                const Text(
                  '💡 Kéo đùi gà 🍖 đến miệng Mimi để cho ăn!',
                  style: TextStyle(fontSize: 13, color: Colors.black54, fontStyle: FontStyle.italic),
                ),

                const SizedBox(height: 20),

                // Stats Progress Bars
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow('🍖 Độ no nê', _hunger, Colors.orange),
                      const SizedBox(height: 12),
                      _buildStatRow('💖 Vui vẻ', _happiness, Colors.pink),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Interactive Food & Action Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DraggableFoodItem(
                      emoji: '🍖',
                      label: 'Cho ăn (-2 ⭐)',
                      onTap: _feedPet,
                      onDragUpdate: _checkMagnetAttraction,
                      onDragEnd: (pos) {
                        _feedPet();
                      },
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        _ticklePet(TapDownDetails(globalPosition: const Offset(200, 300)));
                      },
                      icon: const Text('🪶', style: TextStyle(fontSize: 20)),
                      label: const Text('Chọc nhột'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.shade100,
                        foregroundColor: Colors.pink.shade900,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Particle Overlay Canvas
          Positioned.fill(
            child: ParticleOverlay(particles: _particles),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 12,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text('${(value * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
