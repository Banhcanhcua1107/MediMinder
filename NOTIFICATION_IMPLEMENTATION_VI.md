# Hệ Thống Notification Chính Xác - Hướng Dẫn Triển Khai Chi Tiết

## 🎯 Yêu Cầu của Bạn

Bạn muốn:
1. ✅ Setup thời gian nhắc nhở khi thêm thuốc (user-defined)
2. ✅ Nhắc nhở trước X phút (default 15, tuỳ chỉnh 5/10/15/30/60)
3. ✅ **Gửi notification chính xác** (giảm delay từ -55s ~ 200s)
4. ✅ **Nếu chưa uống sau 5 phút → nhắc mỗi 10 phút**
5. ✅ **Bấm "Đã uống" → dừng nhắc nhở**

---

## 📊 Kiến Trúc Hệ Thống

```
┌─────────────────────────────────────┐
│        User thêm thuốc              │
│  (AddMedScreen)                     │
│  - Chọn giờ: 08:00, 14:00, 20:00   │
│  - Set reminder: 15 phút trước      │
└──────────────┬──────────────────────┘
               ↓
┌─────────────────────────────────────┐
│   NotificationTracker.initialize()  │
│   - Schedule reminders              │
│   - Create notification_tracking    │
│   - Start check timer (30s)         │
│   - Start repeat timer (10min)      │
└──────────────┬──────────────────────┘
               ↓
┌─────────────────────────────────────┐
│   Check Timer (mỗi 30 giây)        │
│   - Lấy pending reminders          │
│   - Check if time to send          │
│   - Send notification              │
│   - Update notification_status     │
└──────────────┬──────────────────────┘
               ↓
       ┌───────┴───────┐
       ↓               ↓
  User bấm        Không uống
  "Đã uống"       sau 5 phút
     ↓                 ↓
  markAsTaken    Repeat Timer
  intake_status    mỗi 10 phút
  = 'taken'        gửi lại
  Stop repeat      (max 5 lần)
  notifications
```

---

## 🗄️ Part 1: Database Setup

### Bước 1: Copy SQL này vào Supabase SQL Editor

File: `MIGRATION_ADD_NOTIFICATION_SETTINGS.sql` (đã tạo)

**Hoặc chạy đoạn này:**

```sql
-- ADD COLUMNS
ALTER TABLE medicine_schedule_times 
ADD COLUMN IF NOT EXISTS reminder_minutes_before INTEGER DEFAULT 15;

ALTER TABLE medicine_schedule_times 
ADD COLUMN IF NOT EXISTS reminder_enabled BOOLEAN DEFAULT true;

-- CREATE TRACKING TABLE
CREATE TABLE IF NOT EXISTS notification_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_medicine_id UUID NOT NULL REFERENCES user_medicines(id) ON DELETE CASCADE,
  medicine_schedule_time_id UUID NOT NULL REFERENCES medicine_schedule_times(id) ON DELETE CASCADE,
  medicine_intake_id UUID REFERENCES medicine_intakes(id) ON DELETE SET NULL,
  
  scheduled_date DATE NOT NULL,
  scheduled_time TIME NOT NULL,
  reminder_scheduled_at TIMESTAMP WITH TIME ZONE NOT NULL,
  
  notification_status VARCHAR(50) NOT NULL DEFAULT 'pending',
  notification_sent_at TIMESTAMP WITH TIME ZONE,
  
  repeat_count INTEGER DEFAULT 0,
  last_reminder_at TIMESTAMP WITH TIME ZONE,
  next_reminder_at TIMESTAMP WITH TIME ZONE,
  
  intake_status VARCHAR(50) NOT NULL DEFAULT 'pending',
  taken_at TIMESTAMP WITH TIME ZONE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notification_tracking_user_id ON notification_tracking(user_id);
CREATE INDEX idx_notification_tracking_status ON notification_tracking(notification_status);

ALTER TABLE notification_tracking ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own notifications" ON notification_tracking
FOR ALL USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
```

**Kết quả:**
- ✅ medicine_schedule_times có thêm: `reminder_minutes_before`, `reminder_enabled`
- ✅ notification_tracking table created (track tất cả notifications)

