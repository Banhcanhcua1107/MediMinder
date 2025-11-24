# 🚀 HƯỚNG DẪN TRIỂN KHAI HỆ THỐNG NHẮC UỐNG THUỐC
## Dựa trên Architecture Kotlin + Cải Tiến cho Flutter

---

## 📋 BƯỚC 1: CÀI ĐẶT BAN ĐẦU

### 1.1 Cập nhật AndroidManifest.xml
```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- PERMISSIONS CẦN THIẾT -->
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />

    <application
        android:allowBackup="true"
        ...>

        <!-- Main Activity -->
        <activity
            android:name=".MainActivity"
            ...>
            ...
        </activity>

    </application>

</manifest>
```

### 1.2 Thêm Dependencies vào pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Notification
  flutter_local_notifications: ^15.1.0+1
  timezone: ^0.9.0
  flutter_timezone: ^0.0.5
  
  # Background tasks
  workmanager: ^0.5.2
  
  # Permissions
  permission_handler: ^11.4.3
  
  # State Management
  provider: ^6.0.0
  
  # Database (if needed locally)
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Network & Auth
  supabase_flutter: ^1.10.0
```

---

## 📱 BƯỚC 2: SETUP SERVICES

### 2.1 Cấu hình NotificationService (main.dart)

```dart
import 'package:mediminder/services/notification_service_enhanced.dart';
import 'package:mediminder/services/background_task_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();
  await notificationService.requestBatteryPermission();

  // 2. Initialize Background Task Service
  final backgroundService = BackgroundTaskService();
  await backgroundService.initialize();
  await backgroundService.scheduleMedicineCheckTask(); // Every 4 hours

  runApp(const MyApp());
}
```

### 2.2 Schedule Notifications khi User Thêm Thuốc (add_med_screen.dart)

```dart
// Khi lưu thuốc mới
Future<void> _handleSaveMedicine() async {
  // ... validation code ...

  // Lưu vào Supabase
  final newMedicine = await medicineProvider.addMedicine(medicineData);

  // Schedule notifications (Important!)
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Schedule cho từng giờ uống
  for (int i = 0; i < newMedicine.scheduleTimes.length; i++) {
    final scheduleTime = newMedicine.scheduleTimes[i];
    final timeOfDay = scheduleTime.timeOfDay;

    await notificationService.scheduleDailyNotification(
      id: NotificationService.generateNotificationId(newMedicine.id, i),
      title: '💊 Đến giờ uống thuốc!',
      body: '${newMedicine.name} - ${newMedicine.dosageStrength}, '
            '${newMedicine.quantityPerDose} viên',
      time: timeOfDay,
      payload: 'medicine:${newMedicine.id}',
      advanceMinutes: 1, // Notify 1 minute before
    );
  }

  // Show success notification
  await notificationService.showImmediateNotification(
    id: 999999,
    title: '✅ Đã lưu thuốc',
    body: 'Bạn sẽ nhận được thông báo lúc ${scheduleTimes.join(", ")}',
  );
}
```

---

## ⏰ BƯỚC 3: UNDERSTAND TIMING

### 3.1 Notification Trigger Logic

```
TAKE TIME (from user):     08:00 AM
TRIGGER TIME (1 min early): 07:59 AM ← Alarm triggers here
USER ACTION:               08:00 AM ← User typically takes medicine now
```

**Lợi ích:**
- ✅ User không bỏ lỡ notification nếu họ bận
- ✅ Có thời gian để xử lý nếu quên
- ✅ Thông báo xuất hiện khi họ chuẩn bị sẵn sàng

### 3.2 Timezone Handling

```dart
// Automatic timezone detection
tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh')); // Vietnam

// Daily repetition
matchDateTimeComponents: DateTimeComponents.time // Repeats at same time daily
```

---

## 🔔 BƯỚC 4: NOTIFICATION BEHAVIOR

### 4.1 Notification Actions (User Interactions)

```dart
// When user taps "Đã uống" (Taken)
_handleBackgroundAction() {
  // 1. Record intake to database
  // 2. Cancel repeat notifications
  // 3. Show success confirmation
}

