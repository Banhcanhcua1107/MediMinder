import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/cloudinary_service.dart';

/// Provider quản lý trạng thái xác thực
class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  /// Đăng ký tài khoản mới
  Future<bool> signUp({required String email, required String password}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _supabaseService.signUp(email: email, password: password);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Đăng nhập
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _supabaseService.signIn(email: email, password: password);

      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    try {
      // Xóa session từ Supabase
      await _supabaseService.signOut();
      _isAuthenticated = false;
      notifyListeners();
      debugPrint('✅ User logged out and cache cleared');
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      debugPrint('❌ Logout error: $e');
    }
  }

  /// Kiểm tra xác thực
  Future<void> checkAuthentication() async {
    _isAuthenticated = await _supabaseService.isAuthenticated();
    notifyListeners();
  }
}

/// Provider quản lý upload ảnh
class ImageUploadProvider extends ChangeNotifier {
  final CloudinaryService _cloudinaryService = CloudinaryService();

  bool _isUploading = false;
  String? _uploadedImageUrl;
  String? _errorMessage;
  double _uploadProgress = 0.0;

  bool get isUploading => _isUploading;
  String? get uploadedImageUrl => _uploadedImageUrl;
  String? get errorMessage => _errorMessage;
  double get uploadProgress => _uploadProgress;

  /// Upload ảnh từ file
  Future<bool> uploadImage(String filePath) async {
    try {
      _isUploading = true;
      _errorMessage = null;
      _uploadProgress = 0.0;
      notifyListeners();

      final fileName = filePath.split('/').last;
      final url = await _cloudinaryService.uploadImage(
        filePath: filePath,
        fileName: fileName,
      );

      _uploadedImageUrl = url;
      _uploadProgress = 1.0;
      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isUploading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Upload ảnh từ URL
  Future<bool> uploadImageFromUrl(String imageUrl) async {
    try {
      _isUploading = true;
      _errorMessage = null;
      notifyListeners();

      final url = await _cloudinaryService.uploadImageFromUrl(
        imageUrl: imageUrl,
        fileName: 'image_${DateTime.now().millisecondsSinceEpoch}',
      );

      _uploadedImageUrl = url;
      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isUploading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Reset state
  void resetUploadState() {
    _isUploading = false;
    _uploadedImageUrl = null;
    _errorMessage = null;
    _uploadProgress = 0.0;
    notifyListeners();
  }
}
