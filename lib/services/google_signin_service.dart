import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service quản lý Google Sign In authentication
class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();

  factory GoogleSignInService() {
    return _instance;
  }

  GoogleSignInService._internal();

  final _googleSignIn = GoogleSignIn(
    scopes: ['openid', 'email', 'profile'],
    // Sử dụng Web Client ID để fix error 12500
    serverClientId:
        '426495788921-p8h4imo4ord7ktogg5obn67p3vlo25f4.apps.googleusercontent.com',
  );

  final _supabaseClient = Supabase.instance.client;

  /// Đăng nhập với Google qua Supabase OAuth (khỏi cần setup Google Play Services)
  Future<void> signInWithGoogle() async {
    try {
      debugPrint('🔐 Starting Supabase OAuth with Google...');

      // Dùng Supabase OAuth redirect - không cần Google Play Services
      await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.mediminder.app://login-callback/',
      );

      debugPrint('✅ Supabase OAuth initiated');
    } catch (e) {
      debugPrint('❌ Supabase OAuth error: $e');
      rethrow;
    }
  }

  /// Đăng xuất Google hoàn toàn (disconnect)
  Future<void> signOutGoogle() async {
    try {
      // disconnect() sẽ xóa token và logout hoàn toàn
      await _googleSignIn.disconnect();
      await _supabaseClient.auth.signOut();
      debugPrint('✅ Google disconnected and Supabase signed out');
    } catch (e) {
      debugPrint('Google sign out error: $e');
      rethrow;
    }
  }

  /// Lấy thông tin Google user hiện tại
  GoogleSignInAccount? getCurrentGoogleUser() {
    return _googleSignIn.currentUser;
  }

  /// Kiểm tra user đã signed in Google chưa
  Future<bool> isGoogleSignedIn() async {
    final isSignedIn = await _googleSignIn.isSignedIn();
    return isSignedIn;
  }
}
