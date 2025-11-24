# 💊 Hệ Thống Nhắc Nhở Uống Thuốc - MediMinder
## Tổng Hợp & Phát Triển từ Architecture Kotlin

---

## 📋 Tổng Quan Hệ Thống

### Mục Tiêu Chính
- ✅ Thiết lập báo thức chính xác theo giờ
- ✅ Thông báo ngay lập tức khi chỉ còn 1 phút
- ✅ Hỗ trợ 3 loại lặp lại: Hôm nay, Mỗi ngày, Ngày xen kỳ
- ✅ Quản lý số lượng viên thuốc
- ✅ Lưu trữ & đồng bộ với server
- ✅ Hoạt động ngoài app (background tasks)

---

## 🏗️ Kiến Trúc Tổng Thể

```
┌─────────────────────────────────────────────────────────────┐
│                    FLUTTER LAYER (UI)                        │
│  add_med_screen.dart → nhập dữ liệu người dùng              │
└────────────────┬────────────────────────────────────────────┘
                 │ (data models)
                 ▼
┌─────────────────────────────────────────────────────────────┐
│                 BUSINESS LOGIC LAYER                         │
│  ┌─────────────────┐  ┌──────────────────┐  ┌────────────┐ │
│  │  notification_  │  │  medicine_       │  │ background │ │
│  │  service.dart   │  │  provider.dart   │  │ _task_     │ │
│  │                 │  │                  │  │ service.   │ │
│  │ • Schedule      │  │ • CRUD ops       │  │ dart       │ │
│  │ • Manage        │  │ • State mgmt     │  │            │ │
│  │                 │  │                  │  │ • Periodic │ │
│  │                 │  │                  │  │   check    │ │
│  └─────────────────┘  └──────────────────┘  └────────────┘ │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│               DATA & PERSISTENCE LAYER                       │
│  ┌──────────────────────┐         ┌──────────────────────┐  │
│  │ medicine_repository  │         │ notification_        │  │
│  │                      │         │ tracker.dart         │  │
│  │ • Local (Hive/      │         │                      │  │
│  │   SharedPreferences) │         │ • Track status       │  │
│  │ • Supabase (remote)  │         │ • Repeat logic       │  │
│  └──────────────────────┘         └──────────────────────┘  │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│            ANDROID NATIVE LAYER (Kotlin/Java)               │
│  ┌──────────────────────┐         ┌──────────────────────┐  │
│  │ AlarmManager         │         │ notification_        │  │
│  │ (Platform Channel)   │         │ manager.dart         │  │
│  │                      │         │                      │  │
│  │ • Set exact alarms   │         │ • Show notifications │  │
│  │ • Repeat scheduling  │         │ • High priority      │  │
│  │ • Doze mode safe     │         │ • Lock screen        │  │
│  └──────────────────────┘         └──────────────────────┘  │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│              SYSTEM LEVEL (Android OS)                       │
│  ┌──────────────────────┐         ┌──────────────────────┐  │
│  │ BroadcastReceiver    │         │ WorkManager          │  │
│  │ (Alarm triggers)     │         │ (background tasks)   │  │
│  │                      │         │                      │  │
│  │ • Receives alarm     │         │ • Periodic checks    │  │
│  │ • Creates intent     │         │ • Device sleep safe  │  │
│  │ • Calls callback     │         │ • Battery optimized  │  │
│  └──────────────────────┘         └──────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 Luồng Hoạt Động Chi Tiết

### Fase 1: Người Dùng Thêm Thuốc
```
User Input (add_med_screen.dart)
    ↓
Validate Data
    ↓
Create Medicine Object
    ├─ name: "Paracetamol"
    ├─ scheduleTimes: [08:00, 14:00, 20:00]
    ├─ repetition: "daily"
    ├─ startDate: "2025-11-24"
    ├─ endDate: "2025-12-24"
    └─ quantityPerDose: 1
    ↓
Save to Supabase
    ↓
Schedule All Notifications
```

### Fase 2: Thiết Lập Báo Thức (Background Task - Mỗi 4 giờ)
```
BackgroundTaskService._handleMedicineCheckTask()
    ↓
