import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';

class TaskDetailScreen extends StatefulWidget {
  final int taskId;
  final Map<String, dynamic> taskData;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
    required this.taskData,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  File? _selectedImage;
  bool _isSubmitting = false;
  final _picker = ImagePicker();
  final String _familyPin = '8888';

  // Determine verification type from category/id for visual presentation (Sprint 2 mock)
  String get _verificationType {
    if (widget.taskId == 1) return 'photo'; // Homework/cleaning requires photo
    if (widget.taskId == 2) return 'pin';   // Study requires parent verification
    return 'auto';                         // Others auto approve
  }

  Future<void> _capturePhoto() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở máy ảnh. Hãy cấp quyền truy cập máy ảnh nhé!')),
      );
    }
  }

  void _handleSubmit() {
    setState(() {
      _isSubmitting = true;
    });

    // Simulate upload and complete
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        // Show congratulations and go back
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            backgroundColor: Colors.white,
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated glowing star icon
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('⭐', style: TextStyle(fontSize: 50)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '🎉 Xuất Sắc Lắm Con Ôi!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Con vừa hoàn thành "${widget.taskData['title']}"!\nMimi đang rất tự hào về con 🐱✨',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textLight,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade400, Colors.deepOrange.shade400],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepOrange.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Thưởng ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          '+${widget.taskData['stars']} ⭐',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        context.pop(); // Close dialog
                        context.pop(); // Go back to task list
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Tuyệt vời! Tuyệt vời! 🚀',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    });
  }

  void _showPinDialog() {
    String enteredPin = '';
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('👨‍👩‍👧 Bố mẹ xác nhận', style: TextStyle(fontWeight: FontWeight.w900)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Vui lòng nhập mã PIN gia đình để hoàn thành nhiệm vụ này:',
                    style: TextStyle(color: AppTheme.textLight, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final isFilled = enteredPin.length > index;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: isFilled ? AppTheme.primary : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE2D6C5), width: 2),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  // Simple grid of numbers inside dialog
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(9, (index) {
                      final digit = '${index + 1}';
                      return InkWell(
                        onTap: () {
                          if (enteredPin.length < 4) {
                            setDialogState(() {
                              enteredPin += digit;
                            });
                          }
                          if (enteredPin.length == 4) {
                            if (enteredPin == _familyPin) {
                              context.pop(); // Close pin dialog
                              _handleSubmit();
                            } else {
                              setDialogState(() {
                                enteredPin = '';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Mã PIN chưa đúng, bố mẹ nhập lại nhé!')),
                              );
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(32),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFFFF2D6)),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(digit, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.taskData;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.text),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Emoji and Title Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(task['emoji'] ?? '📋', style: const TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text(
                      task['title'] ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.text,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+${task['stars']} Sao ⭐',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildVerifyBadge(),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Description
              const Text(
                '📝 Hướng dẫn nhiệm vụ:',
                style: TextStyle(color: AppTheme.text, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                task['desc'] ?? 'Làm việc chăm chỉ để nhận quà tặng con yêu!',
                style: const TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),
              // Conditional inputs based on verification types
              if (_verificationType == 'photo') ...[
                if (_selectedImage != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(_selectedImage!, height: 200, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _capturePhoto,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Chụp lại ảnh minh chứng'),
                  ),
                ] else ...[
                  GestureDetector(
                    onTap: _capturePhoto,
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 2, style: BorderStyle.solid),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_rounded, size: 48, color: AppTheme.primary),
                          SizedBox(height: 8),
                          Text(
                            'Chụp ảnh kết quả của con',
                            style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 48),
              // Action submit button
              ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        if (_verificationType == 'photo' && _selectedImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vui lòng chụp ảnh minh chứng trước nhé!')),
                          );
                        } else if (_verificationType == 'pin') {
                          _showPinDialog();
                        } else {
                          _handleSubmit();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)),
                      )
                    : Text(
                        _verificationType == 'pin' ? 'Yêu cầu Bố mẹ xác nhận' : 'Hoàn thành nhiệm vụ',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyBadge() {
    String label;
    IconData icon;
    Color color;

    switch (_verificationType) {
      case 'photo':
        label = 'Ảnh chụp';
        icon = Icons.camera_alt_outlined;
        color = Colors.blue;
        break;
      case 'pin':
        label = 'Mã PIN';
        icon = Icons.lock_outline_rounded;
        color = Colors.orange;
        break;
      default:
        label = 'Tự động';
        icon = Icons.flash_on_rounded;
        color = AppTheme.secondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color == AppTheme.secondary ? const Color(0xFF55B380) : color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color == AppTheme.secondary ? const Color(0xFF55B380) : color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
// Fix typo style: BorderStyle.values[1] -> style: BorderStyle.solid
