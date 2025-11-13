# 🔧 Hướng dẫn Kết nối Cloudinary và Supabase

## 1️⃣ SUPABASE - Thiết lập cơ sở dữ liệu

### Bước 1.1: Tạo tài khoản Supabase
- Truy cập: https://supabase.com
- Click **Sign Up** → Đăng nhập bằng GitHub hoặc Email

### Bước 1.2: Tạo Project mới
1. Click **New Project**
2. Chọn Organization hoặc tạo mới
3. Nhập tên project: `mediminder`
4. Chọn Region gần nhất (VN: Singapore)
5. Nhập Database Password (lưu giữ cẩn thận!)
6. Click **Create new project** (chờ khoảng 2-3 phút)

### Bước 1.3: Lấy API Keys
1. Vào **Project Settings** (⚙️ icon)
2. Chọn tab **API**
3. Copy những thông tin này:
   - **Project URL** → `SUPABASE_URL`
   - **anon public** (under Project API Keys) → `SUPABASE_ANON_KEY`

### Bước 1.4: Cập nhật vào constants.dart
```dart
// lib/config/constants.dart
static const String SUPABASE_URL = 'https://YOUR_PROJECT_ID.supabase.co';
static const String SUPABASE_ANON_KEY = 'YOUR_ANON_KEY_HERE';
```

### Bước 1.5: Tạo bảng cơ sở dữ liệu (tuỳ chọn)
Ví dụ tạo bảng **users**:
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policy cho phép user xem dữ liệu của chính họ
CREATE POLICY "Users can view own data" ON users
  FOR SELECT USING (auth.uid() = id);
```

---

## 2️⃣ CLOUDINARY - Thiết lập upload ảnh

### Bước 2.1: Tạo tài khoản Cloudinary
- Truy cập: https://cloudinary.com
- Click **Sign Up** → Chọn **Free** plan
- Hoàn thành thông tin (Email, Password)

### Bước 2.2: Lấy Cloud Name
1. Vào **Dashboard**
2. Tìm phần **API Environment** ở phía trên
3. Copy **Cloud name** → Dùng cho `CLOUDINARY_CLOUD_NAME`

### Bước 2.3: Lấy API Keys
1. Click **Settings** (⚙️)
2. Chọn tab **API Keys**
3. Copy:
   - **API Key** → `CLOUDINARY_API_KEY`
   - **API Secret** → `CLOUDINARY_API_SECRET` (⚠️ GIỮ BÍ MẬT!)

### Bước 2.4: Tạo Upload Preset
1. Vào **Settings** → Tab **Upload**
2. Scroll xuống tìm **Upload presets**
3. Click **Add upload preset**
4. Nhập:
   - **Name**: `mediminder_preset`
   - **Signing Mode**: Unsigned (để không cần API secret ở frontend)
   - **Folder**: `mediminder` (tuỳ chọn)
5. Click **Save**

### Bước 2.5: Cập nhật vào constants.dart
```dart
// lib/config/constants.dart
static const String CLOUDINARY_CLOUD_NAME = 'YOUR_CLOUD_NAME';
static const String CLOUDINARY_API_KEY = 'YOUR_API_KEY';
static const String CLOUDINARY_API_SECRET = 'YOUR_API_SECRET'; // Không dùng ở frontend!
static const String CLOUDINARY_UPLOAD_PRESET = 'mediminder_preset';
```

---

## 3️⃣ CÀI ĐẶT DEPENDENCIES

Chạy lệnh:
```bash
flutter pub get
```

---

## 4️⃣ SỬ DỤNG TRONG CODE

### Ví dụ 1: Đăng nhập
```dart
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';

// Ở Widget:
context.read<AuthProvider>().signIn(
  email: 'user@example.com',
  password: 'password123',
);
```

### Ví dụ 2: Upload ảnh
```dart
final imageProvider = context.read<ImageUploadProvider>();
await imageProvider.uploadImage('/path/to/image.jpg');

// Lấy URL ảnh
final imageUrl = imageProvider.uploadedImageUrl;
```

### Ví dụ 3: Lấy dữ liệu từ Supabase
```dart
final supabase = SupabaseService().client;
final data = await supabase
  .from('users')
  .select()
  .eq('email', 'user@example.com');
```

---

## 5️⃣ ENV VARIABLES (Bảo mật)

### Tạo file .env
```
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_ANON_KEY=YOUR_ANON_KEY
CLOUDINARY_CLOUD_NAME=YOUR_CLOUD_NAME
CLOUDINARY_UPLOAD_PRESET=mediminder_preset
```

### Sử dụng dotenv package
Thêm vào pubspec.yaml:
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

Tạo file `lib/config/env.dart`:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static final String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  static final String supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static final String cloudinaryName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static final String cloudinaryPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
}
```

Trong main.dart:
```dart
await dotenv.load(fileName: ".env");
```

### Thêm .env vào .gitignore
```
.env
.env.local
```

---

## ⚠️ BẢO MẬT

1. **KHÔNG bao giờ** commit `constants.dart` nếu có credentials thực
2. **KHÔNG bao giờ** để `CLOUDINARY_API_SECRET` ở frontend
3. Dùng **Upload Preset** (unsigned mode) cho frontend upload
4. Dùng **.env** file để quản lý credentials
5. Enable **Row Level Security (RLS)** trên Supabase database

---

## 🆘 TROUBLESHOOTING

### Lỗi: "Target of URI doesn't exist"
→ Chạy `flutter pub get`

### Upload ảnh không thành công
→ Kiểm tra Upload Preset có tồn tại không
→ Kiểm tra Cloud Name có đúng không

### Supabase không connect
→ Kiểm tra URL và API Key
→ Kiểm tra internet connection
→ Xem logs: `flutter logs`

---

## 📚 Tài liệu tham khảo
- Supabase Flutter: https://supabase.com/docs/reference/flutter/introduction
- Cloudinary: https://cloudinary.com/documentation
- Provider package: https://pub.dev/packages/provider
