# ✅ QUICK START - Cloudinary & Supabase

## 🎯 Những gì đã cài đặt:

✅ Dependencies trong `pubspec.yaml`:
- `supabase_flutter: ^2.10.3` - Kết nối database
- `http: ^1.6.0` - Upload ảnh lên Cloudinary
- `image_picker: ^1.2.1` - Chọn ảnh từ camera/gallery
- `flutter_secure_storage: ^9.2.4` - Lưu credentials an toàn
- `shared_preferences: ^2.5.3` - Lưu dữ liệu local
- `provider: ^6.1.2` - Quản lý state

✅ Files đã tạo:
- `lib/config/constants.dart` - Cấu hình credentials
- `lib/services/supabase_service.dart` - Quản lý Supabase
- `lib/services/cloudinary_service.dart` - Quản lý upload ảnh
- `lib/providers/app_provider.dart` - Provider cho auth & image upload
- `lib/widgets/image_upload_widget.dart` - Widget upload ảnh ví dụ
- `SETUP_GUIDE.md` - Hướng dẫn chi tiết

---

## 🔑 Bước tiếp theo (CẬP CẬP CREDENTIALS):

### 1. Vào `lib/config/constants.dart` và cập nhật:

```dart
// SUPABASE
static const String SUPABASE_URL = 'https://YOUR_PROJECT_ID.supabase.co';
static const String SUPABASE_ANON_KEY = 'YOUR_ANON_KEY_HERE';

// CLOUDINARY
static const String CLOUDINARY_CLOUD_NAME = 'YOUR_CLOUD_NAME';
static const String CLOUDINARY_UPLOAD_PRESET = 'YOUR_UPLOAD_PRESET';
```

### 2. Lấy credentials:

**Supabase:**
- Đi đến: https://app.supabase.com
- Project Settings → API → Copy URL & Anon Key

**Cloudinary:**
- Đi đến: https://cloudinary.com/console
- Copy Cloud Name
- Upload → Upload presets → Tạo preset "mediminder_preset"

### 3. Thử upload ảnh:
```dart
// Ở bất kỳ screen nào:
final imageProvider = context.read<ImageUploadProvider>();
imageProvider.uploadImage('/path/to/image.jpg');
```

---

## 📝 Ví dụ sử dụng:

### Đăng nhập:
```dart
await context.read<AuthProvider>().signIn(
  email: 'user@gmail.com',
  password: 'password123',
);
```

### Lấy dữ liệu từ database:
```dart
final supabase = SupabaseService().client;
final users = await supabase.from('users').select();
```

### Upload ảnh:
```dart
final imageProvider = context.read<ImageUploadProvider>();
bool success = await imageProvider.uploadImage(imagePath);
if (success) {
  final url = imageProvider.uploadedImageUrl;
  print('Ảnh upload thành công: $url');
}
```

---

## ⚠️ QUAN TRỌNG:

1. **Không** commit `constants.dart` lên GitHub nếu có credentials thực
2. **Dùng .env file** để quản lý credentials (xem SETUP_GUIDE.md)
3. **Upload preset** phải là "Unsigned" mode ở Cloudinary
4. **Enable RLS** trên Supabase tables để bảo mật dữ liệu

---

## 🆘 Gặp lỗi?

Xem chi tiết ở `SETUP_GUIDE.md` phần **TROUBLESHOOTING**
