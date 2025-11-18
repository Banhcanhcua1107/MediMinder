# 📱 Notification & Background Task Setup Guide

## 🎉 Tính năng vừa hoàn thành

✅ **Notification Service** - Gửi thông báo cục bộ (Local Notifications)
✅ **Background Task Service** - Chạy task định kỳ ở background
✅ **Android Config** - Permissions + Notification channel
✅ **iOS Config** - Permissions setup
✅ **Integrated to main.dart** - Khởi tạo khi app start

---

## 🚀 Cách Hoạt Động

### **Sơ đồ luồng:**

```
App Start (main.dart)
    ↓
Initialize NotificationService
    ↓
Initialize BackgroundTaskService
    ↓
Schedule Background Tasks:
    - Task 1: Check medicine every 30 minutes
    - Task 2: Sync data every 6 hours
    ↓
When it's time to take medicine:
    ↓
Background task checks medicines
    ↓
If medicine time match:
    ↓
Send notification to user
    ↓
Notification shows on lock screen + notification panel
    ↓
User can click → Open app (TODO: handle navigation)
```

---

## 📋 Files Tạo/Sửa

| File | Loại | Thay Đổi |
|------|------|---------|
| `pubspec.yaml` | Config | + 3 dependencies (flutter_local_notifications, workmanager, timezone) |
| `lib/services/notification_service.dart` | NEW | Service quản lý notification (400+ lines) |
| `lib/services/background_task_service.dart` | NEW | Service background task + dispatcher (350+ lines) |
| `android/app/src/main/AndroidManifest.xml` | Config | + 4 permissions, + service config |
| `android/app/src/main/res/values/strings.xml` | Config | + notification channel strings |
| `ios/Runner/Info.plist` | Config | + notification permission key |
| `lib/main.dart` | Updated | + imports + initialize notification & background services |

---

## 🔧 Bước Setup

### **Bước 1: Flutter Pub Get**
```powershell
cd d:\LapTrinhUngDungDT\MediMinder_DA\mediminder
flutter pub get
```

### **Bước 2: Clean & Rebuild** (Important!)
```powershell
flutter clean
flutter pub get
flutter run
```

---

## 📱 Cách Dùng (Trong Code)

### **1. Gửi thông báo ngay lập tức:**
```dart
final notificationService = NotificationService();

notificationService.showNotification(
  id: 1,
  title: 'Nhắc uống thuốc',
  body: 'Aspirin 500mg - 2 viên',
  payload: 'medicine:123', // Optional
);
```

### **2. Lên lịch thông báo (một lần):**
```dart
final scheduledDate = DateTime.now().add(Duration(minutes: 15));

notificationService.scheduleNotification(
  id: 2,
  title: 'Nhắc uống thuốc',
  body: 'Aspirin 500mg - 2 viên',
  scheduledDate: scheduledDate,
  payload: 'medicine:123',
);
```

### **3. Lên lịch thông báo định kỳ (Hàng ngày):**
```dart
notificationService.scheduleDailyNotification(
  id: 3,
  title: 'Nhắc uống thuốc',
  body: 'Aspirin 500mg - 2 viên',
  time: TimeOfDay(hour: 8, minute: 0), // 08:00 hàng ngày
  payload: 'medicine:123',
);
```

### **4. Hủy thông báo:**
```dart
notificationService.cancelNotification(1); // Hủy ID 1
notificationService.cancelAllNotifications(); // Hủy tất cả
```

### **5. Lấy danh sách pending notifications:**
```dart
final pending = await notificationService.getPendingNotifications();
print('Pending: ${pending.length}');
```

---

## 🔄 Background Tasks

Background tasks tự động chạy định kỳ:

- **Task 1: Medicine Check** - Chạy mỗi 30 phút
  - Lấy danh sách thuốc hôm nay
  - Kiểm tra nếu cách giờ uống < 5 phút
  - Gửi notification

- **Task 2: Medicine Sync** - Chạy mỗi 6 giờ
  - Sync dữ liệu từ Supabase
  - (Optional) Lưu vào local storage

### **Thay đổi tần suất:**

Mở `lib/services/background_task_service.dart`:

```dart
// Thay đổi trong scheduleMedicineCheckTask()
frequency: const Duration(minutes: 30), // ← Thay đây

// Ví dụ thay đổi:
// - 15 phút: Duration(minutes: 15)
// - 1 giờ: Duration(hours: 1)
// - 6 giờ: Duration(hours: 6)
```

---

## ⚠️ Config Cần Sửa (Important!)

### **Supabase URL & Key trong background_task_service.dart**

Mở file: `lib/services/background_task_service.dart`

Tìm 2 chỗ có dòng:
```dart
url: 'YOUR_SUPABASE_URL',
anonKey: 'YOUR_SUPABASE_ANON_KEY',
```

**Sửa thành:**
```dart
// Lấy từ constants.dart hoặc env file
url: AppConstants.supabaseUrl,
anonKey: AppConstants.supabaseAnonKey,
```

Or import:
```dart
import '../config/constants.dart';
```

---

## 🎯 Tích Hợp Vào Add Medicine Screen

Khi user save medicine, tạo notification schedule:

```dart
// Trong add_med_screen.dart _handleSave()

// Sau khi tạo medicine + schedule + times thành công:

final notificationService = NotificationService();

for (int i = 0; i < _reminders.length; i++) {
  final timeOfDay = _reminders[i];
  final notificationId = NotificationService.generateNotificationId(
    medicine.id, 
    i
  );
  
  await notificationService.scheduleDailyNotification(
    id: notificationId,
    title: 'Nhắc uống thuốc',
    body: '${medicine.name} (${medicine.dosageStrength}) - ${medicine.quantityPerDose} viên',
    time: timeOfDay,
    payload: 'medicine:${medicine.id}',
  );
}
```

