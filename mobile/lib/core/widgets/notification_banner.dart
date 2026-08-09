import 'package:flutter/material.dart';

class NotificationBannerWidget extends StatefulWidget {
  final String title;
  final String body;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const NotificationBannerWidget({
    super.key,
    required this.title,
    required this.body,
    this.onTap,
    required this.onDismiss,
  });

  @override
  State<NotificationBannerWidget> createState() => _NotificationBannerWidgetState();
}

class _NotificationBannerWidgetState extends State<NotificationBannerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward();

    // Auto dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.shade400,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.shade800.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: InkWell(
            onTap: () {
              _dismiss();
              if (widget.onTap != null) widget.onTap!();
            },
            child: Row(
              children: [
                const Text('🔔', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black90, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.body,
                        style: const TextStyle(color: Colors.black87, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.black54),
                  onPressed: _dismiss,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
