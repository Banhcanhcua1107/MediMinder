import 'package:flutter/material.dart';

class CustomToast extends StatefulWidget {
  final String message;
  final String? subtitle;
  final bool isSuccess;
  final Duration duration;
  final VoidCallback? onDismiss;

  const CustomToast({
    Key? key,
    required this.message,
    this.subtitle,
    this.isSuccess = true,
    this.duration = const Duration(seconds: 3),
    this.onDismiss,
  }) : super(key: key);

  @override
  State<CustomToast> createState() => _CustomToastState();
}

class _CustomToastState extends State<CustomToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();

    // Tự động ẩn sau duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _animationController.reverse().then((_) {
          if (mounted) {
            widget.onDismiss?.call();
            Navigator.of(context).pop();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isSuccess
        ? const Color(0xFFD1F4E6)
        : const Color(0xFFFFE4E4);
    final iconColor = widget.isSuccess
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);
    final textColor = widget.isSuccess
        ? const Color(0xFF047857)
        : const Color(0xB91F2937);

    return SlideTransition(
      position: _slideAnimation,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        widget.isSuccess ? Icons.check_circle : Icons.error,
                        color: iconColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.message,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _animationController.reverse().then((_) {
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      });
                    },
                    child: Icon(Icons.close, color: iconColor, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Hàm helper để show toast
void showCustomToast(
  BuildContext context, {
  required String message,
  String? subtitle,
  bool isSuccess = true,
  Duration duration = const Duration(seconds: 3),
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    builder: (context) => CustomToast(
      message: message,
      subtitle: subtitle,
      isSuccess: isSuccess,
      duration: duration,
    ),
  );
}