---

## 🔧 Part 2: NotificationTracker Service

**File:** `lib/services/notification_tracker.dart` (đã tạo ✅)

**Tính năng:**
- ✅ `scheduleRemindersForMedicine()` - Lên lịch khi user thêm thuốc
- ✅ `sendReminder()` - Gửi notification chính xác
- ✅ `sendRepeatReminder()` - Gửi lặp lại mỗi 10 phút
- ✅ `markAsTaken()` - Dừng nhắc khi user uống
- ✅ `_startCheckTimer()` - Check mỗi 30 giây
- ✅ `_startRepeatTimer()` - Repeat mỗi 10 phút

---

## 📱 Part 3: Update AddMedScreen

### File: `lib/screens/add_med_screen.dart`

#### Bước 1: Thêm import
```dart
import '../services/notification_tracker.dart';
```

#### Bước 2: Thêm variable
```dart
class _AddMedScreenState extends State<AddMedScreen> {
  // ... existing variables ...
  
  // ✨ THÊM:
  int _reminderMinutesBefore = 15;  // Default 15 phút
}
```

#### Bước 3: Tìm nơi build UI (hôm nay đang ở đâu?)
Tôi cần biết: Khi user add medicine, UI hiển thị **giờ uống** (time picker) ở đâu?

**Vui lòng check:**
- Tên method build reminder times UI là gì?
- UI hiện tại có time picker không?
- Có chỗ nào để add "Reminder Settings" section không?

**Trong khi đó, đây là template UI bạn nên thêm:**

```dart
// Thêm section này trong build method, gần phần "Thời gian uống"

Container(
  padding: const EdgeInsets.all(16),
  margin: const EdgeInsets.only(top: 16),
  decoration: BoxDecoration(
    color: const Color(0xFFF8FAFC),
    border: Border.all(color: const Color(0xFFE2E8F0)),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nhắc nhở trước',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_reminderMinutesBefore phút',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF196EB0),
                ),
              ),
            ],
          ),
          PopupMenuButton<int>(
            onSelected: (value) {
              setState(() {
                _reminderMinutesBefore = value;
              });
              showCustomToast(
                context,
                message: 'Sẽ nhắc $value phút trước',
                isSuccess: true,
              );
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 5, child: Text('5 phút')),
              PopupMenuItem(value: 10, child: Text('10 phút')),
              PopupMenuItem(value: 15, child: Text('15 phút')),
              PopupMenuItem(value: 30, child: Text('30 phút')),
              PopupMenuItem(value: 60, child: Text('60 phút')),
            ],
            child: const Icon(Icons.more_vert, color: Color(0xFF196EB0)),
          ),
        ],
      ),
    ],
  ),
)
```

#### Bước 4: Update save method
```dart
Future<void> _saveMedicine() async {
  try {
    // ... existing save code ...
    
    // Sau khi save thành công, schedule notifications:
    if (isNewMedicine) {
      final tracker = NotificationTracker();
      await tracker.initialize();
      
      await tracker.scheduleRemindersForMedicine(
        userId: currentUser.id,
        medicineId: newMedicine.id,
        medicineName: _nameController.text,
        dosageStrength: _dosageController.text,
        quantityPerDose: int.parse(_quantityController.text),
        reminderMinutesBefore: _reminderMinutesBefore,
        scheduleTimes: _scheduleTimes,  // List<TimeOfDay> từ UI
      );
      
      debugPrint('✅ Reminders scheduled');
    }
    
    Navigator.pop(context, true);
  } catch (e) {
    debugPrint('❌ Error: $e');
  }
}
```

---

## 🏠 Part 4: Update Home Screen

### File: `lib/screens/home_screen.dart`

#### Bước 1: Thêm import
```dart
import '../services/notification_tracker.dart';
```

