# ✅ Checklist Kết nối Cloudinary & Supabase

## 📋 Cài đặt (Đã hoàn thành)

- [x] Thêm dependencies vào `pubspec.yaml`
- [x] Chạy `flutter pub get`
- [x] Tạo `lib/config/constants.dart` với placeholder credentials
- [x] Tạo `lib/services/supabase_service.dart` - Singleton service
- [x] Tạo `lib/services/cloudinary_service.dart` - Upload service
- [x] Tạo `lib/providers/app_provider.dart` - Provider classes
- [x] Cập nhật `lib/main.dart` để khởi tạo Supabase
- [x] Tạo `lib/widgets/image_upload_widget.dart` - Widget ví dụ
- [x] Tạo tài liệu hướng dẫn chi tiết

---

## 🔧 Cấu hình Cloudinary

### [ ] Bước 1: Tạo tài khoản
- Truy cập: https://cloudinary.com/users/register/free
- Đăng ký hoặc đăng nhập

### [ ] Bước 2: Lấy Cloud Name
- Vào Dashboard
- Tìm "API Environment"
- Copy **Cloud name**

### [ ] Bước 3: Tạo Upload Preset
- Settings → Upload
- Tìm "Upload presets"
- Click "Add upload preset"
- **Name**: `mediminder_preset`
- **Signing Mode**: Unsigned
- **Folder**: `mediminder`
- Save

### [ ] Bước 4: Cập nhật constants.dart
```dart
static const String CLOUDINARY_CLOUD_NAME = 'YOUR_CLOUD_NAME';
static const String CLOUDINARY_UPLOAD_PRESET = 'mediminder_preset';
```

---

## 🔐 Cấu hình Supabase

### [ ] Bước 1: Tạo tài khoản
- Truy cập: https://supabase.com
- Sign up hoặc sign in

### [ ] Bước 2: Tạo Project
- Click "New project"
- **Project name**: `mediminder`
- **Region**: Singapore (gần Việt Nam)
- Nhập Database Password
- Chờ 2-3 phút

### [ ] Bước 3: Lấy API Credentials
- Settings → API
- Copy:
  - **Project URL** → SUPABASE_URL
  - **anon public** → SUPABASE_ANON_KEY

### [ ] Bước 4: Cập nhật constants.dart
```dart
static const String SUPABASE_URL = 'https://YOUR_PROJECT.supabase.co';
static const String SUPABASE_ANON_KEY = 'YOUR_ANON_KEY';
```

### [ ] Bước 5: Tạo Tables (tuỳ chọn)
Trong Supabase SQL Editor, chạy:
```sql
-- Bảng profiles
CREATE TABLE profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = user_id);
```

---

## 🧪 Test Kết nối

### [ ] Test Supabase
```dart
// Ở main.dart, sau initialize:
final supabase = SupabaseService().client;
final data = await supabase.from('profiles').select().limit(1);
print('Supabase test: $data');
```

### [ ] Test Cloudinary
1. Thêm `ImageUploadWidget()` vào một screen
2. Chọn ảnh từ gallery
3. Kiểm tra ảnh upload thành công
4. Sao chép URL ảnh đã upload

### [ ] Test Authentication
```dart
// Đăng ký
await context.read<AuthProvider>().signUp(
  email: 'test@example.com',
  password: 'test123456',
);

// Đăng nhập
await context.read<AuthProvider>().signIn(
  email: 'test@example.com',
  password: 'test123456',
);
```

---

## 🚀 Deploy (Khi sẵn sàng)

### [ ] Bảo mật Credentials
- [ ] Tạo `.env` file (xem SETUP_GUIDE.md)
- [ ] Thêm `.env` vào `.gitignore`
- [ ] Dùng `flutter_dotenv` để load từ .env

### [ ] Kiểm tra bảo mật Supabase
- [ ] Enable Row Level Security (RLS) trên tất cả tables
- [ ] Thiết lập policies thích hợp
- [ ] Kiểm tra API keys không bị leak

### [ ] Kiểm tra bảo mật Cloudinary
- [ ] Dùng Upload Preset (unsigned mode)
- [ ] KHÔNG để API Secret ở frontend
- [ ] Kiểm tra folder permissions

### [ ] Testing trước release
- [ ] Test upload ảnh lớn (5MB+)
- [ ] Test offline mode
- [ ] Test với mạng chậm
- [ ] Test trên iOS & Android

---

## 📱 Cấu hình iOS & Android

### iOS
Thêm vào `ios/Runner/Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Ứng dụng cần truy cập thư viện ảnh để upload</string>
<key>NSCameraUsageDescription</key>
<string>Ứng dụng cần truy cập camera để chụp ảnh</string>
```

### Android
Kiểm tra `android/app/build.gradle` có:
```gradle
compileSdkVersion 33 // hoặc cao hơn
```

Thêm vào `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

---

## 🆘 Troubleshooting

### Lỗi: "Target of URI doesn't exist"
**Giải pháp:**
```bash
flutter clean
flutter pub get
```

### Lỗi: "403 Unauthorized" upload Cloudinary
**Kiểm tra:**
- [ ] Cloud Name có đúng không?
- [ ] Upload Preset có tồn tại không?
- [ ] Upload Preset có set "Unsigned" không?

### Lỗi: "Supabase not initialized"
**Giải pháp:**
```dart
// Đảm bảo main() là async
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService().initialize();
  runApp(...);
}
```

### Upload ảnh chậm
**Tối ưu:**
- Nén ảnh trước khi upload
- Dùng image_picker với `imageQuality`
- Kiểm tra kết nối internet

---

## 📚 Tài liệu tham khảo

- [Supabase Docs](https://supabase.com/docs)
- [Cloudinary Docs](https://cloudinary.com/documentation)
- [Flutter Provider Docs](https://pub.dev/packages/provider)
- [Image Picker Docs](https://pub.dev/packages/image_picker)

---

## ✨ Hoàn thành!

Khi bạn ticked tất cả các mục trên, bạn đã sẵn sàng:
- ✅ Upload ảnh lên Cloudinary
- ✅ Lưu dữ liệu vào Supabase
- ✅ Xác thực người dùng
- ✅ Quản lý state với Provider

Chúc bạn code vui vẻ! 🎉
