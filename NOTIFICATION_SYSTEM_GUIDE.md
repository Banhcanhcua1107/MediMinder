# Hệ Thống Notification Chính Xác - Hướng Dẫn Chi Tiết

## 📋 Tổng Quan

Hệ thống bao gồm 3 thành phần:

1. **Database Schema** - Track notification state + reminder settings
2. **NotificationTracker Service** - Handle precise timing + repeat notifications
3. **UI Integration** - Setup reminder time trong AddMedScreen + Handle dalam Home

---

## 🗄️ Step 1: Database Migration

### Chạy SQL Này trong Supabase:
```sql
-- 1. Thêm columns vào medicine_schedule_times
ALTER TABLE medicine_schedule_times 
ADD COLUMN IF NOT EXISTS reminder_minutes_before INTEGER DEFAULT 15;

ALTER TABLE medicine_schedule_times 
ADD COLUMN IF NOT EXISTS reminder_enabled BOOLEAN DEFAULT true;

-- 2. Tạo bảng track notifications
CREATE TABLE IF NOT EXISTS notification_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_medicine_id UUID NOT NULL REFERENCES user_medicines(id) ON DELETE CASCADE,
  medicine_schedule_time_id UUID NOT NULL REFERENCES medicine_schedule_times(id) ON DELETE CASCADE,
  medicine_intake_id UUID REFERENCES medicine_intakes(id) ON DELETE SET NULL,
  
  scheduled_date DATE NOT NULL,
  scheduled_time TIME NOT NULL,
  reminder_scheduled_at TIMESTAMP WITH TIME ZONE NOT NULL,
  
  notification_status VARCHAR(50) DEFAULT 'pending',
  notification_sent_at TIMESTAMP WITH TIME ZONE,
  
  repeat_count INTEGER DEFAULT 0,
  last_reminder_at TIMESTAMP WITH TIME ZONE,
  next_reminder_at TIMESTAMP WITH TIME ZONE,
  
  intake_status VARCHAR(50) DEFAULT 'pending',
  taken_at TIMESTAMP WITH TIME ZONE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notification_tracking_user_id ON notification_tracking(user_id);
CREATE INDEX idx_notification_tracking_intake_status ON notification_tracking(intake_status);

ALTER TABLE notification_tracking ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own notifications" ON notification_tracking
FOR ALL USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
```

---

## 📱 Step 2: Update AddMedScreen - Thêm Reminder Settings UI

### Location: `lib/screens/add_med_screen.dart`

#### Thêm Variable:
```dart
class _AddMedScreenState extends State<AddMedScreen> {
  // ... existing variables ...
  
  // ✨ THÊM NÀY:
  int _reminderMinutesBefore = 15; // Remind 15 minutes before by default
  List<TimeOfDay> _scheduleTimes = []; // List giờ uống
}
```

#### Thêm UI Widget trong build method:
```dart
// Trong section "Thiết lập uống thuốc", thêm:

// ============================================================================
// REMINDER SETTINGS
// ============================================================================
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const SizedBox(height: 24),
    Text(
      l10n.reminderSettings,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: kPrimaryTextColor,
      ),
    ),
    const SizedBox(height: 12),
    
    // Reminder Before Picker
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        border: Border.all(color: kBorderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.reminderBefore,
                style: const TextStyle(
                  fontSize: 14,
                  color: kSecondaryTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$_reminderMinutesBefore ${l10n.minutes}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryTextColor,
                ),
              ),
            ],
          ),
          PopupMenuButton<int>(
            onSelected: (value) {
              setState(() {
                _reminderMinutesBefore = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 5, child: Text('5 ${l10n.minutes}')),
              PopupMenuItem(value: 10, child: Text('10 ${l10n.minutes}')),
              PopupMenuItem(value: 15, child: Text('15 ${l10n.minutes}')),
              PopupMenuItem(value: 30, child: Text('30 ${l10n.minutes}')),
              PopupMenuItem(value: 60, child: Text('60 ${l10n.minutes}')),
            ],
            child: const Icon(Icons.more_vert),
          ),
        ],
      ),
    ),
  ],
),
```

