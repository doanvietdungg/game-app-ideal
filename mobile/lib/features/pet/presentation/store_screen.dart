import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';

class StoreScreen extends StatefulWidget {
  final ApiClient? apiClient;
  const StoreScreen({super.key, this.apiClient});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Persistent static state across app sessions
  static int _stars = 45;
  static String _equippedSkin = 'Mèo Thường 🐱';
  static final Set<String> _unlockedSkins = {'Mèo Thường 🐱'};

  final List<Map<String, dynamic>> _storeSkins = [
    {'name': 'Mèo Robot 🤖', 'cost': 15, 'desc': 'Trang bị vỏ kim loại bóng loáng siêu ngầu.'},
    {'name': 'Mèo Ninja 🥷', 'cost': 30, 'desc': 'Khoác áo choàng đen bí ẩn, di chuyển cực nhanh.'},
    {'name': 'Mèo Quý Tộc 👑', 'cost': 50, 'desc': 'Đội vương miện hoàng gia lấp lánh sang trọng.'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _unlockSkin(Map<String, dynamic> skin) async {
    final cost = skin['cost'] as int;
    final name = skin['name'] as String;

    if (_stars >= cost) {
      setState(() {
        _stars -= cost;
        _unlockedSkins.add(name);
        _equippedSkin = name; // Auto equip on unlock!
      });

      // Sync unlock to Backend Database API if apiClient provided
      if (widget.apiClient != null) {
        widget.apiClient!.post('/v1/children/1/pet/skin', data: {
          'skin_name': name,
          'price': cost,
        }).catchError((_) {});
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(name.split(' ').last, style: const TextStyle(fontSize: 45)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '🎉 Mở Khóa Thành Công!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.text),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Con vừa sở hữu diện mạo "$name"!\nMimi đã được thay trang phục mới siêu ngầu 🐱✨',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: AppTheme.textLight, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Đeo ngay cực thích! 🚀', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không đủ sao rồi! Hãy tích cực làm nhiệm vụ để kiếm thêm sao nhé!'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }

  void _equipSkin(String name) {
    setState(() {
      _equippedSkin = name;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🐾 Đã trang bị thành công diện mạo $name!'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          '🛍️ Cửa hàng & Tủ đồ',
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textLight,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: const [
            Tab(text: 'Cửa hàng 🛒'),
            Tab(text: 'Tủ đồ 👕'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStoreTab(),
          _buildWardrobeTab(),
        ],
      ),
    );
  }

  Widget _buildStoreTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _storeSkins.length,
      itemBuilder: (context, index) {
        final skin = _storeSkins[index];
        final name = skin['name'] as String;
        final isUnlocked = _unlockedSkins.contains(name);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Skin preview icon representation
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(name.split(' ').last, style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(color: AppTheme.text, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        skin['desc'] as String,
                        style: const TextStyle(color: AppTheme.textLight, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isUnlocked) ...[
                  ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Đã sở hữu', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    onPressed: () => _unlockSkin(skin),
                    icon: const Icon(Icons.star_rounded, size: 16, color: Colors.white),
                    label: Text('${skin['cost']}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWardrobeTab() {
    // List unlocked skins
    final unlockedList = _unlockedSkins.toList();
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: unlockedList.length,
      itemBuilder: (context, index) {
        final name = unlockedList[index];
        final isEquipped = _equippedSkin == name;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Skin preview icon representation
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(name.split(' ').last, style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(color: AppTheme.text, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isEquipped ? 'Đang mặc diện mạo này' : 'Nhấn để trang bị ngay',
                        style: TextStyle(
                          color: isEquipped ? AppTheme.secondary : AppTheme.textLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isEquipped) ...[
                  ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Đang dùng', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: () => _equipSkin(name),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Trang bị', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
// Fix typo AppTheme.secondary (Mint Green) using green theme color in text