Lấy danh sách thuốc hôm nay
    ↓
Cho từng thuốc & từng giờ uống:
    ├─ Tính toán thời gian trigger: (giờ_uống - 1 phút)
    ├─ Tính ID duy nhất: hash(medicineId + timeIndex)
    └─ Gọi NotificationService.scheduleDailyNotification()
    ↓
AlarmManager.setExactAndAllowWhileIdle()
```

### Fase 3: Khi Đến Giờ (Đúng 1 phút trước)
```
AlarmManager triggers at scheduled time
    ↓
BroadcastReceiver.onReceive()
    ↓
NotificationService.initialize() (nếu chưa)
    ↓
Create & Show Notification
    ├─ Title: "Đến giờ uống thuốc! 💊"
    ├─ Body: "Paracetamol - 500mg, 1 viên"
    ├─ Actions: [Đã uống] [Hoãn 10p]
    └─ Sound: Alarm (không bị mute)
    ↓
Show on Lock Screen + Notification Panel
```

### Fase 4: Người Dùng Tương Tác
```
User Action: "Đã uống"
    ↓
NotificationService.handleActionBackground()
    ↓
Record intake:
    ├─ Create entry in medicine_intakes table
    ├─ user_id, medicine_id, taken_time
    └─ status: "taken"
    ↓
Cancel repeat notifications
```

---

## 📁 Cấu Trúc File Chi Tiết

### Models (lib/models/)
```
user_medicine.dart
├─ UserMedicine (chính)
│   ├─ id, name, dosageStrength
│   ├─ scheduleTimes: List<MedicineScheduleTime>
│   └─ schedules: List<MedicineSchedule>
│
└─ MedicineScheduleTime
    ├─ id, scheduleId
    ├─ timeOfDay: TimeOfDay(08:00)
    └─ orderIndex: 0, 1, 2...

medicine_intake.dart (NEW)
├─ MedicineIntake
│   ├─ id, userId, medicineId
│   ├─ medicineName, dosageStrength
│   ├─ scheduledTime, takenTime
│   └─ status: "pending" | "taken" | "skipped"
```

### Services (lib/services/)
```
notification_service.dart (Enhanced)
├─ createNotificationChannel()
│   └─ Tạo channel "medicine_alarm_channel_v6"
│
├─ scheduleDailyNotification()
│   ├─ Tính thời gian trigger (giờ - 1 phút)
│   ├─ Set exact alarm: AlarmManager.setExactAndAllowWhileIdle()
│   └─ matchDateTimeComponents: DateTimeComponents.time (lặp hàng ngày)
│
├─ showNotification()
│   ├─ Hiển thị thông báo ngay lập tức
│   └─ Dùng cho confirmation
│
├─ handleActionBackground()
│   ├─ Xử lý khi user bấm "Đã uống"
│   ├─ Create intake record
│   └─ Cancel repeat notifications
│
└─ logPendingNotifications()
    └─ Debug: In danh sách báo thức pending

background_task_service.dart (Enhanced)
├─ initialize()
│   └─ Khởi tạo Workmanager
│
├─ scheduleMedicineCheckTask()
│   └─ Chạy mỗi 4 giờ
│
└─ _handleMedicineCheckTask()
    ├─ Lấy danh sách thuốc hôm nay
    ├─ Lặp từng thuốc & từng giờ
    ├─ Tính ID: hash(medicineId + index)
    └─ Call scheduleDailyNotification()

notification_tracker.dart (NEW - Optional)
├─ Track notification status
├─ Handle repeat/snooze logic
└─ Manage nagging notifications
```

### Repositories (lib/repositories/)
```
medicine_repository.dart (Enhanced)
├─ getTodayMedicines()
│   └─ Lấy thuốc cần uống hôm nay
│
├─ recordMedicineIntake()
│   └─ Lưu record khi user uống
│
├─ getMedicineIntakes()
│   └─ Lịch sử uống thuốc
│
└─ getScheduledNotifications()
    └─ Danh sách báo thức đang active
