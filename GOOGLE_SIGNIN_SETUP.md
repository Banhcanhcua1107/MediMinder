# 🔐 Google Sign In Setup Guide

## 📋 Bước 1: Tạo Google Cloud Project

1. Truy cập: https://console.cloud.google.com
2. Click **Select a Project** → **New Project**
3. Nhập tên: `MediMinder`
4. Click **Create**

---

## 🔑 Bước 2: Tạo OAuth Credentials

### Cho Android:
1. Vào **Credentials** (trái menu)
2. Click **Create Credentials** → **OAuth client ID**
3. Chọn **Android**
4. Nhập:
   - **Name**: `MediMinder Android`
   - **SHA-1 certificate fingerprint**: 
     ```bash
     # Lấy bằng lệnh:
     keytool -list -v -keystore ~/.android/debug.keystore
     # Password mặc định: android
     # Lấy SHA1 fingerprint
     ```

### Cho iOS:
1. Click **Create Credentials** → **OAuth client ID**
2. Chọn **iOS**
3. Nhập:
   - **Name**: `MediMinder iOS`
   - **Bundle ID**: `com.mediminder.app` (từ ios/Runner.xcodeproj)

---

## 🚀 Bước 3: Cấu hình Flutter Project

### Android (`android/app/build.gradle`)
```gradle
dependencies {
    // Google Play services
    implementation 'com.google.android.gms:play-services-auth:20.8.1'
}
```

### iOS (`ios/Runner/Info.plist`)
Thêm:
```xml
<key>GIDClientID</key>
<string>YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com</string>
<key>GIDServerClientID</key>
<string>YOUR_SERVER_CLIENT_ID.apps.googleusercontent.com</string>
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR_GOOGLE_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

---

## 📱 Bước 4: Cấu hình Supabase cho Google OAuth

1. Vào Supabase Dashboard
2. **Settings** → **Authentication**
3. Chọn tab **Providers**
4. Click **Google**
5. Nhập:
   - **Client ID**: Từ Google Cloud Console
   - **Client Secret**: Từ Google Cloud Console
6. Enable → Save

---

## 🔧 Bước 5: Cập nhật Login Screen

```dart
Future<void> _handleGoogleLogin() async {
  try {
    final googleService = GoogleSignInService();
    final response = await googleService.signInWithGoogle();
    
    if (response != null && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Google login failed: $e')),
    );
  }
}
```

---

## 🧪 Test Google Sign In

```dart
// Ở main.dart hoặc startup code:
final googleService = GoogleSignInService();
final isSignedIn = await googleService.isGoogleSignedIn();
print('Google signed in: $isSignedIn');
```

---

## 🆘 Troubleshooting

### Lỗi: "10: DEVELOPER_ERROR"
→ SHA-1 fingerprint không đúng hoặc không được đăng ký

### Lỗi: "PERMISSION_DENIED"
→ Chưa enable Google Sign In ở Supabase Settings

### Lỗi: "invalid_client"
→ Client ID/Secret không đúng

### Lỗi: "Sign in with Google was cancelled"
→ User cancel, không cần xử lý

---

## 📚 Tài liệu tham khảo

- Google Sign In: https://pub.dev/packages/google_sign_in
- Supabase Google OAuth: https://supabase.com/docs/guides/auth/social-auth/auth-google
- Google Cloud Console: https://console.cloud.google.com
