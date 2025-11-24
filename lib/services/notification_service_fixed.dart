import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mediminder/models/user_medicine.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';

// Top-level function để handle notification tap từ background
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('🔔🔔 BACKGROUND Notification received!');
  debugPrint('🔔 Notification ID: ${notificationResponse.id}');
  debugPrint('🔔 Payload: ${notificationResponse.payload}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️ NotificationService already initialized');
      return;
    }

    debugPrint('🔧 Initializing NotificationService...');

    // 1. Cấu hình Timezone (Quan trọng để báo đúng giờ)
    tz_data.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('✅ Timezone initialized: $timeZoneName');
    } catch (e) {
      debugPrint('⚠️ Error initializing timezone: $e');
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
        debugPrint('✅ Fallback timezone set to Asia/Ho_Chi_Minh');
      } catch (_) {
        tz.setLocalLocation(tz.local);
        debugPrint('✅ Fallback timezone set to local');
      }
    }

    // 2. Cấu hình Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. Cấu hình iOS
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('✅ [FOREGROUND] Notification tapped/received!');
        debugPrint('   ID: ${details.id}');
        debugPrint('   Title: ${details.notification?.title}');
        debugPrint('   Body: ${details.notification?.body}');
        debugPrint('   Payload: ${details.payload}');
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // 4. CREATE NOTIFICATION CHANNEL for Android 8+
    if (Platform.isAndroid) {
      try {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();

        if (androidImplementation != null) {
          await androidImplementation.createNotificationChannel(
            AndroidNotificationChannel(
              'medicine_alarm_channel_v7', // Updated channel ID
              'Nhắc nhở uống thuốc',
              description: 'Kênh thông báo quan trọng cho việc uống thuốc',
              importance: Importance.max,
              enableVibration: true,
              playSound: true,
              audioAttributesUsage: AudioAttributesUsage.alarm,
              showBadge: true,
            ),
          );
          debugPrint(
            '✅ Notification Channel created: medicine_alarm_channel_v7',
          );
        }
      } catch (e) {
        debugPrint('❌ Error creating notification channel: $e');
      }
    }

    _isInitialized = true;
    debugPrint('✅ NotificationService initialization completed!');
  }

  // Xin quyền
  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      debugPrint('🔐 Requesting Android permissions...');

      // POST_NOTIFICATIONS (required for Android 13+)
      final postNotifications = await Permission.notification.request();
      debugPrint(
        '   POST_NOTIFICATIONS: ${postNotifications.isDenied
            ? '❌ DENIED'
            : postNotifications.isDenied
            ? '⏸️ DENIED'
            : '✅ GRANTED'}',
      );

      // SCHEDULE_EXACT_ALARM
      final exactAlarm = await Permission.scheduleExactAlarm.request();
      debugPrint(
        '   SCHEDULE_EXACT_ALARM: ${exactAlarm.isDenied ? '❌ DENIED' : '✅ GRANTED'}',
      );
    }
  }

  Future<void> requestBatteryPermission() async {
    if (Platform.isAndroid) {
      debugPrint('🔋 Requesting battery optimization exemption...');
      try {
        final status = await Permission.ignoreBatteryOptimizations.status;
        if (status.isDenied) {
          await Permission.ignoreBatteryOptimizations.request();
          debugPrint('✅ Battery optimization exemption requested');
        } else {
          debugPrint('✅ Battery optimizations already ignored.');
        }
      } catch (e) {
        debugPrint('⚠️ Error requesting battery permission: $e');
      }
    }
  }

  // Cấu hình chi tiết thông báo dạng Báo thức
  AndroidNotificationDetails _getAlarmNotificationDetails({
    bool showActions = true,
  }) {
    return AndroidNotificationDetails(
      'medicine_alarm_channel_v7', // Updated channel ID
      'Nhắc nhở uống thuốc',
      channelDescription: 'Kênh thông báo quan trọng cho việc uống thuốc',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      // sound: null, // Use default sound
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
      audioAttributesUsage: AudioAttributesUsage.alarm,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.alarm,
      showWhen: true,
      when: DateTime.now().millisecondsSinceEpoch,
      actions: showActions
          ? [
              const AndroidNotificationAction(
                'TAKEN_ACTION',
                'Đã uống',
                showsUserInterface: true,
                titleColor: Colors.green,
              ),
              const AndroidNotificationAction(
                'SNOOZE_ACTION',
                'Hoãn 10p',
                showsUserInterface: false,
              ),
            ]
          : null,
    );
  }

  // Hiển thị notification ngay lập tức
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    debugPrint('📢 [IMMEDIATE] Showing notification: ID=$id');
    debugPrint('   Title: $title');
    debugPrint('   Body: $body');

    try {
      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        NotificationDetails(android: _getAlarmNotificationDetails()),
        payload: payload,
      );
      debugPrint('✅ Notification shown successfully');
    } catch (e) {
      debugPrint('❌ Error showing notification: $e');
    }
  }

  // Test immediate notification (hiển thị ngay)
  Future<void> testImmediateNotification() async {
    try {
      debugPrint('🧪 TEST: Showing immediate notification');
      await showNotification(
        id: 888888,
        title: '🔔 TEST IMMEDIATE',
        body:
            'Thông báo test ngay lập tức - Nếu thấy cái này thì notification đang hoạt động!',
      );
      debugPrint('✅ Test immediate notification sent');
    } catch (e) {
      debugPrint('❌ Error showing test immediate notification: $e');
    }
  }

  // Lên lịch notification cho một thời gian cụ thể (test)
  Future<void> scheduleTestAlarm() async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = now.add(const Duration(seconds: 5));

      debugPrint('🧪 TEST SCHEDULED: Scheduling notification in 5 seconds');
      debugPrint('   Current time: $now');
      debugPrint('   Scheduled time: $scheduledDate');

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        999999,
        '🔔 TEST ALARM',
        'Nếu bạn thấy cái này, báo thức đang hoạt động tốt! 🎉',
        scheduledDate,
        NotificationDetails(
          android: _getAlarmNotificationDetails(),
          iOS: const DarwinNotificationDetails(
            presentSound: true,
            interruptionLevel: InterruptionLevel.critical,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('✅ Test alarm scheduled successfully');
    } catch (e) {
      debugPrint('❌ Error scheduling test alarm: $e');
    }
  }

  // Lên lịch lặp lại hàng ngày (CHỦ YẾU - dùng cho medicine reminders)
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
  }) async {
    try {
      // Check permissions first
      if (Platform.isAndroid) {
        final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
        if (!exactAlarmStatus.isGranted) {
          debugPrint('⚠️ SCHEDULE_EXACT_ALARM not granted. Requesting...');
          await Permission.scheduleExactAlarm.request();
        }

        final notificationStatus = await Permission.notification.status;
        if (!notificationStatus.isGranted) {
          debugPrint('⚠️ POST_NOTIFICATIONS not granted. Requesting...');
          await Permission.notification.request();
        }
      }

      // Lấy thời gian hiện tại theo timezone đã setup
      final now = tz.TZDateTime.now(tz.local);

      // Tạo mốc thời gian nhắc
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // Nếu giờ này đã qua rồi, thì đặt cho ngày mai
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
        debugPrint('   ⚠️ Scheduled time already passed, moving to tomorrow');
      }

      // 🔍 DIAGNOSTIC LOG
      debugPrint(
        '📅 [SCHEDULE_DAILY] ID=$id, Time=${time.hour}:${time.minute}',
      );
      debugPrint('   Current time: $now (timezone: ${tz.local.name})');
      debugPrint('   Scheduled time: $scheduledDate');
      debugPrint(
        '   Minutes until trigger: ${scheduledDate.difference(now).inMinutes}',
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        NotificationDetails(
          android: _getAlarmNotificationDetails(),
          iOS: const DarwinNotificationDetails(
            presentSound: true,
            interruptionLevel: InterruptionLevel.critical,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Lặp lại mỗi ngày
        payload: payload,
      );

      // Verify it was scheduled
      final List<PendingNotificationRequest> pending =
          await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      final wasScheduled = pending.any((p) => p.id == id);

      debugPrint('✅ Scheduled Daily: ID=$id at ${time.hour}:${time.minute}');
      debugPrint(
        '   ✓ Verified in pending list: $wasScheduled (Total: ${pending.length})',
      );
    } catch (e) {
      debugPrint('❌ Error scheduling daily notification: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      debugPrint('✅ Canceled notification: ID=$id');
    } catch (e) {
      debugPrint('❌ Error canceling notification: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('✅ Canceled all notifications');
    } catch (e) {
      debugPrint('❌ Error canceling all notifications: $e');
    }
  }

  // Debug: Lấy danh sách pending notifications
  Future<void> logPendingNotifications() async {
    final List<PendingNotificationRequest> pendingNotifications =
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();

    debugPrint(
      '📋 Total pending notifications: ${pendingNotifications.length}',
    );
    for (var notification in pendingNotifications) {
      debugPrint(
        '  - ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}',
      );
    }
  }

  // Tạo ID duy nhất từ MedicineID và index giờ
  static int generateNotificationId(String medicineId, int timeIndex) {
    try {
      int hash = medicineId.hashCode.abs();
      return (hash % 100000000 * 10) + timeIndex;
    } catch (e) {
      return DateTime.now().millisecondsSinceEpoch ~/ 1000;
    }
  }

  Future<void> scheduleRemindersForMedicine(
    UserMedicine medicine, {
    required int daysToSchedule,
  }) async {}
}

extension on NotificationResponse {
  get notification => null;
}
