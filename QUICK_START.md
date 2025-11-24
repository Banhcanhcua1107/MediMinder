# ⚡ QUICK START - Medication Reminder System

## 🎯 In 5 Minutes

### 1️⃣ Copy Enhanced Service (30 seconds)
```
✅ notification_service_enhanced.dart → lib/services/
✅ medicine_intake.dart → lib/models/
```

### 2️⃣ Add Permissions (1 minute)
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
```

### 3️⃣ Initialize in main.dart (2 minutes)
```dart
import 'package:mediminder/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();
  await notificationService.requestBatteryPermission();

  runApp(const MyApp());
}
```

### 4️⃣ Schedule When Adding Medicine (1 minute)
```dart
// In add_med_screen.dart, after saving medicine

final notificationService = NotificationService();
await notificationService.initialize();

for (int i = 0; i < newMedicine.scheduleTimes.length; i++) {
  await notificationService.scheduleDailyNotification(
    id: NotificationService.generateNotificationId(newMedicine.id, i),
    title: '💊 Đến giờ uống thuốc!',
    body: '${newMedicine.name} - ${newMedicine.dosageStrength}',
    time: newMedicine.scheduleTimes[i].timeOfDay,
    payload: 'medicine:${newMedicine.id}',
  );
}
```

### 5️⃣ Test It! (1 minute)
```
1. Add medicine with time = now + 2 minutes
2. Watch notification appear at that time
3. Tap "Đã uống" → should record to database
4. ✅ Done!
```

---

## 🔥 Key Features (Just Work™)

✅ **Exact timing**: 1 minute before user needs to take medicine  
✅ **Daily repetition**: Works every day automatically  
✅ **Lock screen display**: See even on locked phone  
✅ **Background**: Works when app closed  
✅ **Actions**: Mark "Taken" or "Snooze 10 min"  
✅ **Database tracking**: Records all actions  
✅ **Battery safe**: Optimized but reliable  

---

## 📊 Architecture (Simple)

```
User adds medicine
      ↓
Schedule notifications
      ↓
AlarmManager triggers
      ↓
Notification shows
      ↓
User taps action
      ↓
Record to database
      ↓
Next day: repeat
```

---

## 🐛 If It Doesn't Work

### ❌ Notification not appearing
```
✅ Solution:
1. Check device has 2+ minutes remaining
2. Check app gave permissions
3. Check device not in battery saver
4. Check notification channel created (see logs)
5. Restart app & try again
```

### ❌ Action not recording
```
✅ Solution:
1. Check internet connected
2. Check Supabase initialized
3. Check medicine_intakes table exists
4. Check RLS policies allow insertion
```

### ❌ Background task not running
```
✅ Solution:
1. Check device not blocking background
2. Wait 4+ hours for first execution
3. Check Workmanager initialized
4. Restart app
```

---

## 📱 File Locations

```
lib/
  ├─ services/
  │  ├─ notification_service.dart (current - keep it)
  │  ├─ notification_service_enhanced.dart (new - optional)
  │  ├─ background_task_service.dart (current - working)
  │  └─ ...
  ├─ models/
  │  ├─ user_medicine.dart (existing)
  │  ├─ medicine_intake.dart (new - for tracking)
  │  └─ ...
  ├─ screens/
  │  ├─ add_med_screen.dart (update here)
  │  └─ ...
  └─ main.dart (update here)
```

---

## ✨ Expected Timeline

| Time | Action |
|------|--------|
| Now | Add files, update main.dart |
| +10min | Test basic scheduling |
| +30min | Verify notifications appear |
| +1hour | Test "Đã uống" action |
| +4hours | Background task should run |
| +24hours | Notifications repeat next day |

---

## 🚀 Advanced (Optional)

Once basic works:
- [ ] Add intake history screen
- [ ] Add adherence statistics
- [ ] Add smart snooze (extend by 5min if usually late)
- [ ] Add reminders after missed doses
- [ ] Add medication interactions warning

---

## 📞 Need Help?

**1. Check Logs**
```dart
// Enable debug logging
flutter run -v

// Search for notification logs
flutter logs | grep "💊\|✅\|❌"
```

**2. Read Docs**
- `IMPLEMENTATION_GUIDE.md` - Full reference
- `MIGRATION_GUIDE.md` - Step-by-step
- `MEDICATION_REMINDER_SYSTEM.md` - Architecture

**3. Common Issues**
See `TROUBLESHOOTING` section in Implementation Guide

---

## 💡 Pro Tips

1. **Test with 2-minute offset first** (easier to verify)
2. **Check logcat in Android Studio** for native errors
3. **Use DevTools** to verify pending notifications
4. **Test on real device** (emulator sometimes doesn't honor alarms)
5. **Battery optimization off** during development

---

## ✅ Verification Checklist

Before considering "Done":

- [ ] Permissions in AndroidManifest.xml
- [ ] NotificationService initialized in main()
- [ ] Notifications scheduled after medicine saved
- [ ] Notification appears at correct time
- [ ] Tap "Đã uống" → records to database
- [ ] Tap "Hoãn 10p" → notification reschedules
- [ ] Next day → notification repeats
- [ ] App closed → notification still appears
- [ ] Logs show no errors

---

## 🎉 You're Done!

Your users can now:
- ✅ Add medicines with schedule times
- ✅ Receive accurate reminders
- ✅ Mark doses as taken
- ✅ Snooze if needed
- ✅ Track adherence

**Happy coding!** 💊

---

## 📚 More Information

- **Full Guide**: See `IMPLEMENTATION_GUIDE.md`
- **Architecture**: See `MEDICATION_REMINDER_SYSTEM.md`
- **Migration**: See `MIGRATION_GUIDE.md`
- **Reference**: See attachments (Kotlin code + examples)
