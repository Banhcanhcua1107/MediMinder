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
    scopes: [
      'openid', // Đặt openid lên đầu
      'email',
      'profile',
    ],
    serverClientId:
        'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com', // ← Thêm cái này!
  );

  final _supabaseClient = Supabase.instance.client;

  /// Đăng nhập với Google
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      debugPrint('🔐 Starting Google Sign In...');

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled by user');
      }

      debugPrint('📱 Google user signed in: ${googleUser.email}');

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      debugPrint('🔑 Access Token: ${accessToken?.substring(0, 20)}...');
      debugPrint('🔑 ID Token: ${idToken?.substring(0, 20) ?? "NULL"}...');

      if (accessToken == null) {
        throw Exception('No access token for user ${googleUser.email}');
      }
      if (idToken == null) {
        throw Exception(
          'No ID token for user ${googleUser.email}\n\nFix: Check Google Cloud Console OAuth consent screen',
        );
      }

      debugPrint('🌐 Sending to Supabase...');

      // Đăng nhập/đăng ký với Supabase
      final response = await _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      debugPrint('✅ Supabase sign in successful: ${response.user?.email}');
      return response;
    } catch (e) {
      debugPrint('❌ Google sign in error: $e');
      rethrow;
    }
  }

  /// Đăng xuất Google
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      await _supabaseClient.auth.signOut();
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
