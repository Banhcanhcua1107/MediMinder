# 🔄 MIGRATION GUIDE: Integrate Enhanced Notification System

## 📋 Current State vs Enhanced State

### Current Implementation
- ✅ Basic notification scheduling
- ✅ Timezone support
- ✅ Channel creation
- ⚠️ Missing: Advanced action handling
- ⚠️ Missing: Intake tracking
- ⚠️ Missing: Background action processing

### Enhanced Implementation
- ✅ All of above +
- ✅ Background action handlers (@pragma)
- ✅ Medicine intake recording
- ✅ Snooze functionality
- ✅ Advanced intake model
- ✅ Better error handling

---

## 🚀 STEP-BY-STEP INTEGRATION

### Step 1: Replace NotificationService (OPTIONAL - Backwards Compatible)

**Option A: Keep Current + Add Enhanced**
```dart
// Use the current notification_service.dart as-is
// It already has all essential features

// Add enhanced_notification_service.dart for new features like:
// - Automatic action handling
// - Intake recording
// - Snooze logic
```

**Option B: Replace with Enhanced**
```dart
// If you want full replacement:
// 1. Backup notification_service.dart
// 2. Copy notification_service_enhanced.dart → notification_service.dart
// 3. Update imports
// 4. Test thoroughly
```

**Recommendation**: **Option A** - Keep current working implementation, add enhanced gradually.

---

### Step 2: Add Intake Tracking

**Create medicine_intake.dart** (if not exists)
```
✅ Already provided in lib/models/medicine_intake.dart
```

**Update MedicineRepository to handle intakes**
```dart
class MedicineRepository {
  // ... existing code ...
  
  // NEW: Record medicine intake
  Future<void> recordMedicineIntake(MedicineIntake intake) async {
    await _supabase
        .from('medicine_intakes')
        .insert(intake.toJson());
  }
  
  // NEW: Get intake history
  Future<List<MedicineIntake>> getIntakeHistory(
    String userId,
    String medicineId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    var query = _supabase
        .from('medicine_intakes')
        .select()
        .eq('user_id', userId)
        .eq('user_medicine_id', medicineId);
    
    if (fromDate != null) {
      query = query.gte('scheduled_date', fromDate.toIso8601String());
    }
    if (toDate != null) {
      query = query.lte('scheduled_date', toDate.toIso8601String());
    }
    
    final data = await query;
    return (data as List).map((e) => MedicineIntake.fromJson(e)).toList();
  }
}
```

---

### Step 3: Update Background Task Service

**Current code is good!** Just ensure it's using the correct notification method:

```dart
// ✅ Current _handleMedicineCheckTask() already does:
for (var medicine in medicines) {
  for (int i = 0; i < medicine.scheduleTimes.length; i++) {
    final scheduleTime = medicine.scheduleTimes[i];
    final timeOfDay = scheduleTime.timeOfDay;

    await notificationService.scheduleDailyNotification(
      id: NotificationService.generateNotificationId(medicine.id, i),
      title: 'Đến giờ uống thuốc! 💊',
      body: '${medicine.name} - ${medicine.dosageStrength}, '
          '${medicine.quantityPerDose} viên',
      time: timeOfDay,
      payload: 'medicine:${medicine.id}',
    );
  }
}
```

---

### Step 4: Add Action Handler (NEW)

**Create in NotificationService**:

```dart
// Add to NotificationService class

/// Handle notification actions (Taken/Snooze)
static Future<void> handleActionBackground(
  NotificationResponse details,
) async {
  final actionId = details.actionId;
  final payload = details.payload;
  
  if (payload == null || !payload.startsWith('medicine:')) return;
  
  final medicineId = payload.split(':')[1];
  
  if (actionId == 'TAKEN_ACTION') {
    await _recordMedicineAsTaken(medicineId, details.id);
  } else if (actionId == 'SNOOZE_ACTION') {
    await _rescheduleNotification(medicineId, details.id);
  }
}

static Future<void> _recordMedicineAsTaken(
  String medicineId,
  int? notificationId,
) async {
  try {
    // Initialize Supabase
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );
    } catch (_) {}
    
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;
    
    // Get medicine info
    final medicineData = await supabase
        .from('user_medicines')
        .select()
        .eq('id', medicineId)
        .single();
    
    final medicine = UserMedicine.fromJson(medicineData);
    
    // Record intake
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
    
    // Cancel notification
    if (notificationId != null) {
      final service = NotificationService();
      await service.initialize();
      await service.cancelNotification(notificationId);
    }
    
    debugPrint('✅ Recorded as taken');
  } catch (e) {
    debugPrint('❌ Error: $e');
  }
}

static Future<void> _rescheduleNotification(
  String medicineId,
  int? notificationId,
) async {
  try {
    debugPrint('⏱️ Snoozing for 10 minutes');
    
    if (notificationId != null) {
      final service = NotificationService();
      await service.initialize();
      
      final now = tz.TZDateTime.now(tz.local);
      final snoozeTime = now.add(const Duration(minutes: 10));
      
      await service._flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId + 10000,
        '⏰ Nhắc nhở lại: Uống thuốc',
        'Bạn vừa hoãn 10 phút',
        snoozeTime,
        NotificationDetails(
          android: service._getAlarmNotificationDetails(showActions: true),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'medicine:$medicineId',
      );
    }
  } catch (e) {
    debugPrint('❌ Error snoozing: $e');
  }
}
```

---

### Step 5: Update add_med_screen.dart

**Ensure notifications are scheduled after save:**

```dart
// In _handleSave() or similar

Future<void> _handleSave() async {
  // ... validation & save to Supabase ...
  
  try {
    // 1. Save medicine
    final newMedicine = await _medicineProvider.addMedicine(medicineData);
    
    // 2. Schedule notifications (IMPORTANT)
    final notificationService = NotificationService();
    await notificationService.initialize();
    
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
      );
    }
    
    // 3. Show success
    await notificationService.showImmediateNotification(
      id: 999999,
      title: '✅ Đã lưu thuốc',
      body: 'Sẽ nhận thông báo lúc ${formattedTimes}',
    );
    
  } catch (e) {
    debugPrint('❌ Error: $e');
    // Show error dialog
  }
}
```

---

### Step 6: Create Intake History Screen (OPTIONAL)

**New screen to view medication adherence:**

```dart
// lib/screens/medicine_intake_history.dart

class MedicineIntakeHistoryScreen extends StatefulWidget {
  final String medicineId;
  
  const MedicineIntakeHistoryScreen({required this.medicineId});

  @override
  State<MedicineIntakeHistoryScreen> createState() =>
      _MedicineIntakeHistoryScreenState();
}

class _MedicineIntakeHistoryScreenState extends State<MedicineIntakeHistoryScreen> {
  late MedicineRepository _medicineRepository;
  List<MedicineIntake> _intakes = [];
  
  @override
  void initState() {
    super.initState();
    _loadIntakeHistory();
  }
  
  Future<void> _loadIntakeHistory() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;
      
      _medicineRepository = MedicineRepository(supabase);
      
      final intakes = await _medicineRepository.getIntakeHistory(
        user.id,
        widget.medicineId,
        fromDate: DateTime.now().subtract(const Duration(days: 30)),
      );
      
      setState(() {
        _intakes = intakes;
      });
    } catch (e) {
      debugPrint('Error: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử uống thuốc')),
      body: ListView.builder(
        itemCount: _intakes.length,
        itemBuilder: (context, index) {
          final intake = _intakes[index];
          final isTaken = intake.status == 'taken';
          
          return ListTile(
            leading: Icon(
              isTaken ? Icons.check_circle : Icons.schedule,
              color: isTaken ? Colors.green : Colors.orange,
            ),
            title: Text('${intake.scheduledDate} ${intake.scheduledTime}'),
            subtitle: Text(intake.status),
            trailing: isTaken
                ? Text(intake.takenAt ?? 'N/A')
                : null,
          );
        },
      ),
    );
  }
}
```