#### Update Save Medicine Method:
```dart
Future<void> _saveMedicine() async {
  try {
    // ... existing save code ...
    
    // ✨ THÊM NÀY - Nếu là medicine mới:
    if (!_isEditing) {
      // Get NotificationTracker instance
      final tracker = NotificationTracker();
      await tracker.initialize();
      
      // Schedule reminders
      await tracker.scheduleRemindersForMedicine(
        userId: user.id,
        medicineId: newMedicine.id,
        medicineName: _nameController.text,
        dosageStrength: _dosageController.text,
        quantityPerDose: int.parse(_quantityController.text),
        reminderMinutesBefore: _reminderMinutesBefore,
        scheduleTimes: _scheduleTimes, // Your list of times
      );
      
      debugPrint('✅ Reminders scheduled via NotificationTracker');
    }
  } catch (e) {
    // Handle error
  }
}
```

---

## 🏠 Step 3: Update Home Screen - Integrate Notification Tracking

### Location: `lib/screens/home_screen.dart`

#### Update _handleToggleTaken Method:
```dart
Future<void> _handleToggleTaken(
  UserMedicine medicine,
  MedicineScheduleTime scheduleTime,
  bool taken,
) async {
  try {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // ... existing toggle code ...
      
      // ✨ THÊM NÀY - Nếu user bấm "Đã uống":
      if (taken) {
        final tracker = NotificationTracker();
        final now = DateTime.now();
        
        await tracker.markAsTaken(
          userId: user.id,
          medicineId: medicine.id,
          scheduledDateTime: now,
        );
        
        debugPrint('✅ Notifications stopped for ${medicine.name}');
      }
    }
  } catch (e) {
    debugPrint('❌ Error: $e');
  }
}
```

---

## ⚙️ Step 4: Initialize NotificationTracker dalam main.dart

### Location: `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ... existing initialization ...

  // ✨ THÊM NÀY
  try {
    final tracker = NotificationTracker();
    await tracker.initialize();
    debugPrint('✅ NotificationTracker initialized');
  } catch (e) {
    debugPrint('❌ Error initializing NotificationTracker: $e');
  }

  runApp(...);
}
```

---

## 🔔 Step 5: Localization Strings

### Thêm vào `app_en.arb`:
```json
{
  "reminderSettings": "Reminder Settings",
  "reminderBefore": "Remind Before",
  "minutes": "minutes"
}
```

### Thêm vào `app_vi.arb`:
```json
{
  "reminderSettings": "Cài Đặt Nhắc Nhở",
  "reminderBefore": "Nhắc Trước",
  "minutes": "phút"
}
```

---

## 📊 Flow Đầy Đủ

### Khi User Thêm Thuốc:
```
1. User nhập thông tin thuốc
2. User chọn reminder time (5/10/15/30/60 phút)
3. User chọn giờ uống (08:00, 14:00, 20:00)
4. Click Save
   ↓
5. SaveMedicine → Database
   ↓
6. notificationTracker.scheduleRemindersForMedicine()
   ↓
7. notification_tracking table được populate
   ↓
8. NotificationTracker check timer mỗi 30 giây
```

### Khi Đến Gần Giờ Uống:
```
1. Thời gian nhắc nhở (08:00 - 15 phút = 07:45) được check
2. NotificationService.showNotification() gửi notification
3. notification_tracking.notification_status = 'sent'
4. User nhận được notification 💪
```

### Nếu User Không Uống Sau 10 Phút:
```
1. repeatTimer check mỗi 10 phút
2. Gửi repeat notification (lần 2, 3, 4, 5)
3. Mỗi lần gửi: repeat_count++, next_reminder_at += 10 min
4. Sau 5 lần: đánh dấu 'missed'
5. Vẫn có thể ấn "Đã uống" để dừng
```

### Khi User Bấm "Đã Uống":
```
1. _handleToggleTaken(medicine, true)
   ↓
