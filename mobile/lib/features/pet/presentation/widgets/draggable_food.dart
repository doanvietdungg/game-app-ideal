import 'package:flutter/material.dart';

class DraggableFoodItem extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback? onTap;
  final Function(Offset globalPos) onDragUpdate;
  final Function(Offset globalPos) onDragEnd;

  const DraggableFoodItem({
    super.key,
    required this.emoji,
    required this.label,
    this.onTap,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        if (onTap != null) {
          onTap!();
        }
      },
      child: Draggable<String>(
        data: emoji,
        feedback: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade100.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.shade400.withValues(alpha: 0.5),
                  blurRadius: 16,
                  spreadRadius: 4,
                )
              ],
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 48)),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _buildButton(),
        ),
        onDragUpdate: (details) => onDragUpdate(details.globalPosition),
        onDragEnd: (details) => onDragEnd(details.offset),
        child: _buildButton(),
      ),
    );
  }

  Widget _buildButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade300, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
        ],
      ),
    );
  }
}