// When user taps "Hoãn 10p" (Snooze)
_rescheduleNotification() {
  // 1. Schedule new notification 10 minutes later
  // 2. With unique ID to avoid duplicate
}
```

### 4.2 Notification Display (Lock Screen)

```dart
fullScreenIntent: true,               // Show on lock screen
visibility: NotificationVisibility.public,
category: AndroidNotificationCategory.alarm,
audioAttributesUsage: AudioAttributesUsage.alarm, // Not muted by volume
```

---

## 📊 BƯỚC 5: DATABASE SCHEMA

### 5.1 user_medicines (Existing)
```sql
CREATE TABLE user_medicines (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  dosage_strength TEXT,
  quantity_per_dose INTEGER,
  is_active BOOLEAN DEFAULT true,
  start_date DATE,
  end_date DATE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP
);
```

### 5.2 medicine_schedule_times (Existing)
```sql
CREATE TABLE medicine_schedule_times (
  id TEXT PRIMARY KEY,
  schedule_id TEXT NOT NULL,
  time_of_day TIME NOT NULL,
  order_index INTEGER,
  FOREIGN KEY (schedule_id) REFERENCES medicine_schedules(id)
);
```

### 5.3 medicine_intakes (NEW - For Tracking)
```sql
CREATE TABLE medicine_intakes (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL,
  user_medicine_id TEXT NOT NULL,
  medicine_name TEXT NOT NULL,
  dosage_strength TEXT,
  quantity_per_dose INTEGER,
  scheduled_date DATE NOT NULL,
  scheduled_time TIME NOT NULL,
  taken_at TIMESTAMP,
  status TEXT DEFAULT 'pending', -- pending, taken, skipped
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES auth.users(id),
  FOREIGN KEY (user_medicine_id) REFERENCES user_medicines(id)
);

-- Index for fast queries
CREATE INDEX idx_medicine_intakes_user_date 
ON medicine_intakes(user_id, scheduled_date);

CREATE INDEX idx_medicine_intakes_status 
ON medicine_intakes(status);
```

---

## 🎯 BƯỚC 6: TESTING CHECKLIST

### 6.1 Unit Testing
- [ ] ID generation is unique
- [ ] Timezone conversion correct
- [ ] Trigger time = scheduled time - 1 minute
- [ ] Database operations successful

### 6.2 Integration Testing
```dart
// Test notification scheduling
test('Notification scheduled correctly', () async {
  final service = NotificationService();
  await service.initialize();

  final testTime = TimeOfDay(hour: 10, minute: 30);
  await service.scheduleDailyNotification(
    id: 1,
    title: 'Test',
    body: 'Test body',
    time: testTime,
  );

  // Verify it appears in pending list
  final pending = await service._flutterLocalNotificationsPlugin
      .pendingNotificationRequests();
  expect(pending.any((p) => p.id == 1), true);
});
```

### 6.3 Manual Testing (Real Device)

**Test 1: Immediate Notification**
```
1. Add medicine with time = current time + 2 minutes
2. Watch notification appear 1 minute before
3. Tap "Đã uống" → should be recorded
```

**Test 2: Daily Repetition**
```
1. Add medicine with daily reminder at 08:00
2. Wait for notification to appear at 07:59
3. Close app completely
4. Next day at 07:59, notification should appear again
```

**Test 3: Background Task**
```
1. Close app
2. Wait 4+ hours
3. Background task should run and refresh schedule
4. Check logs: "🔔 Background medicine scheduling task executing"
```

**Test 4: Battery Optimization**
```
1. Device in deep sleep (Doze mode)
2. At scheduled time, notification should still appear
3. Battery optimization should be bypassed
```

### 6.4 Debugging Logs to Check

```
✅ Timezone: Asia/Ho_Chi_Minh
✅ Notification Channel created: medicine_alarm_channel_v6
✅ [SCHEDULE] ID=XXX, Time=08:00, Trigger=07:59
📋 Pending: 3
   - ID=1: Paracetamol
   - ID=2: Vitamin D
   - ID=3: Aspirin
✅ Scheduled successfully
✅ Recording taken: medicine123
✅ Successfully recorded as taken
```

---

## 🔧 BƯỚC 7: TROUBLESHOOTING

### Issue 1: Notification tidak hiển thị
```
❌ Symptom: Scheduled but never appears