---

## 🗑️ Xóa Medicine - Hủy Notification

Khi user delete medicine:

```dart
// Trong medicine_repository.dart deleteMedicine()

// Sau khi delete từ database:

final notificationService = NotificationService();

// Hủy tất cả notification của medicine này
for (int i = 0; i < 10; i++) { // Max 10 times per day
  final notificationId = NotificationService.generateNotificationId(medicineId, i);
  await notificationService.cancelNotification(notificationId);
}
```

---

## 🔔 Notification Appearance

### **Android:**
- ✅ Hiện ở notification panel (top of screen)
- ✅ Hiện ở lock screen
- ✅ Có sound + vibration
- ✅ Có LED (light indicator)
- ✅ Action: Swipe to dismiss hoặc click

### **iOS:**
- ✅ Hiện banner ở top của screen
- ✅ Hiện ở notification center
- ✅ Có sound + vibration
- ✅ Action: Swipe to dismiss hoặc click

---

## 📝 Notification Channel Info

**Channel Name:** Medicine Reminders
**Channel ID:** medicine_channel
**Importance:** Maximum (always shows)
**Sound:** Default system sound
**Vibration:** Enabled
**LED Color:** #196EB0 (Primary color)

---

## ❌ Troubleshooting

### **Lỗi 1: "flutter_local_notifications not found"**
```
→ Chạy: flutter pub get
→ Rebuild: flutter clean && flutter pub get && flutter run
```

### **Lỗi 2: "Notification không hiện"**
```
→ Check Android: Settings > Apps > MediMinder > Notifications (ON?)
→ Check iOS: Settings > MediMinder > Notifications (ON?)
→ Check: App có permission không? (Nhấn Allow khi popup yêu cầu)
→ Restart app: Tắt và mở lại
```

### **Lỗi 3: "Background task không chạy"**
```
→ Ensure: Internet connection (để connect Supabase)
→ Ensure: App không bị kill (force stop)
→ Check: Battery saver mode (có thể block background task)
→ Try: Restart app + restart phone
```

### **Lỗi 4: "Supabase connection error in background task"**
```
→ Add: Config URL + Key trong background_task_service.dart
→ Check: .env file có value không?
→ Verify: URL + Key có đúng không?
```

---

## 🎯 Next Steps

### **1. Test Notification (Immediate):**
Thêm code vào medicine_list_screen.dart (temporary):
```dart
// Button for testing
FloatingActionButton(
  onPressed: () {
    final notificationService = NotificationService();
    notificationService.showNotification(
      id: 999,
      title: 'Test Notification',
      body: 'This is a test message',
    );
  },
  child: Icon(Icons.notification_add),
),
```

### **2. Test Background Task:**
- Thêm medicine với time cách 2 phút
- Chờ 30 phút (tần suất check)
- Check notification panel

### **3. Integrate Notification Tap:**
Mở: `lib/services/notification_service.dart`
Tìm: `_onSelectNotification()`
Sửa: Xử lý navigation dựa trên payload

```dart
static Future<void> _onSelectNotification(
  NotificationResponse notificationResponse,
) async {
  final String? payload = notificationResponse.payload;
  
  if (payload?.startsWith('medicine:') == true) {
    // Extract medicine ID
    final medicineId = payload!.split(':')[1];
    
    // TODO: Navigate to medicine detail or list
    debugPrint('Navigate to medicine: $medicineId');
  }
}
```

---

## 📊 Permission Status

**Android:**
- ✅ INTERNET - For Supabase
- ✅ ACCESS_NETWORK_STATE - For network check
- ✅ POST_NOTIFICATIONS - For showing notifications (API 33+)
- ✅ SCHEDULE_EXACT_ALARM - For exact time scheduling
- ✅ WAKE_LOCK - For keeping device awake
- ✅ RECEIVE_BOOT_COMPLETED - For auto-start after reboot

**iOS:**
- ✅ NSUserNotificationUsageDescription - For notification permission

---

## 🔐 Security Notes

- Background tasks run in **isolated process** (separate from main app)
- Cannot access UI directly
- Can only use native APIs + Supabase
- Runs even if app is closed (⚠️ use sparingly)

---

## 💡 Advanced Features (Optional)

### **Custom Sound:**
```dart
// Download sound file
// Add to assets/sounds/notification.wav
// Modify notification_service.dart to use custom sound
```

### **Notification Actions:**
```dart
// Add buttons to notification
// Ví dụ: "Mark as Taken" button directly from notification
```

### **Local Database Sync:**
```dart
// Implement SharedPreferences caching
// Sync medicine list locally
// Support offline mode
```

### **Smart Scheduling:**
```dart
// Calculate perfect notification time
// Send notification 5 min before, not exactly at time
// User can adjust notification lead time
```

---

## 📚 Reference

- flutter_local_notifications: https://pub.dev/packages/flutter_local_notifications
- workmanager: https://pub.dev/packages/workmanager
- timezone: https://pub.dev/packages/timezone

---

## ✅ Checklist

- [x] Dependencies added to pubspec.yaml
- [x] NotificationService created
- [x] BackgroundTaskService created
- [x] Android config (permissions + channel)
- [x] iOS config (permissions)
- [x] Integrated to main.dart
- [ ] Test immediate notification
- [ ] Test scheduled notification
- [ ] Test daily recurring notification
- [ ] Test background task execution
- [ ] Test notification on lock screen
- [ ] Handle notification tap (TODO)
- [ ] Integrate with add_med_screen
- [ ] Integrate with medicine list delete

---

**Status:** ✅ **READY TO TEST**

**Next:** Run `flutter run` and start testing! 🚀
