/// Cloudinary Configuration
/// Thay đổi giá trị dưới đây bằng thông tin của bạn từ https://cloudinary.com
class CloudinaryConfig {
  /// Lấy từ Cloudinary Dashboard > Settings > Cloud name
  static const String cloudName = 'YOUR_CLOUD_NAME';

  /// Upload preset (create unsigned upload preset trong Cloudinary)
  /// Cloudinary Dashboard > Settings > Upload > Add upload preset
  static const String uploadPreset = 'YOUR_UPLOAD_PRESET';

  /// API Key (optional, chỉ cần nếu dùng signed uploads)
  static const String apiKey = 'YOUR_API_KEY';

  /// Folder để lưu avatar trên Cloudinary
  static const String avatarFolder = 'mediminder/avatars';

  /// Kích thước avatar sau khi upload
  static const int avatarWidth = 300;
  static const int avatarHeight = 300;
}
