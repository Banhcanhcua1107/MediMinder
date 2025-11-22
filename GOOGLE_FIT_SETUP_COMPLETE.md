# 🔧 Setup Google Fit & Google Cloud - Hướng dẫn Chi tiết

## ⚠️ Vấn đề Hiện tại
- App báo "✅ Đã lưu 0 dữ liệu thành công"
- Nghĩa là không lấy được data từ Google Fit
- **Nguyên nhân:** Chưa setup Google Cloud Project & API

---

## 📋 Bước 1: Tạo Google Cloud Project

### 1.1 Truy cập Google Cloud Console
1. Vào: https://console.cloud.google.com/
2. Đăng nhập bằng tài khoản Google
3. Click **"Create Project"** (hoặc chọn project cũ nếu có)

### 1.2 Điền thông tin Project
- **Project name:** `MediMinder` (hoặc tên bất kỳ)
- **Organization:** Bỏ trống nếu không có
- Click **CREATE**

---

## 🔑 Bước 2: Enable Google Fit API

### 2.1 Search & Enable API
1. Trong Google Cloud Console, search: **"Google Fit API"**
2. Khi thấy result, click vào
3. Click **ENABLE**
4. Chờ 1-2 phút để enable xong

### 2.2 Verify API Enabled
- Vào **APIs & Services** > **Enabled APIs and services**
- Nên thấy **"Google Fit API"** trong danh sách

---

## 📱 Bước 3: Setup OAuth 2.0 (Quan trọng!)

### 3.1 Tạo OAuth 2.0 Credentials
1. Vào **APIs & Services** > **Credentials**
2. Click **+ CREATE CREDENTIALS** > **OAuth 2.0 Client ID**
3. Nếu bị hỏi **"Configure OAuth consent screen first"** → Click **CONFIGURE CONSENT SCREEN**

### 3.2 Configure OAuth Consent Screen
**Step 1: OAuth Consent Screen**
- **User type:** Select "External"
- Click **CREATE**

**Step 2: Edit App Registration**
- **App name:** MediMinder
- **User support email:** Your email
- **Developer contact:** Your email
- Click **SAVE AND CONTINUE**

**Step 3: Scopes**
- Click **ADD OR REMOVE SCOPES**
- Search & add: **`https://www.googleapis.com/auth/fitness.activity.read`**
- Search & add: **`https://www.googleapis.com/auth/fitness.heart_rate.read`**
- Search & add: **`https://www.googleapis.com/auth/fitness.blood_glucose.read`**
- Click **UPDATE**
- Click **SAVE AND CONTINUE**

**Step 4: Test Users**
- Click **ADD USERS**
- Add your email: `haidangnakar11@gmail.com`
- Click **SAVE AND CONTINUE**

**Step 5: Review**
- Click **BACK TO DASHBOARD**

### 3.3 Tạo OAuth Client ID
1. Vào **Credentials** again
2. Click **+ CREATE CREDENTIALS** > **OAuth 2.0 Client ID**
3. **Application type:** Select "Android"
4. **Name:** MediMinder Android
5. **Package name:** `com.mediminder.app`

### 3.4 Lấy SHA-1 Certificate Fingerprint

**Chạy lệnh để lấy SHA-1:**
```bash
keytool -list -v -keystore C:\Users\haida\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Hoặc chạy từ Android Studio:**
1. Mở Android Studio
2. Vào **Gradle** tab (bên phải)
3. Run: `Tasks > android > signingReport`
4. Xem output → Copy **SHA1** value

**Paste SHA1 vào Google Cloud:**
- Trong **Create OAuth 2.0 Client ID** form
- Paste vào **SHA-1 certificate fingerprint** field
- Click **CREATE**

---

## 📲 Bước 4: Install Health Connect

### 4.1 Install từ Play Store
1. Trên thiết bị Android, mở Play Store
2. Search: **"Google Health Connect"**
3. Click **INSTALL**
4. Chờ install xong

### 4.2 Lại mở MediMinder app
1. Click **"Cài Health Connect"** button (nếu chưa cài)
2. Hoặc click **"Đồng Bộ Google Fit"**
3. Grant permissions when asked

---

## 🔍 Bước 5: Verify Setup Trong App

### 5.1 Kiểm tra Permission
Khi bấm **"Đồng Bộ Google Fit"**:
1. ✅ Sẽ có popup xin permission
2. ✅ Click "Allow"
3. ✅ App sẽ kết nối tới Google Fit

### 5.2 Xem Logs (Debug)
Khi sync, xem console logs:
- ✅ Nếu thấy: `✅ Lấy được X data points` → OK!
- ✅ Nếu thấy: `✅ Lưu được Y data points` → Success!
- ❌ Nếu thấy `❌ Lỗi xin quyền` → Xem Bước 3 lại

---

## 💡 Tại sao cần Google Cloud?

| Thành phần | Tác dụng |
|-----------|---------|
| **Google Cloud Project** | Bao gồm tất cả API & credentials |
| **Google Fit API** | Cho phép app kết nối tới Google Fit |
| **OAuth 2.0** | Xác thực user & lấy permission |
| **Health Connect** | Thực tế là nơi lưu trữ dữ liệu sức khỏe trên device |
| **Scopes** | Quyền gì được phép lấy (heart rate, steps, glucose...) |

---

## 🧪 Test Data

### Thêm dữ liệu test trong Health Connect
1. Mở **Google Health Connect** app
2. Click **+** để thêm data
3. Chọn loại (Steps, Heart Rate, etc.)
4. Enter value & save
5. Quay lại MediMinder → Click **"Đồng Bộ Google Fit"**
6. Nên thấy dữ liệu được sync

---

## ❌ Nếu vẫn không work

### Kiểm tra:
1. **API enabled?** → Vào Google Cloud Console check
2. **OAuth configured?** → Xem Credentials page
3. **SHA-1 đúng?** → Chạy lại keytool command
4. **Health Connect installed?** → Check Play Store
5. **Permission granted?** → Allow khi app hỏi

### Logs để debug:
```
I/flutter: ✅ Lấy được X data points  ← Nếu thấy này = OK
I/flutter: ❌ Lỗi xin quyền: ...       ← Xem error message
I/flutter: ✅ Lưu được Y data points   ← Nếu > 0 = Success!
```

---

## 🎯 Summary - Checklist

- [ ] Create Google Cloud Project
- [ ] Enable Google Fit API
- [ ] Create OAuth 2.0 Client ID (Android)
- [ ] Add scopes (fitness.activity.read, etc.)
- [ ] Get SHA-1 fingerprint
- [ ] Install Health Connect on device
- [ ] Add test data in Health Connect
- [ ] Run app & test sync
- [ ] Check logs → Nên thấy "Lưu được X data points"

**Xong! 🎉**
