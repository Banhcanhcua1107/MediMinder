# 🧪 Notification Testing Guide

## Quick Test Scenarios

### Scenario 1: Immediate Test (When Adding Medicine)
1. Open app
2. Add medicine with time = **current time + 1 minute**
3. Should see:
   - ✅ Test notification immediately ("✅ Đã lưu thuốc")
   - ✅ Scheduled notification appears in logs
4. Wait 1 minute → Should see "⏰ Đến giờ uống thuốc!"

### Scenario 2: Background Check (App Closed)
1. Add medicine with time = **current time + 5 minutes**
2. Save and note the medicine name
3. Close app completely
4. Wait 5 minutes
5. Check phone notifications → Should see "⏰ Đến giờ uống thuốc! 💊"
6. Open logcat to see: `🔔 Background medicine check task executing...`

### Scenario 3: App Resume Check
1. Add medicine with time = **current time + 2 minutes**
2. Minimize app (don't close)
3. Wait 2 minutes (can use another app)
4. Reopen MediMinder app
5. Check logs for: `✅ Notification restart check completed`

### Scenario 4: Multiple Times Per Day
1. Add medicine with 3 different times:
   - 08:00
   - 12:00  
   - 20:00
2. Wait for each time (or change system time to test)
3. All 3 times should trigger notifications

## 📊 Debugging with Logcat

### Filter for MediMinder logs:
```bash
adb logcat *:S flutter:V | grep -i "medicine\|notification\|🔔\|✅\|📋"
```

### Key logs to watch:
```
✅ Scheduled Daily: ID=XXXXX at HH:MM
📋 Total pending notifications: X
🔔 Background medicine check task executing...
📋 Checking X medicines at HH:MM
🔔 Notification triggered for [medicine]
📢 Immediate notification shown: ID=XXXXX
✅ Notification restart check completed
```

## 🔧 System Time Testing (To Speed Up)

You can change system time to test without waiting hours:

### On Android Device:
1. Settings → System → Date & time → Automatic time disabled
2. Set time to 1 minute before your test time
3. Wait for notification to trigger
4. **Don't forget to re-enable automatic time!**

Or use ADB:
```bash
adb shell date +%s -s "$(python3 -c 'import time; print(int(time.time() + 60))')"
```

## ✅ Success Criteria

After fixes, you should see:

| When | Expected | Status |
|------|----------|--------|
| Add medicine | Immediate test notification | ✅ |
| At exact time (app open) | Notification appears | ✅ |
| At exact time (app closed) | Notification within 1-15 min | ✅ |
| App resume near medicine time | Quick re-check | ✅ |
| Phone volume on | Notification sound plays | ✅ |
| Phone has vibration | Vibration pattern triggers | ✅ |

## 🚨 Troubleshooting

### No notification after adding medicine:
- [ ] Check app has notification permission
- [ ] Check app is not in "Do Not Disturb" mode
- [ ] Check logcat for errors
- [ ] Restart app

### No notification at scheduled time:
- [ ] Check system time is correct
- [ ] Check Android battery optimization settings
- [ ] Check Workmanager is running (check logcat)
- [ ] Try closing and reopening app

### Notification appears late (15+ minutes):
- [ ] Normal - background task runs every 15 minutes
- [ ] Next update will make it more frequent
- [ ] Try reopening app to trigger immediate check

### Notification sound not working:
- [ ] Check phone volume is on
- [ ] Check "notification_alarm_channel_v3" is not muted in Settings
- [ ] Try restarting app
- [ ] Check Android version (Android 8+ needs channel config)

## 📱 Device Requirements

- **OS**: Android 8.0+ (API 26+)
- **Permissions**: SCHEDULE_EXACT_ALARM, POST_NOTIFICATIONS
- **Features**: Needed for exact time notifications
- **Time**: Must be set correctly (used as trigger reference)

## 💾 Files Changed

The following files have been modified:

1. `lib/services/notification_service.dart`
   - Added `showImmediateNotification()` method
   - Added `testShowPendingNotifications()` method

2. `lib/services/background_task_service.dart`
   - Frequency: 30 min → 15 min
   - Tolerance: 5 min → 2-3 min
   - Better logging

3. `lib/screens/home_screen.dart`
   - Added `_restartNotifications()` method
   - Calls on app resume

See `NOTIFICATION_FIX_SUMMARY.md` for detailed changes.

---

**Last Updated**: 2025-11-20  
**Status**: Ready for Testing ✅
