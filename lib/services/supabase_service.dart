import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/constants.dart';

/// Service quản lý kết nối và các thao tác với Supabase
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  late SupabaseClient _client;

  SupabaseClient get client => _client;

  /// Khởi tạo Supabase
  Future<void> initialize() async {
    _client = SupabaseClient(
      AppConstants.SUPABASE_URL,
      AppConstants.SUPABASE_ANON_KEY,
    );
  }

  // ==================== AUTHENTICATION ====================

  /// Đăng ký tài khoản mới
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  /// Đăng nhập
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Đăng xuất
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Lấy user hiện tại
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  /// Kiểm tra session có hợp lệ không
  Future<bool> isAuthenticated() async {
    final session = _client.auth.currentSession;
    return session != null;
  }

  // ==================== DATABASE OPERATIONS ====================

  /// Lấy dữ liệu từ bảng
  Future<List<dynamic>> getFromTable(String tableName) async {
    return await _client.from(tableName).select();
  }

  /// Thêm dữ liệu vào bảng
  Future<dynamic> insertIntoTable(
    String tableName,
    Map<String, dynamic> data,
  ) async {
    return await _client.from(tableName).insert(data).select();
  }

  /// Cập nhật dữ liệu
  Future<dynamic> updateInTable(
    String tableName,
    Map<String, dynamic> data,
    String columnName,
    dynamic columnValue,
  ) async {
    return await _client
        .from(tableName)
        .update(data)
        .eq(columnName, columnValue)
        .select();
  }

  /// Xóa dữ liệu
  Future<void> deleteFromTable(
    String tableName,
    String columnName,
    dynamic columnValue,
  ) async {
    await _client.from(tableName).delete().eq(columnName, columnValue);
  }

  // ==================== STORAGE OPERATIONS ====================

  /// Upload file lên Supabase Storage
  Future<String> uploadFile({
    required String bucketName,
    required String filePath,
    required String fileName,
  }) async {
    try {
      await _client.storage.from(bucketName).upload(fileName, File(filePath));

      // Lấy public URL
      final String publicUrl = _client.storage
          .from(bucketName)
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  /// Download file từ Supabase Storage
  Future<void> downloadFile({
    required String bucketName,
    required String fileName,
    required String savePath,
  }) async {
    try {
      final data = await _client.storage.from(bucketName).download(fileName);
      // Lưu file
      File(savePath).writeAsBytesSync(data);
    } catch (e) {
      throw Exception('Download failed: $e');
    }
  }
}
