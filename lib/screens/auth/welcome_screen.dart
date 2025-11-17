import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';

// --- Bảng màu thống nhất ---
const Color kPrimaryColor = Color(0xFF196EB0);
const Color kBackgroundColor = Color(0xFFF8FAFC);
const Color kCardColor = Colors.white;
const Color kPrimaryTextColor = Color(0xFF1E293B);
const Color kSecondaryTextColor = Color(0xFF64748B);

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 28.0,
                vertical: 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 8),
                  SizedBox(
                    width: 170,
                    height: 170,
                    child: Image.network(
                      'https://res.cloudinary.com/dgl8p7xqo/image/upload/v1763387953/7732212_hgg4um.png',
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const CircularProgressIndicator();
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported, size: 50);
                      },
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Welcome To',
                    style: TextStyle(fontSize: 14, color: kSecondaryTextColor),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'MediMinder',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: kPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Trợ lý cá nhân giúp bạn quản lý lịch uống thuốc mỗi ngày.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kSecondaryTextColor),
                  ),
                  SizedBox(height: 22),

                  PrimaryButton(
                    text: 'Đăng nhập',
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                  ),
                  SizedBox(height: 12),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: Text(
                      'Đăng ký',
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
