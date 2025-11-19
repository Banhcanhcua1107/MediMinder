# 📋 Danh Sách File Liên Quan Đến Notification System

## 🔴 **Core Notification Services**

### **1. `lib/services/notification_service.dart` (319 dòng)**
**Mục đích:** Quản lý tất cả thông báo cục bộ
**Chức năng chính:**
- `initialize()` - Khởi tạo notification service với iOS/Android settings
- `showNotification()` - Hiển thị notification ngay lập tức
- `scheduleNotification()` - Lên lịch notification 1 lần ở thời điểm cụ thể
- `scheduleDailyNotification()` - Lên lịch notification lặp hàng ngày
- `cancelNotification()` / `cancelAllNotifications()` - Hủy notification
- `getPendingNotifications()` - Lấy danh sách notification chờ xử lý

**Công nghệ:**
- `flutter_local_notifications` 17.0.0
- `timezone` 0.9.4
- Android API: `Importance.max`, `Priority.high`, `fullScreenIntent: true`
- iOS API: `requestAlert`, `requestBadge`, `requestSound`

---

### **2. `lib/services/background_task_service.dart` (262 dòng)**
**Mục đích:** Xử lý background tasks khi app đóng
**Chức năng chính:**
- `callbackDispatcher()` - Top-level function chạy trong isolate
- `scheduleMedicineCheckTask()` - Chạy mỗi 30 phút
- `scheduleMedicineSyncTask()` - Chạy mỗi 6 giờ
- `_handleMedicineCheckTask()` - Check thuốc & gửi notification nếu tới giờ
- `_handleMedicineSyncTask()` - Đồng bộ dữ liệu từ Supabase

**Công nghệ:**
- `workmanager` 0.8.0
- Isolate execution
- Supabase real-time sync

---

## 🟡 **Screen/UI Files Sử Dụng Notification**

### **3. `lib/screens/add_med_screen.dart` (938 dòng)**
**Mục đích:** Thêm/sửa thuốc + lên lịch notification
**Phần liên quan notification:**
- `_handleSave()` - Lên lịch notification khi lưu thuốc
  - Tạo DateTime cho mỗi thời gian uống
  - Gọi `notificationService.scheduleNotification()`
  - Test notification ngay (để xác nhận service hoạt động)

**Code quan trọng:**
```dart
// Tạo test notification ngay lập tức
await notificationService.showNotification(
  id: _nameController.text.hashCode,
  title: '✅ Thuốc đã được thêm',
  body: '${_nameController.text} - sẽ nhắc vào: ${_reminders.join(", ")}',
);

// Lên lịch cho mỗi thời gian
for (int i = 0; i < _reminders.length; i++) {
  await notificationService.scheduleNotification(
    id: _nameController.text.hashCode + i,
    title: 'Nhắc uống thuốc',
    body: '${_nameController.text} - ${_dosageController.text}, ${_quantityController.text} viên',
    scheduledDate: scheduledDateTime,
    payload: 'medicine',
  );
}
```

---

### **4. `lib/screens/home_screen.dart` (633 dòng)**
**Mục đích:** Hiển thị danh sách thuốc hôm nay + checkbox xác nhận
**Phần liên quan notification:**
- `didChangeAppLifecycleState()` - Refresh dữ liệu khi app quay lại foreground
- `_handleToggleTaken()` - Xác nhận đã uống (lưu vào `medicine_intakes` table)
- Hiển thị status: "✅ Đã uống" hoặc "⚠️ Sắp tới"

**Code quan trọng:**
```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    debugPrint('🔄 App resumed - refreshing medicines');
    _loadMedicines(); // Tự động refresh
  }
}

// Khi click checkbox
Future<void> _handleToggleTaken(...) async {
  if (taken) {
    // Ghi nhận vào database
    await Supabase.instance.client
        .from('medicine_intakes')
        .insert({...});
  }
}
```

---

### **5. `lib/screens/medicine_list_screen.dart` (200+ dòng)**
**Mục đích:** Hiển thị tất cả thuốc của user
**Phần liên quan notification:**
- Điều hướng đến `add_med_screen` khi click "+"
- Refresh list sau khi thêm thuốc thành công

---

## 🟢 **Data Layer - Repositories**

### **6. `lib/repositories/medicine_repository.dart` (434 dòng)**
**Mục đích:** CRUD operations cho thuốc, schedules, intakes
**Phần liên quan notification:**
- `getTodayMedicines()` - Lấy danh sách + load `medicine_intakes` cho hôm nay
- `createMedicineIntake()` - Tạo intake record khi xác nhận đã uống
- `updateMedicineIntakeStatus()` - Cập nhật status (pending/taken/missed)
- `getMedicineIntakes()` - Lấy lịch sử intake

**Code quan trọng:**
```dart
Future<List<UserMedicine>> getTodayMedicines(String userId) async {
  // Lấy dữ liệu thuốc
  // Load intakes cho hôm nay
  final intakes = await getMedicineIntakes(userId, date: today);
  // Gán vào userMed.intakes
  userMed.intakes = intakes.where(...).toList();
}
```