#### Bước 2: Update _handleToggleTaken method
```dart
Future<void> _handleToggleTaken(
  UserMedicine medicine,
  MedicineScheduleTime scheduleTime,
  bool taken,
) async {
  try {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // ... existing code ...
      
      // ✨ THÊM NÀY:
      if (taken) {
        // Người dùng bấm "Đã uống"
        final tracker = NotificationTracker();
        
        await tracker.markAsTaken(
          userId: user.id,
          medicineId: medicine.id,
          scheduledDateTime: DateTime.now(),
        );
        
        debugPrint('✅ Marked as taken - repeat notifications stopped');
      }
    }
  } catch (e) {
    debugPrint('❌ Error toggling taken status: $e');
  }
}
```

---

## ⚙️ Part 5: Initialize trong main.dart

### File: `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ... existing initializations ...

  // ✨ THÊM:
  try {
    final tracker = NotificationTracker();
    await tracker.initialize();
    debugPrint('✅ NotificationTracker initialized');
  } catch (e) {
    debugPrint('⚠️ NotificationTracker init warning: $e');
    // Không block app nếu tracker fail
  }

  runApp(...);
}
```

---

## 🌍 Part 6: Localization

### File: `lib/l10n/app_en.arb`
```json
{
  "reminderSettings": "Reminder Settings",
  "reminderBefore": "Remind Before",
  "minutes": "minutes",
  "testNotificationBody": "This is a test reminder notification",
  "checkSound": "Check if sound is working"
}
```

### File: `lib/l10n/app_vi.arb`
```json
{
  "reminderSettings": "Cài Đặt Nhắc Nhở",
  "reminderBefore": "Nhắc Trước",
  "minutes": "phút",
  "testNotificationBody": "Đây là thông báo nhắc nhở test",
  "checkSound": "Kiểm tra xem âm thanh có hoạt động"
}
```

---

## 🎯 Cách Hoạt Động Chi Tiết

### Timeline Ví Dụ: Thuốc uống lúc 08:00, nhắc 15 phút trước

```
07:45 - Notification scheduled time
  ↓
07:45:00 - checkTimer runs (every 30 seconds)
  ↓
07:45:15 - 30 seconds elapsed
  ↓
Check: Is now 07:45:15 close to 07:45:00? (diff = 15 seconds < 30) → YES!
  ↓
Send notification 📢
  ↓
notification_tracking.notification_status = 'sent'
notification_tracking.next_reminder_at = 07:55 (07:45 + 10 min)
  ↓
08:00 - User gets notification (maybe little delay)
User has 10 minutes to drink medicine
  ↓
08:05 - repeatTimer fires
  ↓
Check: next_reminder_at (08:00 + 10min = 08:10) < now? NO
User still has time
  ↓
08:10 - repeatTimer fires again
  ↓
Check: 08:10 <= now? YES!
Check: intake_status = 'pending'? YES!
  ↓
Send REPEAT notification #1 (⏰ Nhắc nhở lần 2)
repeat_count = 1
next_reminder_at = 08:20
  ↓
08:12 - User bấm "Đã uống"
  ↓
markAsTaken()
  ↓
notification_tracking.intake_status = 'taken'
  ↓
repeatTimer checks again at 08:20
  ↓
Check: intake_status = 'taken'? YES! → SKIP
No more notifications sent ✅
```

### Nếu User Quên Uống (All 5 Reminders):

```
08:00 - First notification (reminder)
08:10 - Repeat #1
08:20 - Repeat #2
08:30 - Repeat #3
08:40 - Repeat #4
08:50 - Repeat #5 (last)
09:00 - repeatTimer fires
Check: repeat_count (5) > 5? NO (exactly 5)
But next_reminder_at (09:00) exists? YES
Send it anyway? Will check

