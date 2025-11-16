# 🔐 Fix Lỗi "No ID Token" - Google Sign-In + Supabase

## 🚨 Lỗi Hiện Tại

```
Exception: No ID token for user haidagnakar11@gmail.com
Fix: Check Google Cloud Console OAuth consent screen
```

---

## 🔍 **Nguyên Nhân**

Google không trả ID Token vì:
1. ❌ Email chưa add vào **Test users**
2. ❌ OAuth Consent Screen ở **"Testing" mode**
3. ❌ Scopes không đủ (thiếu `openid`)

---

## ✅ **Fix Chi Tiết (3 Cách)**

---

## **CÁCH 1: Add Test User (Nhanh Nhất - 2 phút)**

### Nếu bạn chỉ test với 1-2 email → Dùng cách này

### **Bước 1: Vào Google Cloud Console**

```
https://console.cloud.google.com/apis/consent
```

### **Bước 2: Add Test User**

1. Scroll xuống → Tìm **"Test users"** section

```
┌─────────────────────────────────────┐
│         Test users                  │
│                                     │
│  [+ Add users]                      │
│                                     │
│  User information                   │
│  No rows to display                 │
└─────────────────────────────────────┘
```

2. Click **"+ Add users"**

```
┌──────────────────────────────────┐
│  Add users                       │
│                                  │
│  Email addresses:                │
│  ┌──────────────────────────────┐│
│  │ haidagnakar11@gmail.com    │ ││
│  └──────────────────────────────┘│
│                                  │
│  [Add]  [Cancel]                 │
└──────────────────────────────────┘
```

3. Paste email: `haidagnakar11@gmail.com`
4. Click **"Add"**

### **Bước 3: Chờ Sync**

- Chờ 30 giây - 1 phút
- Google cập nhật test users

### **Bước 4: Test Lại**

```powershell
flutter run
```

- Click "Đăng Nhập Google"
- Chọn: `haidagnakar11@gmail.com`
- ✅ ID Token sẽ được lấy

---

## **CÁCH 2: Publish App (Khuyến Nghị - 5 phút)**

### Nếu bạn muốn tất cả users có thể đăng nhập → Dùng cách này

### **Bước 1: Vào OAuth Consent Screen**

```
https://console.cloud.google.com/apis/consent
```

### **Bước 2: Click "PUBLISH APP"**

```
┌──────────────────────────────────────────┐
│ Google Auth Platform / Audience          │
│                                          │
│ User type: External                      │
│ Publishing status: [Testing]             │
│                      ↓                   │
│              [PUBLISH APP] ← Click này   │
└──────────────────────────────────────────┘
```

### **Bước 3: Chọn Production**

```
┌──────────────────────────────────┐
│  Ready to publish?               │
│                                  │
│  Release to: [Production]        │
│            or [Internal]         │
│                                  │
│  [PUBLISH] [CANCEL]              │
└──────────────────────────────────┘
```

- Chọn **"Production"**
- Click **"PUBLISH"**

### **Bước 4: Chờ Cập Nhật**

- Chờ ~5 phút
- Google cập nhật consent

### **Bước 5: Test Lại**

```powershell
flutter run
```

- Click "Đăng Nhập Google"
- Chọn **bất kỳ email nào** (không cần test user)
- ✅ Sẽ hoạt động!

---

## **CÁCH 3: Thêm Scopes (Backup - 3 phút)**

### Nếu vẫn "No ID Token" sau Cách 1 hoặc 2 → Kiểm tra scopes

### **Bước 1: Vào OAuth Consent Screen**

```
https://console.cloud.google.com/apis/consent
```

### **Bước 2: Click "EDIT APP"**

```
┌──────────────────────────────────────────┐
│ Audience                                 │
│ Editing app: MediMinder                  │
│                                          │
│ [EDIT APP] ← Click này                   │
└──────────────────────────────────────────┘
```

### **Bước 3: Scroll xuống Scopes**

Tìm section: **"Scopes"**

### **Bước 4: Click "ADD OR REMOVE SCOPES"**

```
┌──────────────────────────────────────────┐
│ Scopes                                   │
│                                          │
│ Selected scopes: (none)                  │
│                                          │
│ [ADD OR REMOVE SCOPES] ← Click này       │
└──────────────────────────────────────────┘
```

### **Bước 5: Thêm Required Scopes**

Tìm & check các scope này:

```
☑️ openid
☑️ email
☑️ profile
☑️ https://www.googleapis.com/auth/userinfo.profile
```

**Cách tìm:** Search bar → gõ từng scope

### **Bước 6: Save**

- Click **"UPDATE"** hoặc **"Save"**
- Chờ cập nhật

### **Bước 7: Test Lại**

