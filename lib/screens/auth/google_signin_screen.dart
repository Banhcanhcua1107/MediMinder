import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final _supabase = Supabase.instance.client;
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();

    // Lắng nghe auth state change
    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;

      if (session != null && mounted) {
        debugPrint(
          '✅ Auth state changed - User logged in: ${session.user.email}',
        );
        // Navigate to home khi user login thành công
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Logout trước để xóa cache Google account
      debugPrint('🔓 Signing out previous session...');
      await _supabase.auth.signOut();

      // Gọi Supabase Auth để đăng nhập với Google
      debugPrint('🔐 Initiating Google OAuth sign-in...');
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        // redirectTo phải khớp với android:scheme trong AndroidManifest.xml
        redirectTo: 'com.mediminder.app://login-callback/',
      );

      // Sau khi callback thành công, StreamBuilder trong main.dart
      // sẽ lắng nghe sự thay đổi và tự động chuyển sang Dashboard
      debugPrint(
        '✅ OAuth callback received - waiting for StreamBuilder to handle navigation...',
      );
    } catch (e) {
      debugPrint('❌ Google Sign In error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đăng nhập: ${e.toString()}'),
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
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kCardColor,
            border: Border.all(color: kBorderColor, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            color: kPrimaryTextColor,
            iconSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 30),

                // Title
                Text(
                  'Tiếp tục với Google!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                                              color: const Color(0xFF3C4043),
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

                // Footer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