✅ Fix:
1. Check AndroidManifest.xml has SCHEDULE_EXACT_ALARM
2. Check device not in battery saver mode
3. Check notification channel is created
4. Verify timezone is correct
5. Check logs for any errors
```

### Issue 2: Notification lặp không dừa
```
❌ Symptom: Appears multiple times unexpectedly

✅ Fix:
1. Check ID generation is unique per medicine + time
2. Verify matchDateTimeComponents: DateTimeComponents.time
3. Cancel old notifications before scheduling new ones
```

### Issue 3: Background task không chạy
```
❌ Symptom: Workmanager task never executes

✅ Fix:
1. Check Workmanager initialized in main()
2. Check @pragma('vm:entry-point') on callback
3. Check network connected for Supabase
4. Device not in battery saver blocking background tasks
```

### Issue 4: Action handlers không hoạt động
```
❌ Symptom: Tapping "Đã uống" doesn't record

✅ Fix:
1. Verify notificationTapBackground is @pragma('vm:entry-point')
2. Check Supabase initialization in background
3. Verify medicine_intakes table exists and writable
4. Check app has internet permission
```

---

## 📈 BƯỚC 8: ADVANCED FEATURES (Optional)

### 8.1 Nagging Notifications
```dart
// If user didn't respond after 15 minutes, send another
Future<void> scheduleNaggingNotification(
  int originalId,
  String title,
  String body,
) async {
  final service = NotificationService();
  await service.initialize();

  final now = tz.TZDateTime.now(tz.local);
  final nagTime = now.add(const Duration(minutes: 15));

  await service._flutterLocalNotificationsPlugin.zonedSchedule(
    originalId + 5000, // Unique ID for nagging
    '⏰ $title',
    '$body - Bạn đã quên?',
    nagTime,
    NotificationDetails(android: service._getAlarmNotificationDetails()),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}
```

### 8.2 Medication Adherence Stats
```dart
// Calculate adherence percentage
Future<double> calculateAdherence(String userId, String medicineId) async {
  final supabase = Supabase.instance.client;
  
  // Total scheduled doses this month
  final totalScheduled = await supabase
      .from('medicine_intakes')
      .count()
      .eq('user_id', userId)
      .eq('user_medicine_id', medicineId);
  
  // Doses actually taken
  final taken = await supabase
      .from('medicine_intakes')
      .count()
      .eq('user_id', userId)
      .eq('user_medicine_id', medicineId)
      .eq('status', 'taken');
  
  return (taken / totalScheduled) * 100;
}
```

### 8.3 Smart Reminders (ML-based timing)
```dart
// Adjust reminder time based on user patterns
// If user always takes medicine 5 minutes after notification,
// send notification 5 minutes earlier
```

---

## 🎓 BƯỚC 9: BEST PRACTICES

### DO ✅
- ✅ Always check if user gave permissions before scheduling
- ✅ Use timezone-aware datetime calculations
- ✅ Implement notification channel before scheduling
- ✅ Log all notification operations for debugging
- ✅ Cancel old notifications before adding new ones
- ✅ Test on real devices in Doze mode
- ✅ Handle background isolation for Supabase
- ✅ Store medication data locally as cache

### DON'T ❌
- ❌ Don't use system timezone directly
- ❌ Don't schedule too many notifications at once
- ❌ Don't ignore battery optimization settings
- ❌ Don't assume Android version (check with Platform.isAndroid)
- ❌ Don't schedule exact alarms on API < 31 without checking
- ❌ Don't forget @pragma('vm:entry-point') on background callbacks
- ❌ Don't assume network always available in background
- ❌ Don't block UI thread with heavy database operations

---

## 📚 REFERENCE FILES

- `notification_service_enhanced.dart` - Main notification engine
- `background_task_service.dart` - Background scheduling
- `medicine_intake.dart` - Data model for tracking
- `MEDICATION_REMINDER_SYSTEM.md` - Architecture overview

---

## ✨ EXPECTED RESULTS

✅ **Exact timing**: Notification appears within 1-2 seconds of scheduled time  
✅ **Daily repetition**: Works every day at same time  
✅ **Lock screen**: Visible even on locked phone  
✅ **Sound**: Plays alarm sound that can't be muted  
✅ **Background**: Continues working with app closed  
✅ **Actions**: User can mark "Taken" or "Snooze"  
✅ **Database**: All actions recorded for adherence tracking  
✅ **Battery**: Optimized but reliable in Doze mode  