---

### Step 7: Database Migration

**Create migration in Supabase SQL:**

```sql
-- Create medicine_intakes table if not exists
CREATE TABLE IF NOT EXISTS medicine_intakes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  user_medicine_id TEXT NOT NULL REFERENCES user_medicines(id),
  medicine_name TEXT NOT NULL,
  dosage_strength TEXT,
  quantity_per_dose INTEGER DEFAULT 1,
  scheduled_date DATE NOT NULL,
  scheduled_time TIME NOT NULL,
  taken_at TIMESTAMP,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'taken', 'skipped')),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX idx_medicine_intakes_user_date 
ON medicine_intakes(user_id, scheduled_date DESC);

CREATE INDEX idx_medicine_intakes_status 
ON medicine_intakes(status);

CREATE INDEX idx_medicine_intakes_medicine 
ON medicine_intakes(user_medicine_id);

-- Enable RLS if needed
ALTER TABLE medicine_intakes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only see their own intakes"
  ON medicine_intakes
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own intakes"
  ON medicine_intakes
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

---

## ✅ TESTING AFTER MIGRATION

### Test 1: Basic Scheduling
```
1. Add medicine with time = now + 2 minutes
2. Wait for notification at correct time
3. Check logcat for scheduling logs
```

### Test 2: Action Handling
```
1. Notification appears
2. Tap "Đã uống"
3. Check medicine_intakes table → record created
4. Notification should cancel
```

### Test 3: Snooze
```
1. Tap "Hoãn 10p"
2. New notification should appear 10 min later
3. Check ID is offset by 10000
```

### Test 4: Background Task
```
1. Close app
2. Wait 4+ hours
3. Background task should refresh schedule
4. Check logs in logcat
```

---

## 🔍 TROUBLESHOOTING DURING MIGRATION

### Issue: "method 'scheduleDailyNotification' not found"
**Solution**: Make sure NotificationService import is correct
```dart
import 'package:mediminder/services/notification_service.dart';
```

### Issue: "No Supabase instance"
**Solution**: Initialize Supabase in main() before using
```dart
await Supabase.initialize(
  url: AppConstants.supabaseUrl,
  anonKey: AppConstants.supabaseAnonKey,
);
```

### Issue: "medicine_intakes table not found"
**Solution**: Run the SQL migration in Supabase dashboard

### Issue: "Notifications not appearing"
**Solution**: Check logs
```
✅ Notification Channel created
✅ [SCHEDULE] ID=XXX
✅ Pending: X notifications
```

---

## 📊 BEFORE & AFTER COMPARISON

| Feature | Before | After |
|---------|--------|-------|
| Schedule Notifications | ✅ | ✅ |
| Daily Repetition | ✅ | ✅ |
| Timezone Support | ✅ | ✅ |
| Action Handling | ❌ | ✅ |
| Intake Tracking | ❌ | ✅ |
| Snooze Feature | ❌ | ✅ |
| History View | ❌ | ✅ |
| Adherence Stats | ❌ | ✅ |
| Background Actions | ❌ | ✅ |

---

## 🎯 NEXT STEPS

1. **Immediate**: Test enhanced notification service
2. **Week 1**: Add intake tracking & recording
3. **Week 2**: Build history/adherence screens
4. **Week 3**: Add statistics & insights
5. **Week 4**: Optimize performance & battery

---

## 📞 QUICK REFERENCE

| File | Purpose | Status |
|------|---------|--------|
| notification_service.dart | Core notifications | ✅ Working |
| notification_service_enhanced.dart | Enhanced features | ✅ New |
| background_task_service.dart | Background scheduling | ✅ Working |
| medicine_intake.dart | Data model | ✅ New |
| add_med_screen.dart | UI for adding | ⚠️ Update needed |
| medicine_repository.dart | Data access | ⚠️ Add methods |
| IMPLEMENTATION_GUIDE.md | How-to guide | ✅ Comprehensive |
| MEDICATION_REMINDER_SYSTEM.md | Architecture | ✅ Detailed |
