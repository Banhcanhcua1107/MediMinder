import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool fullWidth;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      style: ElevatedButton.styleFrom(
        // Thêm 2 dòng dưới đây để tùy chỉnh màu sắc cho nút
        backgroundColor: const Color(0xFF1256DB), // Màu nền của nút
        foregroundColor: Colors.white, // Màu của chữ bên trong nút

        minimumSize: Size(fullWidth ? double.infinity : 160, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 3,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
      onPressed: onPressed,
      child: Text(text),
    );

    if (fullWidth) return button;
    return Center(child: SizedBox(width: 220, child: button));
  }
}