---

## 🔵 **Models**

### **7. `lib/models/user_medicine.dart` (434 dòng)**
**Mục đích:** Model dữ liệu cho thuốc
**Các class:**
- `UserMedicine` - Thông tin thuốc
  - `intakes: List<MedicineIntake>` - Lịch sử uống (NEW)
  - `scheduleTimes: List<MedicineScheduleTime>` - Các thời gian uống
- `MedicineSchedule` - Tần suất (daily, alternate_days, custom)
- `MedicineScheduleTime` - Thời gian cụ thể
- `MedicineIntake` - Lịch sử uống (taken_at, status, etc)

---

## 🟣 **Configuration Files**

### **8. `android/app/src/main/AndroidManifest.xml` (72 dòng)**
**Permissions cần có:**
```xml
<!-- Notification permissions -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.DISABLE_KEYGUARD" />

<!-- Background task permissions -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

<!-- Application attribute -->
<application android:enableOnBackInvokedCallback="true" ...>
```

---

### **9. `android/app/build.gradle.kts` (Build Configuration)**
**Cần có Java 8 desugaring:**
```kotlin
isCoreLibraryDesugaringEnabled = true

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
```

---

### **10. `ios/Runner/Info.plist` (iOS Configuration)**
**Permissions:**
```xml
<key>UIUserInterfaceStyle</key>
<string>Light</string>
<key>NSUserNotificationUsageDescription</key>
<string>Ứng dụng cần quyền thông báo để nhắc nhở uống thuốc</string>
```

---

### **11. `pubspec.yaml` (Dependencies)**
```yaml
dependencies:
  flutter_local_notifications: ^17.0.0
  workmanager: ^0.8.0
  timezone: ^0.9.4
  supabase_flutter: ^2.10.2
```

---

## 🟠 **Main Entry Point**

### **12. `lib/main.dart` (Initialization)**
**Khởi tạo services:**
```dart
Future<void> main() async {
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Initialize background task service
  final backgroundTaskService = BackgroundTaskService();
  await backgroundTaskService.scheduleMedicineCheckTask();
  await backgroundTaskService.scheduleMedicineSyncTask();
  
  runApp(const MediMinderApp());
}
```

---

## 📊 **Database Schema (Supabase)**

### **Tables:**
1. **`user_medicines`** - Thông tin thuốc
2. **`medicine_schedules`** - Tần suất uống
3. **`medicine_schedule_times`** - Thời gian cụ thể
4. **`medicine_intakes`** - **Lịch sử uống (quan trọng cho notification)** ⭐
   - `user_id`
   - `user_medicine_id`
   - `medicine_name`
   - `scheduled_date`
   - `scheduled_time`
   - `status: 'pending' | 'taken' | 'missed'`
   - `taken_at: timestamp`

---

## 🔗 **Flow Diagram - Khi Thêm Thuốc**

```
add_med_screen.dart
    ↓
_handleSave()
    ↓
createMedicine() → repository → Supabase
    ↓
createSchedule() + createScheduleTime()
    ↓
NotificationService.scheduleNotification() ← ⭐ QUAN TRỌNG
    ├─ Show test notification (ngay)
    └─ Schedule notification (tại thời gian)
    ↓
showCustomToast("Lưu thành công")
    ↓
Navigator.pop(context, true)
    ↓
home_screen.dart (refresh)
    ↓
getTodayMedicines() + load intakes
    ↓
Hiển thị danh sách + checkbox xác nhận
```

---

## 🔗 **Flow Diagram - Khi Đến Thời Gian**

```
System alarm triggered
    ↓
notification_service.dart
    ↓
showNotification()
    ├─ Android: fullScreenIntent=true, Importance.max
    ├─ Sound: enabled
    ├─ Vibration: enabled
    └─ LED: Color(0xFF196EB0)
    ↓
Notification hiển thị
    ├─ Foreground: hiện notification banner
    ├─ Background: notification tray
    └─ Locked: fullscreen notification
    ↓
User click → Open app
    ↓
home_screen.dart (resume)
    ↓
didChangeAppLifecycleState(resumed)
    ↓
_loadMedicines() → getTodayMedicines()
```

---

## ✅ **Checklist Kiểm Tra File**

- ✅ `notification_service.dart` - Đã có đầy đủ
- ✅ `background_task_service.dart` - Đã có đầy đủ
- ✅ `add_med_screen.dart` - Thêm notification khi lưu ✨
- ✅ `home_screen.dart` - Thêm auto-refresh ✨
- ✅ `medicine_repository.dart` - Có getTodayMedicines + load intakes
- ✅ `user_medicine.dart` - Thêm field `intakes`
- ✅ `AndroidManifest.xml` - Permissions + enableOnBackInvokedCallback
- ✅ `build.gradle.kts` - Java 8 desugaring
- ✅ `Info.plist` - Notification permission
- ✅ `pubspec.yaml` - Tất cả dependencies
- ✅ `main.dart` - Initialize services

---

**Tất cả file đã được cập nhật! Ready to test! 🚀**
