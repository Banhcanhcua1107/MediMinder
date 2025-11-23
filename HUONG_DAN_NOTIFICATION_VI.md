# Hướng Dẫn Sử Dụng Notification Settings - MediMinder

## 🎯 Tính Năng Chính

### 1️⃣ Bật/Tắt Thông Báo Toàn Cục
```
┌─────────────────────────────────┐
│ 🔔 Enable Notifications         │
│ Get reminders for your medicines│
│                         [Toggle]│
└─────────────────────────────────┘
```
**Chức năng**: Kiểm soát tất cả thông báo của ứng dụng
**Lưu ý**: Tắt cái này sẽ vô hiệu hóa tất cả cài đặt khác

---

### 2️⃣ Cài Đặt Nhắc Nhở Uống Thuốc

#### a) Bật Nhắc Nhở Uống Thuốc
```
┌─────────────────────────────────┐
│ 💊 Enable Medicine Reminders    │
│                         [Toggle]│
└─────────────────────────────────┘
```

#### b) Đặt Giờ Nhắc Nhở
```
┌─────────────────────────────────┐
│ 🕐 Reminder Time                │
│    09:00                        │
│    [Tap để chọn giờ]           │
└─────────────────────────────────┘
```
**Cách dùng**: 
- Tap vào mục này
- Chọn giờ từ Time Picker
- Lưu tự động

#### c) Nhắc Trước Bao Nhiêu Phút?
```
┌─────────────────────────────────┐
│ ⏱️ Remind Before: 15 minutes    │
│    [Menu: 5, 10, 15, 30, 60]   │
└─────────────────────────────────┘
```
**Ví dụ**: Nếu set 15 phút, sẽ nhắc 15 phút trước khi uống thuốc

---

### 3️⃣ Cài Đặt Âm Thanh & Rền

#### a) Âm Thanh Thông Báo
```
┌─────────────────────────────────┐
│ 🔊 Notification Sound           │
│                         [Toggle]│
└─────────────────────────────────┘
```

#### b) Rền
```
┌─────────────────────────────────┐
│ 📳 Vibration                    │
│                         [Toggle]│
└─────────────────────────────────┘
```

---

### 4️⃣ Test Thông Báo
```
┌─────────────────────────────────┐
│ 🔔 Test Alarm                   │
│ Send test notification with alarm│
│    [Tap để gửi test]           │
└─────────────────────────────────┘
```

**Chức năng**: Gửi thông báo test để kiểm tra:
- ✅ Âm thanh có hoạt động không?
- ✅ Rền có hoạt động không?
- ✅ Thông báo xuất hiện đúng cách?

---

## 📱 Quy Trình Sử Dụng Chi Tiết

### Bước 1: Truy Cập Notification Settings
```
Profile Screen → Tap "Notifications" → Notification Settings Screen
```

### Bước 2: Bật Thông Báo
```
Main Toggle → "Enable Notifications" = ON
Status: "Notifications enabled" ✅
```

### Bước 3: Cấu Hình Nhắc Nhở Uống Thuốc
```
Step 3a: Enable Medicine Reminders = ON
Step 3b: Tap "Reminder Time" → Chọn giờ (ví dụ 09:00)
Step 3c: Select "Remind Before" → Chọn 15 phút
```

### Bước 4: Cấu Hình Âm Thanh
```
Notification Sound = ON
Vibration = ON
```

### Bước 5: Test Thông Báo
```
Tap "Test Alarm" 
→ Xem thông báo xuất hiện
→ Nghe âm thanh báo thức
→ Cảm nhận rền
→ Nếu ổn, tap "OK"
```

---

## 🎨 Giao Diện Chi Tiết

