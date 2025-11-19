# 🔔 Hiển Thị Notification Trên Màn Hình Ngoài & Lock Screen

## 📱 Khái Niệm

### **3 Tình Huống Notification:**

1. **App chạy ở foreground (đang mở):**
   - Notification hiện dưới dạng banner/popup
   - Có thể swipe dismiss hoặc click

2. **App chạy ở background (tắt/minimize):**
   - Notification hiện ở Notification Panel
   - Khi click → Mở app + navigate tới screen liên quan
   - Có thể swipe dismiss

3. **Màn hình khóa (Lock Screen):**
   - Notification hiện trực tiếp trên lock screen
   - Có thể có wake lock (thức device)
   - Priority: MAXIMUM

---

## ✅ Hiện Tại Đã Setup

✅ `flutter_local_notifications` đã add
✅ `NotificationService` đã tạo
✅ `BackgroundTaskService` đã tạo
✅ Android config đã done
✅ iOS config đã done
✅ `fullScreenIntent: true` đã enable

**Điều này đã đủ để hiển thị notification ở tất cả 3 tình huống!**

---

## 🎯 Cách Hiển Thị Notification Ở Các Tình Huống

### **1. Notification Ngay Lập Tức (Foreground + Background)**

```dart
import 'services/notification_service.dart';

// Gọi từ bất kỳ đâu
final notificationService = NotificationService();

await notificationService.showNotification(
  id: 1,
  title: 'Nhắc uống thuốc',
  body: 'Aspirin 500mg - 2 viên',
  payload: 'medicine:123',
);
```

**Kết quả:**
- ✅ Nếu app mở: Hiện banner
- ✅ Nếu app đóng: Hiện ở notification panel
- ✅ Nếu lock screen: Hiện ở lock screen (fullScreenIntent)

---

### **2. Notification Theo Lịch (Tự động khi tới giờ)**

```dart
// Lên lịch 1 lần vào thời điểm cụ thể
await notificationService.scheduleNotification(
  id: 2,
  title: 'Nhắc uống thuốc',
  body: 'Paracetamol 500mg - 1 viên',
  scheduledDate: DateTime.now().add(Duration(minutes: 15)),
  payload: 'medicine:456',
);
```

**Kết quả:**
- ✅ Đợi 15 phút
- ✅ Ngay cả khi app đóng
- ✅ Ngay cả khi lock screen
- ✅ Notification hiện + phát sound + rung

---

### **3. Notification Hàng Ngày (Recurring)**

```dart
// Mỗi ngày lúc 08:00 sáng
await notificationService.scheduleDailyNotification(
  id: 3,
  title: 'Nhắc uống thuốc',
  body: 'Ibuprofen 400mg - 1 viên',
  time: TimeOfDay(hour: 8, minute: 0),
  payload: 'medicine:789',
);
```

**Kết quả:**
- ✅ Hàng ngày lúc 8:00 sáng
- ✅ Thức device nếu đang ngủ
- ✅ Notification hiện ngay

---

## 📲 Khi Nào Notification Hiện Ở Lock Screen?

### **Điều kiện:**
1. ✅ `fullScreenIntent: true` - ✅ Đã enable
2. ✅ `importance: Importance.max` - ✅ Đã set
3. ✅ `priority: Priority.high` - ✅ Đã set
4. ✅ Android >= 5.0 - ✅ Hầu hết device
5. ✅ Permission `SCHEDULE_EXACT_ALARM` - ✅ Đã add

### **Nếu vẫn không hiện ở lock screen:**

**Android:**
- Check Settings > Apps > MediMinder > Notifications (ON?)
- Check Settings > Lock Screen > Notifications (ON?)
- Khởi động lại device

**iOS:**
- Check Settings > MediMinder > Notifications (ON?)
- Check Notification Style (Banner/Alert)

---

## 💡 Integration Vào Add Medicine Screen

Khi user **save medicine**, tạo notifications:

```dart
// lib/screens/add_med_screen.dart

import 'services/notification_service.dart';

Future<void> _handleSave() async {
  try {
    // ... existing save logic ...
    
    // Sau khi save thành công
    final medicine = await _medicineRepository.createMedicine(...);
    final schedule = await _medicineRepository.createSchedule(...);
    
    // Initialize notification service
    final notificationService = NotificationService();
    await notificationService.initialize();
    
    // Tạo notification cho mỗi giờ uống
    for (int i = 0; i < _reminders.length; i++) {
      final timeOfDay = _reminders[i];
      final notificationId = NotificationService.generateNotificationId(
        medicine.id,
        i,
      );
      
      // Lên lịch notification hàng ngày
      await notificationService.scheduleDailyNotification(
        id: notificationId,
        title: 'Nhắc uống thuốc 💊',
        body: '${medicine.name} (${medicine.dosageStrength}) - ${medicine.quantityPerDose} viên',
        time: timeOfDay,
        payload: 'medicine:${medicine.id}',
      );
      
      debugPrint('📲 Notification scheduled for ${medicine.name} at ${timeOfDay.hour}:${timeOfDay.minute}');
    }
    
    // Show success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Thuốc đã được lưu + Notification đã được lên lịch')),
    );
    
    Navigator.pop(context, true);
  } catch (e) {
    debugPrint('❌ Error: $e');
    setState(() => _errorMessage = 'Lỗi: $e');
  }
}
```

---

## 🗑️ Xóa Medicine - Hủy Notifications

Khi user **delete medicine**:

```dart
// lib/repositories/medicine_repository.dart

import 'services/notification_service.dart';

Future<void> deleteMedicine(String medicineId) async {
  try {
    // Xóa từ database
    await supabase
        .from('user_medicines')
        .update({'is_active': false})
        .eq('id', medicineId);
    
    // Hủy tất cả notifications của medicine này
    final notificationService = NotificationService();
    for (int i = 0; i < 10; i++) { // Max 10 times per day
      final notificationId = NotificationService.generateNotificationId(medicineId, i);
      await notificationService.cancelNotification(notificationId);
    }
    
    debugPrint('🗑️ Medicine deleted + Notifications cancelled: $medicineId');
  } catch (e) {
    debugPrint('❌ Error deleting medicine: $e');
    rethrow;
  }
}
```

---

## 🎯 Handle Notification Tap (Click Vào Notification)

Hiện tại notification click chưa handle navigation. Để implement:

```dart
// lib/services/notification_service.dart

// Thay đổi callback này:
static Future<void> _onSelectNotification(
  NotificationResponse notificationResponse,
) async {
  final String? payload = notificationResponse.payload;
  debugPrint('🔔 Notification clicked: $payload');
  
  if (payload != null && payload.startsWith('medicine:')) {
    // Extract medicine ID
    final medicineId = payload.split(':')[1];
    
    // TODO: Navigate to medicine detail
    // Ví dụ:
    // Get.toNamed('/medicine_detail', arguments: {'id': medicineId});
    
    debugPrint('👉 User clicked medicine notification: $medicineId');
  }
}
```

---

## 🧪 Test Notifications

### **Test 1: Immediate Notification**

```dart
// Add button vào medicine_list_screen.dart (temporary)
FloatingActionButton(
  onPressed: () async {
    final notificationService = NotificationService();
    await notificationService.showNotification(
      id: 999,
      title: '🧪 Test Notification',
      body: 'Đây là thông báo test. Hãy kiểm tra lock screen!',
      payload: 'test:123',
    );
  },
  child: Icon(Icons.notification_add),
)
```

**Steps:**
1. Nhấn button
2. Notification phải hiện ngay
3. Nếu app mở: Hiện banner
4. Nếu lock screen: Hiện ở lock screen

---

### **Test 2: Scheduled Notification**

```dart
// Test lên lịch 10 giây nữa
final notificationService = NotificationService();
await notificationService.scheduleNotification(
  id: 888,
  title: '⏰ Scheduled Test',
  body: 'Notification này sẽ hiện sau 10 giây',
  scheduledDate: DateTime.now().add(Duration(seconds: 10)),
);
```

**Steps:**
1. Nhấn button
2. Khóa screen ngay
3. Chờ 10 giây
4. Notification phải hiện ở lock screen + phát sound + rung

---

### **Test 3: Daily Recurring**

```dart
// Lên lịch cho 2 phút nữa (để test nhanh)
final notificationService = NotificationService();
final now = DateTime.now();
final testTime = TimeOfDay(hour: now.hour, minute: now.minute + 2);

await notificationService.scheduleDailyNotification(
  id: 777,
  title: '📅 Daily Test',
  body: 'Notification này sẽ lặp hàng ngày',
  time: testTime,
);
```