```powershell
flutter clean
flutter pub get
flutter run
```

---

## 🧪 **Testing - Kiểm Tra Logs**

### Khi chạy `flutter run`, xem logs:

#### ✅ **Thành Công:**
```
🔐 Starting Google Sign In...
📱 Google user signed in: haidagnakar11@gmail.com
🔑 Access Token: eyJhbGc...
🔑 ID Token: eyJhbGc...
🌐 Sending to Supabase...
✅ Supabase sign in successful: haidagnakar11@gmail.com
🚀 Navigating to /home...
```

#### ❌ **Lỗi - No ID Token:**
```
🔐 Starting Google Sign In...
📱 Google user signed in: haidagnakar11@gmail.com
🔑 Access Token: eyJhbGc...
🔑 ID Token: NULL
❌ Exception: No ID token for user haidagnakar11@gmail.com
```

→ Làm lại Cách 1 hoặc 2

---

## 📊 **So Sánh 3 Cách**

| Cách | Thời Gian | Ai Dùng Được | Khi Nào Dùng |
|------|-----------|-------------|------------|
| **1. Add Test User** | 2 phút | Chỉ test users | Dev/Debug |
| **2. Publish App** | 5 phút | Tất cả users | Production |
| **3. Thêm Scopes** | 3 phút | Tùy mode | Nếu vẫn lỗi |

**Recommend: Cách 2** (Publish App) → Cho production-ready

---

## ✅ **Checklist - Khi Nào Done?**

- [ ] **Cách 1 HOẶC Cách 2** được hoàn thành
- [ ] Logs hiển thị: ✅ Supabase sign in successful
- [ ] Auto-navigate sang Home Screen
- [ ] Vào Supabase Dashboard → Xem user trong `auth.users`

---

## 🔗 **Xem Dữ Liệu Trong Supabase**

Sau khi đăng nhập thành công:

### **1. Vào Supabase Dashboard**
```
https://app.supabase.com
```

### **2. Chọn project MediMinder**

### **3. Menu trái → Authentication → Users**

### **4. Kiểm tra user:**

```
Email: haidagnakar11@gmail.com
Provider: google
User ID: (từ Google)
User Metadata:
  - name: (tên từ Google)
  - picture: (avatar URL)
  - email: haidagnakar11@gmail.com
```

✅ **Nếu thấy user → Google Sign-In + Supabase đã hoạt động!**

---

## 🎯 **Flow Hoàn Chỉnh**

```
1. User click "Đăng Nhập Google"
   ↓
2. Google dialog xuất hiện
   ↓
3. User chọn email → Xác nhận
   ↓
4. App gửi yêu cầu tới Google
   ↓
5. Google trả: Access Token + ID Token
   ↓
6. App gửi tokens tới Supabase
   ↓
7. Supabase xác thực & tạo user
   ↓
8. App lấy JWT Token từ Supabase
   ↓
9. ✅ Auto-navigate sang Home Screen
   ↓
10. User được lưu trong Supabase DB
```

---

## 💡 **Tips & Troubleshooting**

### **Q: Chọn Cách Nào?**

```
Nếu: Test với 1-2 email → Cách 1 (Add Test User)
Nếu: Production / Nhiều user → Cách 2 (Publish App)
Nếu: Vẫn lỗi sau 1-2 → Cách 3 (Thêm Scopes)
```

### **Q: Mất bao lâu để cập nhật?**

```
Cách 1: 30 giây - 1 phút
Cách 2: 5 phút (sau khi click Publish)
Cách 3: 1-2 phút (sau khi save scopes)
```

### **Q: Làm sao biết đã fix xong?**

```
✅ Logs hiển thị: "Supabase sign in successful"
✅ Auto-navigate sang Home
✅ Thấy user trong Supabase auth.users
```

### **Q: Vẫn lỗi sau khi làm?**

```
1. flutter clean && flutter pub get
2. Uninstall app khỏi emulator
3. flutter run lại
4. Thử email khác (hoặc logout & login lại)
```

---

## 📚 **Reference**

- [Google OAuth 2.0 Documentation](https://developers.google.com/identity/protocols/oauth2)
- [Supabase Google Auth](https://supabase.com/docs/guides/auth/social-login/auth-google)
- [Flutter google_sign_in](https://pub.dev/packages/google_sign_in)

---

## 🎓 **Kết Luận**

**Problem:** No ID Token = Google Consent Screen chưa config đúng

**Solution:** 
- ✅ **Option A:** Add test user (nhanh, dùng cho dev)
- ✅ **Option B:** Publish app (production-ready)

**Recommend:** **Cách 2 (Publish)** → Ready for real users! 🚀

---

**Bạn chọn cách nào? Báo kết quả khi done!** 💪