2. tracker.markAsTaken()
   ↓
3. notification_tracking.intake_status = 'taken'
4. repeatTimer không còn gửi
5. Thông báo dừng lại
```

---

## 🎯 Chi Tiết Chính Xác Timer

### Problem: Delay -55s đến 200s
**Nguyên Nhân**: Flutter Timer không chính xác trên background

### Solution:
1. **Use 30-second check interval** (thay vì exact time)
   - Timer mỗi 30s check xem có nhắc nào cần gửi
   - Cho phép ±30 giây sai số

2. **Compare dengan reminder_scheduled_at từ DB**
   ```dart
   final reminderDt = DateTime.parse(reminder['reminder_scheduled_at']);
   final diffSeconds = reminderDt.difference(now).inSeconds.abs();
   
   if (diffSeconds < 30) {
     // Send now!
   }
   ```

3. **For Production: Dùng native platform**
   - Android: `AlarmManager.setAndAllowWhileIdle()`
   - iOS: `UNNotificationRequest` với `trigger`
   - Giảm delay xuống <5 giây

### Current Implementation:
- ✅ Check mỗi 30 giây
- ✅ Allow ±30 seconds margin
- ✅ Database-driven (can recover from app restart)
- ⏳ Future: Native platform channels untuk <5s accuracy

---

## 📝 Localization Keys Cần Thêm

```dart
// app_en.arb
"reminderSettings": "Reminder Settings",
"reminderBefore": "Remind Before",
"minutes": "minutes",
"testNotificationBody": "This is a test reminder notification",
"checkSound": "Check if sound is working",

// app_vi.arb
"reminderSettings": "Cài Đặt Nhắc Nhở",
"reminderBefore": "Nhắc Trước",
"minutes": "phút",
"testNotificationBody": "Đây là thông báo nhắc nhở test",
"checkSound": "Kiểm tra xem âm thanh có hoạt động",
```

---

## 🧪 Test Checklist

- [ ] User có thể set reminder time (5/10/15/30/60 min)
- [ ] Notification gửi trong ±30 giây so với scheduled time
- [ ] Repeat notification gửi mỗi 10 phút
- [ ] Bấm "Đã uống" dừng repeat
- [ ] Sau 5 lần nhắc: đánh dấu missed
- [ ] Database track chính xác (notification_tracking table)
- [ ] App restart: vẫn continue nhắc nhở

---

## 📱 Database Queries để Debug

```sql
-- Xem tất cả pending reminders cho hôm nay
SELECT * FROM notification_tracking 
WHERE scheduled_date = CURRENT_DATE 
  AND intake_status = 'pending'
ORDER BY scheduled_time;

-- Xem reminders đã gửi
SELECT * FROM notification_tracking 
WHERE notification_status = 'sent'
  AND scheduled_date = CURRENT_DATE;

-- Xem repeat reminders
SELECT user_medicine_id, medicine_name, repeat_count, next_reminder_at
FROM notification_tracking 
WHERE repeat_count > 0 
  AND scheduled_date = CURRENT_DATE;

-- Xem missed (quá 5 lần nhắc)
SELECT * FROM notification_tracking 
WHERE intake_status = 'missed'
  AND scheduled_date = CURRENT_DATE;
```

---

## ✅ Completion Checklist

- [x] Database schema created (MIGRATION_ADD_NOTIFICATION_SETTINGS.sql)
- [x] NotificationTracker service created
- [ ] AddMedScreen UI updated (reminder settings)
- [ ] AddMedScreen save logic updated (schedule reminders)
- [ ] Home screen updated (mark taken logic)
- [ ] main.dart updated (initialize tracker)
- [ ] Localization strings added
- [ ] Test all flows

---

**Bây giờ bạn có:**
1. ✅ Precise timing (±30 second margin)
2. ✅ Repeat notifications (mỗi 10 phút)
3. ✅ Track missed doses
4. ✅ User-configurable reminder time
5. ✅ Database persistence (survive app restart)