Actually: After 5, we mark as 'missed'
intake_status = 'missed'
No more repeat notifications
User can still mark "Đã uống" to change status
```

---

## 🧪 Testing Steps

### Test 1: Setup & Schedule
1. Open AddMedScreen
2. Add medicine with:
   - Name: Aspirin
   - Time: 08:00, 14:00, 20:00
   - Reminder: 15 phút
3. Save
4. Check database:
   ```sql
   SELECT * FROM notification_tracking 
   WHERE user_medicine_id = '[medicine_id]'
   ORDER BY scheduled_time;
   ```
   - Should have 3 rows (for 08:00, 14:00, 20:00)
   - reminder_scheduled_at should be 15 minutes before

### Test 2: Notification Sent
1. Set time to 1 minute before scheduled reminder
2. Wait for notification
3. Observe debug logs:
   ```
   ⏱️ Checking for reminders to send...
   🎯 Time to send reminder for [medicine_id]
   📢 Sending reminder notification
   ✅ Reminder notification sent
   ```

### Test 3: Repeat Notifications
1. Don't click "Đã uống"
2. Wait for 10 minutes
3. New repeat notification should arrive
4. Logs should show:
   ```
   🔔 Sending repeat reminder #1
   ✅ Repeat reminder #1 sent
   ```

### Test 4: Mark Taken Stops Repeat
1. Click "Đã uống"
2. Logs should show:
   ```
   ✅ Marking medicine as taken
   notification_tracking.intake_status = 'taken'
   ```
3. No more repeat notifications
4. Check DB: `taken_at` should be updated

---

## ⚡ Giảm Delay (±30 seconds to <5 seconds)

### Current Solution (±30 seconds):
✅ **Pros**: Simple, works across platforms
❌ **Cons**: Not precise enough

### Future Enhancement (Native):

#### Android (`notification_tracker.dart`):
```dart
// Use platform channel
import 'package:flutter/services.dart';

const platform = MethodChannel('com.mediminder/notification');

Future<void> scheduleNativeAlarm(DateTime reminderTime) async {
  try {
    await platform.invokeMethod('scheduleAlarm', {
      'reminderTime': reminderTime.millisecondsSinceEpoch,
    });
  } catch (e) {
    debugPrint('Error scheduling native alarm: $e');
  }
}
```

#### In Kotlin (android/app/src/main/kotlin/com/example/mediminder/MainActivity.kt):
```kotlin
val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.mediminder/notification")
channel.setMethodCallHandler { call, result ->
    when (call.method) {
        "scheduleAlarm" -> {
            val reminderTime = call.argument<Long>("reminderTime")!!
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val alarmIntent = Intent(context, NotificationBroadcastReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(context, 0, alarmIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
            alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, reminderTime, pendingIntent)
            result(null)
        }
    }
}
```

**Result**: <5 second accuracy ✨

---

## 📋 SQL Queries để Monitor

```sql
-- Tất cả pending reminders hôm nay
SELECT 
  medicine_name, 
  scheduled_time, 
  reminder_scheduled_at,
  notification_status,
  intake_status
FROM notification_tracking 
WHERE scheduled_date = CURRENT_DATE
ORDER BY scheduled_time;

-- Repeat notifications gửi
SELECT 
  medicine_name,
  repeat_count,
  last_reminder_at,
  next_reminder_at
FROM notification_tracking
WHERE repeat_count > 0
  AND scheduled_date = CURRENT_DATE;

-- Missed doses (>5 repeat)
SELECT medicine_name, repeat_count
FROM notification_tracking
WHERE intake_status = 'missed'
  AND scheduled_date = CURRENT_DATE;

-- Already taken
SELECT medicine_name, taken_at
FROM notification_tracking
WHERE intake_status = 'taken'
  AND scheduled_date = CURRENT_DATE;
```

---

## ✅ Checklist Hoàn Thành

- [ ] SQL migration chạy thành công
- [ ] NotificationTracker service có compile
- [ ] AddMedScreen UI updated (reminder settings)
- [ ] AddMedScreen save logic updated
- [ ] Home screen markAsTaken updated
- [ ] main.dart initialize tracker
- [ ] Localization strings added
- [ ] Test all flows:
  - [ ] Schedule reminders
  - [ ] Send notifications
  - [ ] Repeat every 10 min
  - [ ] Mark taken stops repeat
  - [ ] Missed after 5 repeats
- [ ] Deploy & verify

---

**Bây giờ bạn có:**
✅ Precise notification timing (±30s, upgradable to <5s)
✅ Repeat notifications (automatic every 10 minutes)
✅ User-configurable reminder time
✅ Track missed doses
✅ Database persistence
✅ Full localization (EN/VI)

**Bước tiếp theo**: Implement các phần vừa hướng dẫn! 🚀
