import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/pet_physics_canvas.dart';

class PetSelectionScreen extends StatefulWidget {
  const PetSelectionScreen({super.key});

  @override
  State<PetSelectionScreen> createState() => _PetSelectionScreenState();
}

class _PetSelectionScreenState extends State<PetSelectionScreen> {
  String _selectedSpecies = 'cat';

  final List<Map<String, String>> _speciesList = [
    {'id': 'cat', 'name': 'Mèo Mimi 🐱', 'desc': 'Ngoan ngoãn, thích ăn đùi gà và vuốt ve'},
    {'id': 'dog', 'name': 'Chó Rex 🐶', 'desc': 'Trung thành, vẫy đuôi mừng khi bé hoàn thành bài'},
    {'id': 'dragon', 'name': 'Rồng Spark 🐉', 'desc': 'Dũng cảm, phun pháo hoa ngôi sao mừng bé'},
    {'id': 'rabbit', 'name': 'Thỏ Miffy 🐰', 'desc': 'Chăm chỉ, đôi tai dài nhấp nhô vui vẻ'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Chọn Loài Thú Cưng 🐾'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Active Preview
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.amber.shade200, width: 2),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 180,
                    child: Center(
                      child: PetPhysicsCanvas(species: _selectedSpecies, expression: 'happy'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _speciesList.firstWhere((s) => s['id'] == _selectedSpecies)['name']!,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _speciesList.firstWhere((s) => s['id'] == _selectedSpecies)['desc']!,
                    style: const TextStyle(color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Selection List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _speciesList.length,
              itemBuilder: (context, index) {
                final item = _speciesList[index];
                final isSelected = item['id'] == _selectedSpecies;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: isSelected ? Colors.amber.shade100 : Colors.white,
                  elevation: isSelected ? 3 : 1,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text(item['desc']!),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: Colors.deepOrange, size: 28)
                        : const Icon(Icons.circle_outlined, color: Colors.black26),
                    onTap: () {
                      setState(() {
                        _selectedSpecies = item['id']!;
                      });
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã chọn ${_speciesList.firstWhere((s) => s['id'] == _selectedSpecies)['name']} làm đồng hành! 🎉')),
                  );
                  context.pop();
                },
                child: const Text('Xác nhận chọn thú cưng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
