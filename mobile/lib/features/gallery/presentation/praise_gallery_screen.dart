import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../data/gallery_repository.dart';

class PraiseGalleryScreen extends StatefulWidget {
  final ApiClient? apiClient;
  const PraiseGalleryScreen({super.key, this.apiClient});

  @override
  State<PraiseGalleryScreen> createState() => _PraiseGalleryScreenState();
}

class _PraiseGalleryScreenState extends State<PraiseGalleryScreen> {
  late final GalleryRepository _repository;
  List<PraiseItem> _praises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = GalleryRepository(widget.apiClient ?? ApiClient());
    _loadPraises();
  }

  Future<void> _loadPraises() async {
    final items = await _repository.getPraiseItems();
    if (mounted) {
      setState(() {
        _praises = items;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Góc Kỷ Niệm & Lời Khen 💖'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _praises.isEmpty
              ? const Center(child: Text('Chưa có hình ảnh nào trong góc kỷ niệm.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _praises.length,
                  itemBuilder: (context, index) {
                    final item = _praises[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Task Header & Sticker
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.taskTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    const SizedBox(height: 4),
                                    Text(item.completedAt, style: const TextStyle(color: Colors.black45, fontSize: 12)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(item.stickerEmoji, style: const TextStyle(fontSize: 16)),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.stickerText,
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Photo Placeholder Container
                          Container(
                            height: 180,
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.amber.shade200, width: 2),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt_rounded, size: 48, color: Colors.orange),
                                SizedBox(height: 8),
                                Text('Ảnh kết quả bé nộp 📸', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),

                          // Parent Praise Note Card
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.pink.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.pink.shade200, width: 1),
                              ),
                              child: Row(
                                children: [
                                  const Text('💬 ', style: TextStyle(fontSize: 20)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Lời khen từ Bố Mẹ:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink)),
                                        const SizedBox(height: 4),
                                        Text(item.parentComment, style: const TextStyle(color: Colors.black87, fontStyle: FontStyle.italic)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
