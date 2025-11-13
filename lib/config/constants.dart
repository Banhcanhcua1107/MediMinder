/// File chứa các hằng số cấu hình cho Cloudinary và Supabase
/// CẢNH BÁO: Đừng commit file này lên GitHub nếu có credentials thực

class AppConstants {
  // ==================== SUPABASE CONFIG ====================
  /// URL của Supabase project
  /// Lấy từ: https://app.supabase.com/projects
  static const String SUPABASE_URL = 'YOUR_SUPABASE_URL';

  /// Supabase Anon Key
  /// Lấy từ: Settings > API > Project API Keys
  static const String SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';

  // ==================== CLOUDINARY CONFIG ====================
  /// Cloudinary Cloud Name
  /// Lấy từ: https://cloudinary.com/console/settings/account
  static const String CLOUDINARY_CLOUD_NAME = 'YOUR_CLOUD_NAME';

  /// Cloudinary API Key (chỉ dùng cho backend)
  static const String CLOUDINARY_API_KEY = 'YOUR_CLOUDINARY_API_KEY';

  /// Cloudinary API Secret (chỉ dùng cho backend, KHÔNG dùng ở frontend)
  static const String CLOUDINARY_API_SECRET = 'YOUR_CLOUDINARY_API_SECRET';

  /// Cloudinary Upload Preset (tạo ở Cloudinary console)
  static const String CLOUDINARY_UPLOAD_PRESET = 'YOUR_UPLOAD_PRESET';

  // ==================== API ENDPOINTS ====================
  static const String API_BASE_URL = 'https://api.example.com';
}
