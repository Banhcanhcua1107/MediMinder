import 'package:flutter/material.dart';
import '../../services/google_signin_service.dart';

// --- Bảng màu thống nhất ---
const Color kPrimaryColor = Color(0xFF196EB0);
const Color kBackgroundColor = Color(0xFFF8FAFC);
const Color kCardColor = Colors.white;
const Color kPrimaryTextColor = Color(0xFF1E293B);
const Color kSecondaryTextColor = Color(0xFF64748B);
const Color kBorderColor = Color(0xFFE2E8F0);

class GoogleSignInScreen extends StatefulWidget {
  const GoogleSignInScreen({super.key});

  @override
  State<GoogleSignInScreen> createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Gọi Google Sign In Service
      final googleSignInService = GoogleSignInService();
      final result = await googleSignInService.signInWithGoogle();

      debugPrint('📱 Google Sign In result: $result');
      debugPrint('📱 User: ${result?.user}');

      if (!mounted) return;

      // Kiểm tra kết quả
      if (result != null && result.user != null) {
        debugPrint('✅ Google Sign In thành công: ${result.user?.email}');
        // Chuyển sang Home Screen
        debugPrint('🚀 Navigating to /home...');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        debugPrint('❌ Google Sign In failed - result or user is null');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng nhập Google thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Google Sign In error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Back Button
            Positioned(
              left: 26,
              top: 24,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 41,
                  height: 41,
                  decoration: BoxDecoration(
                    color: kCardColor,
                    border: Border.all(color: kBorderColor, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
              ),
            ),

            // Main Content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 80),

                    // Title
                    Text(
                      'Tiếp tục với Google!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: const Color(0xFF196EB0),
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                    ),

                    const SizedBox(height: 40),

                    // Account Choice Box
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFFDADCE0),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          // Header with Google Logo
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFFDADCE0),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Image.network(
                                  'https://www.gstatic.com/images/branding/product/1x/googleg_40dp.png',
                                  width: 14,
                                  height: 14,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: Icon(Icons.g_translate, size: 14),
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Đăng nhập bằng Google',
                                  style: TextStyle(
                                    color: Color(0xFF5F6368),
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Main Content
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 24,
                            ),
                            child: Column(
                              children: [
                                // Header Text
                                Column(
                                  children: [
                                    Text(
                                      'Chọn một tài khoản',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: const Color(0xFF202124),
                                            fontSize: 24,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Roboto',
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'để tiếp tục với ',
                                            style: TextStyle(
                                              color: Color(0xFF202124),
                                              fontSize: 16,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: '- ',
                                            style: TextStyle(
                                              color: Color(0xFF196EB0),
                                              fontSize: 16,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: 'MediMinder',
                                            style: TextStyle(
                                              color: Color(0xFF196EB0),
                                              fontSize: 16,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Account Options - Only "Sử dụng tài khoản khác"
                                GestureDetector(
                                  onTap: _isLoading ? null : _handleSignIn,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.account_circle_outlined,
                                          size: 20,
                                          color: Color(0xFF3C4043),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Sử dụng tài khoản khác',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: const Color(
                                                    0xFF3C4043,
                                                  ),
                                                  fontSize: 14,
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ),
                                        if (_isLoading) ...[
                                          const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Color(0xFF196EB0),
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Description
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 12,
                            ),
                            child: Text(
                              'Để tiếp tục, Google sẽ chia sẻ tên, địa chỉ email, tùy chọn ngôn ngữ và ảnh hồ sơ của bạn với MediMinder. Trước khi sử dụng ứng dụng này, bạn có thể xem chính sách bảo mật và điều khoản dịch vụ của MediMinder.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: const Color(0xFF5F6368),
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.normal,
                                    height: 1.4,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),

            // Footer
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _isLoading ? null : () {},
                      child: Row(
                        children: const [
                          Text(
                            'Tiếng Việt',
                            style: TextStyle(
                              color: Color(0xFF202124),
                              fontSize: 12,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 16,
                            color: Color(0xFF202124),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: const [
                        Text(
                          'Trợ giúp',
                          style: TextStyle(
                            color: Color(0xFF80868B),
                            fontSize: 12,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Bảo mật',
                          style: TextStyle(
                            color: Color(0xFF80868B),
                            fontSize: 12,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Điều khoản',
                          style: TextStyle(
                            color: Color(0xFF80868B),
                            fontSize: 12,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
