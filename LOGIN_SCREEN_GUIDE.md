# 📱 Login Screen - Figma Design Implementation

## ✅ Những gì đã cập nhật

### 🎨 Thiết kế từ Figma
- **Tiêu đề**: "Welcome back! Glad to see you, Again!" (màu xanh #196EB0)
- **Email input**: Placeholder "Enter your email" với border xám nhạt
- **Password input**: Placeholder "Enter your password" + icon mắt để hiển thị/ẩn mật khẩu
- **Login button**: Nút xanh #196EB0 full width
- **Forgot Password**: Link xanh ở góc trên phải
- **Divider**: "Or" line divider
- **Google button**: Nút trắng với border, icon Google, text "Continue with Google"
- **Sign up link**: "Don't have an account? Register" (Register màu xanh)

---

## 🔄 Các tính năng

### 1️⃣ Back Button (Đã thiết kế)
```dart
Container(
  height: 41,
  width: 41,
  decoration: BoxDecoration(
    color: Colors.white,
    border: Border.all(color: const Color(0xFFE8ECF4)),
    borderRadius: BorderRadius.circular(12),
  ),
  child: IconButton(...),
)
```

### 2️⃣ Email & Password Inputs
- Các input có background xám nhạt (#F7F8F9)
- Border xám (#E8ECF4)
- Border radius: 8px
- Placeholder text màu #8391A1

### 3️⃣ Password Visibility Toggle
```dart
suffixIcon: GestureDetector(
  onTap: () {
    setState(() {
      _showPassword = !_showPassword;
    });
  },
  child: Icon(Icons.visibility / Icons.visibility_off),
)
```

### 4️⃣ Login Button với Loading State
```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    return ElevatedButton(
      onPressed: authProvider.isLoading ? null : _handleLogin,
      child: authProvider.isLoading 
          ? CircularProgressIndicator()
          : Text('Login'),
    );
  },
)
```

### 5️⃣ Google Login Integration
```dart
ElevatedButton.icon(
  icon: Image.network('https://www.figma.com/api/mcp/asset/...'),
  label: const Text('Continue with Google'),
)
```

---

## 🎯 Màu sắc (Colors)

| Tên | Hex | Dùng cho |
|-----|-----|---------|
| Primary Blue | #196EB0 | Tiêu đề, button, links |
| Dark Text | #1E232C | Văn bản chính |
| Gray Text | #8391A1 | Placeholder, hint |
| Border Gray | #E8ECF4 | Border input |
| Background | #F7F8F9 | Input background |
| Dark Gray | #6A707C | Text "Or" |

---

## 📝 Các hàm chính

### `_handleLogin()`
```dart
// Validate email & password
// Call AuthProvider.signIn()
// Nếu thành công → Navigate to /home
// Nếu thất bại → Show SnackBar error
```

### `_handleGoogleLogin()`
```dart
// TODO: Implement Google authentication
// Có thể dùng google_sign_in package
```

---

## 🚀 Cách sử dụng

### 1. Chạy app
```bash
flutter run
```

### 2. Cấu hình Supabase credentials
Cập nhật `lib/config/constants.dart`:
```dart
static const String SUPABASE_URL = 'YOUR_URL';
static const String SUPABASE_ANON_KEY = 'YOUR_KEY';
```

### 3. Login
- Nhập email/password
- Click "Login"
- Nếu thành công → Điều hướng đến `/home`

### 4. Google Login (TODO)
- Cần thêm package: `google_sign_in`
- Cấu hình OAuth credentials trên Google Cloud Console

---

## 📦 Packages được dùng

- `provider: ^6.1.2` - State management
- `supabase_flutter: ^2.10.3` - Authentication & Database

---

## ⚠️ TODO - Cần hoàn thành

- [ ] Implement Google Login (google_sign_in package)
- [ ] Implement Forgot Password screen
- [ ] Email validation
- [ ] Password strength validation
- [ ] Remember me checkbox (tuỳ chọn)

---

## 🎨 Design Tokens

```dart
// Colors
const Color primaryBlue = Color(0xFF196EB0);
const Color darkText = Color(0xFF1E232C);
const Color grayText = Color(0xFF8391A1);
const Color borderGray = Color(0xFFE8ECF4);
const Color bgGray = Color(0xFFF7F8F9);

// Typography
const double titleFontSize = 30;
const FontWeight titleFontWeight = FontWeight.bold;

// Spacing
const double inputHeight = 56;
const double borderRadius = 8;
```
