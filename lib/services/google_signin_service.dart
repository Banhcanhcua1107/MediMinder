import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/constants.dart';

/// Service quản lý Google Sign In authentication
class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();

  factory GoogleSignInService() {
    return _instance;
  }

  GoogleSignInService._internal();

  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
  );

  final _supabaseClient = Supabase.instance.client;

  /// Đăng nhập với Google
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No access token for user ${googleUser.email}';
      }
      if (idToken == null) {
        throw 'No ID token for user ${googleUser.email}';
      }

      // Đăng nhập/đăng ký với Supabase
      final response = await _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return response;
    } catch (e) {
      print('Google sign in error: $e');
      rethrow;
    }
  }

  /// Đăng xuất Google
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      await _supabaseClient.auth.signOut();
    } catch (e) {
      print('Google sign out error: $e');
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