```

### Screens (lib/screens/)
```
add_med_screen.dart (Enhanced)
├─ Schedule notifications sau khi lưu
│   └─ Call _handleSave() → scheduleDailyNotification()
│
└─ Cancel cũ trước khi tạo mới
    └─ Tránh trùng lặp ID

medicine_list_screen.dart (NEW)
├─ Hiển thị danh sách báo thức hôm nay
├─ Status: "pending", "taken", "skipped"
└─ Edit/Delete báo thức

medicine_intake_history.dart (NEW)
├─ Lịch sử uống thuốc
├─ Filter by date/medicine
└─ Statistics: taken%, adherence
```

---

## 🔧 Implementasi Chi Tiết

### 1️⃣ Notification Channel Creation (Android 8+)
```dart
// notification_service.dart - initialize()
if (Platform.isAndroid) {
  final AndroidFlutterLocalNotificationsPlugin? androidImpl =
      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
  
  if (androidImpl != null) {
    await androidImpl.createNotificationChannel(
      AndroidNotificationChannel(
        'medicine_alarm_channel_v6',
        'Nhắc nhở uống thuốc',
        description: 'Kênh báo thức cho thuốc',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );
  }
}
```

### 2️⃣ Schedule Exact Alarm (1 phút trước)
```dart
// notification_service.dart - scheduleDailyNotification()
Future<void> scheduleDailyNotification({
  required int id,
  required String title,
  required String body,
  required TimeOfDay time,
  String? payload,
}) async {
  final now = tz.TZDateTime.now(tz.local);
  
  // Trigger 1 phút trước giờ uống
  var scheduledDate = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
  ).subtract(const Duration(minutes: 1)); // ← 1 PHÚT TRƯỚC
  
  // Nếu đã qua, schedule cho ngày mai
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  
  await _flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    title,
    body,
    scheduledDate,
    NotificationDetails(
      android: _getAlarmNotificationDetails(showActions: true),
      iOS: const DarwinNotificationDetails(
        presentSound: true,
        interruptionLevel: InterruptionLevel.critical,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time, // ← LẶP HÀNG NGÀY
    payload: payload,
  );
  
  debugPrint('📅 Scheduled: $title at ${time.hour}:${time.minute}');
}
```

### 3️⃣ Background Task Scheduling (Mỗi 4 giờ)
```dart
// background_task_service.dart - _handleMedicineCheckTask()
Future<void> _handleMedicineCheckTask() async {
  try {
    debugPrint('🔔 Checking medicines for scheduling...');
    
    // Khởi tạo Supabase
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );
    } catch (_) {}
    
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    
    if (user == null) {
      debugPrint('⚠️ No user, skipping');
      return;
    }
    
    // Lấy dữ liệu thuốc
    final medicineRepo = MedicineRepository(supabase);
    final medicines = await medicineRepo.getTodayMedicines(user.id);
    
    if (medicines.isEmpty) {
      debugPrint('ℹ️ No medicines to schedule');
      return;
    }
    
    // Khởi tạo Notification Service
    final notificationService = NotificationService();
    await notificationService.initialize();
    
    // Schedule từng thuốc
    for (var medicine in medicines) {
      if (!medicine.isActive) continue;
      
      // Lặp từng giờ uống
      for (int i = 0; i < medicine.scheduleTimes.length; i++) {
        final scheduleTime = medicine.scheduleTimes[i];
        final timeOfDay = scheduleTime.timeOfDay;
        
        // Tạo ID duy nhất
        final notificationId = 
            NotificationService.generateNotificationId(medicine.id, i);
        
        // Schedule
        await notificationService.scheduleDailyNotification(
          id: notificationId,
          title: 'Đến giờ uống thuốc! 💊',
          body: '${medicine.name} - ${medicine.dosageStrength}, '
              '${medicine.quantityPerDose} viên',
          time: timeOfDay,
          payload: 'medicine:${medicine.id}',
        );
      }
    }
    
    debugPrint('✅ Scheduling completed');
  } catch (e) {
    debugPrint('❌ Error: $e');
  }
}
```

### 4️⃣ Handle Notification Actions
```dart
// notification_service.dart - handleActionBackground()
static Future<void> handleActionBackground(
  NotificationResponse details,
) async {
  final actionId = details.actionId;
  final payload = details.payload;
  
  if (payload == null || !payload.startsWith('medicine:')) return;
  
  final medicineId = payload.split(':')[1];
  
  if (actionId == 'TAKEN_ACTION') {
    debugPrint('✅ User marked as TAKEN: $medicineId');
    await _markMedicineAsTaken(medicineId, details.id);
  } else if (actionId == 'SNOOZE_ACTION') {
    debugPrint('⏱️ User SNOOZED: $medicineId');
    await _scheduleSnooze(medicineId);
  }
}

