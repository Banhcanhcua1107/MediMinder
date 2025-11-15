import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'supabase_service.dart';

/// Service xử lý deep link từ email xác nhận
class AuthDeepLinkService {
  static final AuthDeepLinkService _instance = AuthDeepLinkService._internal();

  factory AuthDeepLinkService() {
    return _instance;
  }

  AuthDeepLinkService._internal();

  final supabaseService = SupabaseService();
  final appLinks = AppLinks();

  /// Khởi tạo deep link listener
  void initDeepLinks(BuildContext? context) {
    // Listen for app links
    appLinks.uriLinkStream.listen(
      (uri) {
        if (context != null) {
          _handleDeepLink(uri.toString(), context);
        }
      },
      onError: (err) {
        debugPrint('❌ Deep link error: $err');
      },
    );
  }

  /// Xử lý deep link
  void _handleDeepLink(String link, BuildContext context) {
    debugPrint('🔗 Deep link received: $link');

    try {
      final uri = Uri.parse(link);

      // Kiểm tra xem là confirmation link không
      if (uri.scheme == 'mediminder' && uri.host == 'auth') {
        final type = uri.queryParameters['type'];
        final email = uri.queryParameters['email'];

        if (type == 'email_change' || type == 'signup') {
          debugPrint('✅ Email verification link detected');
          // Supabase sẽ tự động xác nhận khi người dùng nhấp link
        } else if (type == 'recovery') {
          debugPrint('✅ Password recovery link detected');
          if (context.mounted) {
            Navigator.pushNamed(
              context,
              '/create-new-password',
              arguments: email,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error parsing deep link: $e');
    }
  }
}
