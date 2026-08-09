import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class ChildLoginScreen extends StatefulWidget {
  const ChildLoginScreen({super.key});

  @override
  State<ChildLoginScreen> createState() => _ChildLoginScreenState();
}

class _ChildLoginScreenState extends State<ChildLoginScreen> with SingleTickerProviderStateMixin {
  String _selectedChild = 'Bé Nam';
  final String _correctPin = '8888'; // Mock family PIN
  String _enteredPin = '';
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  final List<Map<String, String>> _mockChildren = [
    {'name': 'Bé Nam', 'avatar': '🐱'},
    {'name': 'Bé Vy', 'avatar': '🐰'},
    {'name': 'Bé Ben', 'avatar': '🐻'},
  ];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyPress(String digit) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += digit;
      });
    }

    if (_enteredPin.length == 4) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  void _verifyPin() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_enteredPin.length == 4) {
        // Success redirect to Home Screen
        if (mounted) {
          context.go('/home');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.text),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Chọn tài khoản của con nhé! 🌟',
              style: TextStyle(
                color: AppTheme.text,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
            // Avatar Selector row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _mockChildren.map((c) => _buildAvatarItem(c)).toList(),
            ),
            const SizedBox(height: 32),
            const Text(
              'Nhập mã PIN gia đình của con:',
              style: TextStyle(
                color: AppTheme.textLight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Pin indicators
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value * (1 - (_shakeController.value * 2 - 1).abs()), 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) => _buildPinDot(index)),
                  ),
                );
              },
            ),
            const Spacer(),
            // Numeric Keypad
            _buildKeypad(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarItem(Map<String, String> child) {
    final isSelected = _selectedChild == child['name'];
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChild = child['name']!;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isSelected ? 80 : 64,
              height: isSelected ? 80 : 64,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accent : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isSelected ? 0.12 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isSelected ? AppTheme.primary : const Color(0xFFE2D6C5),
                  width: isSelected ? 3 : 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  child['avatar']!,
                  style: TextStyle(fontSize: isSelected ? 36 : 28),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              child['name']!,
              style: TextStyle(
                color: AppTheme.text,
                fontSize: isSelected ? 15 : 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDot(int index) {
    final isFilled = _enteredPin.length > index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isFilled ? AppTheme.primary : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isFilled ? AppTheme.primary : const Color(0xFFE2D6C5),
          width: 2,
        ),
        boxShadow: isFilled
            ? [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['1', '2', '3'].map((n) => _buildKeypadButton(n)).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['4', '5', '6'].map((n) => _buildKeypadButton(n)).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['7', '8', '9'].map((n) => _buildKeypadButton(n)).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 64, height: 64), // Empty space for layout balance
              _buildKeypadButton('0'),
              _buildBackspaceButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String digit) {
    return GestureDetector(
      onTap: () => _onKeyPress(digit),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: const Color(0xFFFFF2D6), width: 1.5),
        ),
        child: Center(
          child: Text(
            digit,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return GestureDetector(
      onTap: _onBackspace,
      child: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.backspace_outlined,
            color: AppTheme.text,
            size: 24,
          ),
        ),
      ),
    );
  }
}