static Future<void> _markMedicineAsTaken(
  String medicineId,
  int? notificationId,
) async {
  try {
    // Khởi tạo Supabase nếu cần
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );
    } catch (_) {}
    
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;
    
    // Lấy thông tin thuốc
    final medicineData = await supabase
        .from('user_medicines')
        .select()
        .eq('id', medicineId)
        .single();
    
    final medicine = UserMedicine.fromJson(medicineData);
    
    // Ghi vào medicine_intakes
    final now = DateTime.now();
    await supabase.from('medicine_intakes').insert({
      'user_id': user.id,
      'user_medicine_id': medicineId,
      'medicine_name': medicine.name,
      'dosage_strength': medicine.dosageStrength,
      'quantity_per_dose': medicine.quantityPerDose,
      'scheduled_date': now.toIso8601String().split('T')[0],
      'scheduled_time': '${now.hour}:${now.minute}:00',
      'taken_at': now.toIso8601String(),
      'status': 'taken',
    });
    
    // Cancel repeat notifications
    if (notificationId != null) {
      final service = NotificationService();
      await service.initialize();
      await service.cancelNotification(notificationId);
      await service.cancelNotification(notificationId + 1); // Nagging
    }
    
    debugPrint('✅ Recorded as taken');
  } catch (e) {
    debugPrint('❌ Error: $e');
  }
}
```

---

## 📊 Database Schema Cần Thiết

### user_medicines table
```sql
id | name | dosageStrength | quantityPerDose | startDate | endDate | isActive | ...
```

### medicine_schedule_times table
```sql
id | scheduleId | timeOfDay | orderIndex
```

### medicine_intakes table (NEW)
```sql
id | user_id | user_medicine_id | medicine_name | dosage_strength |
quantity_per_dose | scheduled_date | scheduled_time | taken_at | status | ...
```

---

## ✅ Checklist Triển Khai

### Phase 1: Core Setup
- [ ] Create Notification Channel
- [ ] Setup AlarmManager permissions
- [ ] Add Platform Channels (nếu cần)
- [ ] Test exact alarm setting

### Phase 2: Scheduling Logic
- [ ] Calculate 1-minute advance trigger
- [ ] Generate unique notification IDs
- [ ] Support daily repetition
- [ ] Background task mỗi 4 giờ

### Phase 3: User Interactions
- [ ] Show notifications on lock screen
- [ ] Add "Đã uống" action
- [ ] Add "Hoãn 10p" action
- [ ] Record intake to database

### Phase 4: Testing
- [ ] Test on Android 6.0+
- [ ] Test on Android 12+ (exact alarm)
- [ ] Test on Android 13+ (notifications)
- [ ] Test battery optimization bypass
- [ ] Test background task triggers

---

## 🎯 Kết Quả Mong Đợi

✅ **Notification hiển thị chính xác 1 phút trước** giờ uống thuốc  
✅ **Hoạt động ngoài app** (background)  
✅ **Không bị mute** ngay cả ở chế độ silent  
✅ **Hiển thị trên lock screen** toàn màn hình  
✅ **Hỗ trợ 3 loại lặp lại** (hôm nay, mỗi ngày, ngày xen kỳ)  
✅ **Track lịch sử** uống thuốc  
✅ **Optimize pin** nhưng vẫn đáng tin cậy  

---

## 📚 Tài Liệu Tham Khảo

- Kotlin architecture: ALARM_SOURCE_CODE.kt
- Medication reminder guide: MEDICATION_REMINDER_FEATURE.md
- Usage guide: USAGE_GUIDE.md
