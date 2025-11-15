import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      'https://res.cloudinary.com/dgl8p7xqo/image/upload/v1763014788/clock_pill_ibxkam.png',
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return CircularProgressIndicator();
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.image_not_supported, size: 50);
                      },
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Welcome To',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'MediMinder',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0B63B8),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Trợ lý cá nhân giúp bạn quản lý lịch uống thuốc mỗi ngày.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
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
                        color: Color(0xFF0B63B8),
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
