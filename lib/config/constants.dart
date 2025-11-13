/// File chứa các hằng số cấu hình cho Cloudinary và Supabase
///
/// PHƯƠNG PHÁP TỪ .env (KHUYẾN NGHỊ):
/// 1. Tạo file lib/.env từ .env.example
/// 2. Điền SUPABASE_URL và SUPABASE_ANON_KEY
/// 3. Thêm flutter_dotenv vào pubspec.yaml
/// 4. Load trong main.dart: await dotenv.load(fileName: "lib/.env");
/// 5. Sử dụng AppConstants.supabaseUrl thay cho AppConstants.SUPABASE_URL
///
/// PHƯƠNG PHÁP TỪ HỌC (CHỈ ĐỂ DEVELOPMENT):
/// - Điền trực tiếp vào SUPABASE_URL_HARDCODED
/// - CẢNH BÁO: Đừng commit credentials lên GitHub!

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // ==================== SUPABASE CONFIG ====================

  /// PHƯƠNG PHÁP 1: Load từ .env file (Khuyến nghị ⭐)
  /// Bước 1: Copy lib/.env.example → lib/.env
  /// Bước 2: Edit lib/.env với credentials từ Supabase
  /// Bước 3: Chạy: flutter pub get
  /// Bước 4: Chạy app: flutter run

  static String get supabaseUrl {
    String? url;

    try {
      url = dotenv.env['SUPABASE_URL'];
    } catch (e) {
      // If dotenv is not initialized, url stays null
      url = null;
    }

    // Fallback to hardcoded value for development
    if (url == null || url.isEmpty) {
      url = SUPABASE_URL_HARDCODED;
    }

    // If still empty, throw error
    if (url.isEmpty || url == 'YOUR_SUPABASE_URL') {
      throw Exception('''
        ❌ SUPABASE_URL not configured!
        
        SOLUTIONS:
        1. Create file: lib/.env
        2. Copy from: lib/.env.example
        3. Fill credentials from: https://app.supabase.com/projects > Settings > API
        4. Run: flutter pub get && flutter run
        
        OR for quick testing (not recommended):
        - Edit: lib/config/constants.dart
        - Change: SUPABASE_URL_HARDCODED = 'your-url-here'
        ''');
    }

    return url;
  }

  /// Supabase Anon Key từ .env
  /// Lấy từ: https://app.supabase.com > Settings > API > Project API Keys > anon (public key)
  static String get supabaseAnonKey {
    String? key;

    try {
      key = dotenv.env['SUPABASE_ANON_KEY'];
    } catch (e) {
      // If dotenv is not initialized, key stays null
      key = null;
    }

    // Fallback to hardcoded value for development
    if (key == null || key.isEmpty) {
      key = SUPABASE_ANON_KEY_HARDCODED;
    }

    // If still empty, throw error
    if (key.isEmpty || key == 'YOUR_SUPABASE_ANON_KEY') {
      throw Exception('''
        ❌ SUPABASE_ANON_KEY not configured!
        
        SOLUTIONS:
        1. Create file: lib/.env
        2. Copy from: lib/.env.example
        3. Fill credentials from: https://app.supabase.com/projects > Settings > API
        4. Run: flutter pub get && flutter run
        
        OR for quick testing (not recommended):
        - Edit: lib/config/constants.dart
        - Change: SUPABASE_ANON_KEY_HARDCODED = 'your-key-here'
        ''');
    }

    return key;
  }

  // ==================== PHƯƠNG PHÁP 2: Hardcode (DEVELOPMENT ONLY) ====================
  /// ⚠️ CHỈ DÙNG ĐỂ TEST NHANH - KHÔNG COMMIT LÊN GITHUB!
  ///
  /// Nếu bạn muốn test nhanh mà không muốn tạo .env:
  /// 1. Lấy URL từ: https://app.supabase.com/projects > Settings > API
  /// 2. Paste vào dưới đây (thay thế YOUR_SUPABASE_URL)
  /// 3. Lấy Anon Key từ: Settings > API > Project API Keys > anon
  /// 4. Paste vào dưới đây (thay thế YOUR_SUPABASE_ANON_KEY)

  static const String SUPABASE_URL_HARDCODED =
      'https://vdcgpyuebfopwfsalkzr.supabase.co';
  static const String SUPABASE_ANON_KEY_HARDCODED =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZkY2dweXVlYmZvcHdmc2Fsa3pyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4NDQzNDEsImV4cCI6MjA3ODQyMDM0MX0.f3iU--it-IFnTI5xcKahpKgV6u291xknHcPVwDrnOkI';

  // ==================== CLOUDINARY CONFIG ====================
  /// Cloudinary Cloud Name
  /// Lấy từ: https://cloudinary.com/console/settings/account
  static const String CLOUDINARY_CLOUD_NAME = 'dgl8p7xqo';

  /// Cloudinary API Key (chỉ dùng cho backend)
  static const String CLOUDINARY_API_KEY = 'YOUR_CLOUDINARY_API_KEY';

  /// Cloudinary API Secret (chỉ dùng cho backend, KHÔNG dùng ở frontend)
  static const String CLOUDINARY_API_SECRET = 'YOUR_CLOUDINARY_API_SECRET';

  /// Cloudinary Upload Preset (tạo ở Cloudinary console)
  static const String CLOUDINARY_UPLOAD_PRESET = 'ml_default';

  // ==================== API ENDPOINTS ====================
  static const String API_BASE_URL = 'https://api.example.com';
}