```
┌──────────────────────────────────────┐
│  ← Notifications                     │
├──────────────────────────────────────┤
│                                      │
│  [🔔] Enable Notifications           │  
│      Get reminders for your medicines│
│                            [TOGGLE ON]│
│                                      │
│  MEDICINE REMINDERS                  │
│  [💊] Enable Medicine Reminders      │
│                           [TOGGLE ON]│
│  ─────────────────────────────────── │
│  [🕐] Reminder Time                  │
│       09:00                      [→] │
│  ─────────────────────────────────── │
│  [⏱️] Remind Before: 15 minutes      │
│       [Menu: 5, 10, 15, 30, 60]  [...] │
│                                      │
│  SOUND & VIBRATION                   │
│  [🔊] Notification Sound             │
│                           [TOGGLE ON]│
│  ─────────────────────────────────── │
│  [📳] Vibration                      │
│                           [TOGGLE ON]│
│                                      │
│  [🔔] Test Alarm                     │
│      Send test notification      [→] │
│                                      │
│  ℹ️ Enable notifications to receive   │
│     timely reminders for taking your  │
│     medicines. Customize sound,       │
│     vibration, and reminder timing.   │
│                                      │
└──────────────────────────────────────┘
```

---

## 💾 Dữ Liệu Được Lưu

Các cài đặt sau được lưu tự động:
- ✅ Trạng thái Enable Notifications
- ✅ Trạng thái Enable Medicine Reminders
- ✅ Giờ nhắc nhở (ví dụ: 09:00)
- ✅ Thời gian nhắc trước (ví dụ: 15)
- ✅ Trạng thái Sound
- ✅ Trạng thái Vibration

**Dữ liệu được lưu trong**: `SharedPreferences`
**Tự động tải khi**: Mở ứng dụng lần tới

---

## 🔧 Khắc Phục Sự Cố

### ❌ Thông báo không hiện?
```
✅ Bước 1: Kiểm tra "Enable Notifications" = ON
✅ Bước 2: Kiểm tra "Enable Medicine Reminders" = ON
✅ Bước 3: Kiểm tra giờ nhắc nhở đã được đặt
✅ Bước 4: Kiểm tra quyền thông báo trên điện thoại
```

### ❌ Không nghe thấy âm thanh?
```
✅ Kiểm tra "Notification Sound" = ON
✅ Kiểm tra âm lượng điện thoại
✅ Kiểm tra âm thanh không bị im lặng (Silent mode OFF)
✅ Tap "Test Alarm" để kiểm tra
```

### ❌ Không cảm nhận rền?
```
✅ Kiểm tra "Vibration" = ON
✅ Kiểm tra rền của điện thoại có bật không
✅ Tap "Test Alarm" để kiểm tra
```

---

## 📋 Danh Sách Kiểm Tra (Checklist)

**Cấu hình ban đầu:**
- [ ] Bật "Enable Notifications"
- [ ] Bật "Enable Medicine Reminders"
- [ ] Đặt "Reminder Time" 
- [ ] Chọn "Remind Before" (15 phút)
- [ ] Bật "Notification Sound"
- [ ] Bật "Vibration"
- [ ] Test thông báo

**Kiểm tra định kỳ:**
- [ ] Thông báo vẫn hoạt động?
- [ ] Âm thanh bình thường?
- [ ] Rền bình thường?
- [ ] Giờ nhắc nhở có đúng?

---

## 🌐 Hỗ Trợ Ngôn Ngữ

Ứng dụng hỗ trợ:
- 🇻🇳 Tiếng Việt (VI)
- 🇺🇸 Tiếng Anh (EN)

Ngôn ngữ sẽ thay đổi theo cài đặt ngôn ngữ của ứng dụng

---

## 📞 Liên Hệ Hỗ Trợ

Nếu gặp vấn đề:
1. Kiểm tra cấu hình lại tất cả
2. Restart ứng dụng
3. Kiểm tra quyền thông báo trên hệ thống

---

**Phiên bản**: 1.0  
**Cập nhật lần cuối**: Tháng 11, 2025  
**Trạng thái**: ✅ Hoàn thành