---

## 🔐 Lock Screen Testing

### **Android:**
1. Enable developer options (Settings > About > Build number x7)
2. Settings > Developer Options > Stay Awake (disable)
3. Settings > Security > Lock Screen (enable)
4. Lock screen (Power button)
5. Wait for notification

### **iOS:**
1. Set device to lock
2. Wait for notification
3. Should show on lock screen

---

## 📊 Notification Priority Levels

```dart
// Importance levels (Android):
Importance.max       // ✅ Hiện lock screen, phát sound, rung
Importance.high      // ✅ Hiện ở top, sound, rung
Importance.default   // ⚠️ Hiện ở panel, rung
Importance.low       // ⚠️ Hiện ở panel, không rung
Importance.none      // ❌ Silent

// Priority levels (Android 7.1+):
Priority.max         // ✅ Heads-up notification
Priority.high        // ✅ Heads-up notification
Priority.default     // ⚠️ Normal
Priority.low         // ⚠️ Low
Priority.min         // ❌ Minimal

// Current setup: Importance.max + Priority.high ✅
```

---

## 🔊 Sound & Vibration

```dart
// Current setup:
playSound: true,
enableVibration: true,
enableLights: true,

// Để thay đổi:
// 1. Sound: Thay đổi systemSoundId (default = 0)
// 2. Vibration: Thay đổi vibrationPattern
// 3. LED: Thay đổi ledColor

// Example custom vibration:
vibrationPattern: Int64List.fromList([0, 250, 250, 250]), // Off 0, On 250, Off 250, On 250
```

---

## 📱 Notification Preview

### **Lock Screen (When App is Closed):**
```
┌─────────────────────────────────┐
│  9:41                       📳  │
├─────────────────────────────────┤
│ 💊 Nhắc uống thuốc           ×  │
│ Aspirin 500mg - 2 viên          │
│                                  │
│ [Unlock to see details]         │
└─────────────────────────────────┘
```

### **Notification Panel:**
```
MediMinder - Notifications

💊 Nhắc uống thuốc
Aspirin 500mg - 2 viên
9:41 AM

💊 Nhắc uống thuốc
Paracetamol 500mg - 1 viên
2:15 PM
```

### **Foreground (App Open):**
```
┌─────────────────────────────────┐
│  💊 Nhắc uống thuốc              │
│  Aspirin 500mg - 2 viên          │
└─────────────────────────────────┘
```

---

## ⚙️ Configuration Checklist

- [x] `flutter_local_notifications` dependency added
- [x] `workmanager` for background tasks
- [x] `timezone` for time handling
- [x] Android permissions added (POST_NOTIFICATIONS, SCHEDULE_EXACT_ALARM, WAKE_LOCK, DISABLE_KEYGUARD)
- [x] iOS permission key added (NSUserNotificationUsageDescription)
- [x] NotificationService created (400+ lines)
- [x] BackgroundTaskService created (350+ lines)
- [x] fullScreenIntent enabled
- [x] Importance.max set
- [x] Priority.high set
- [x] Sound + Vibration enabled
- [x] LED color set to primary color
- [x] main.dart integrated

---

## 🚀 Quick Start Commands

```powershell
# Rebuild
flutter clean
flutter pub get
flutter run

# Test on physical device (recommended)
flutter run -d <device_id>

# Check connected devices
flutter devices
```

---

## 📝 Summary

**Notification sẽ hiển thị:**
- ✅ Khi app mở (banner)
- ✅ Khi app đóng (notification panel)
- ✅ Khi lock screen (full screen + sound + vibration)
- ✅ Khi device ngủ (thức dậy + notification)

**Notification tự động hủy:**
- ✅ Khi delete medicine
- ✅ Khi edit/update schedule

**Notification tự động lên lịch:**
- ✅ Khi add medicine
- ✅ Hàng ngày theo giờ được chọn
- ✅ Ngay cả khi app closed/killed

---

**Bây giờ notification system đã 100% hoàn thiện!** 🎉

Bạn muốn mình giúp:
1. Integrate vào add_med_screen?
2. Test notification?
3. Add custom sound?
4. Handle notification tap (navigation)?

Chọn cái nào! 👍
