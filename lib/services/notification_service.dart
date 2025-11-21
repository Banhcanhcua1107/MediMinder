import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
    if (_isInitialized) return;

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
      } catch (_) {
        tz.setLocalLocation(tz.local);
      }
    }

    // 2. Cấu hình icon cho Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. Cấu hình cho iOS
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('🔔 Notification received (foreground): ${details.payload}');
        debugPrint('🔔 Notification ID: ${details.id}');
        debugPrint('🔔 Action ID: ${details.actionId}');
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    _isInitialized = true;
    debugPrint('✅ Notification Service initialized');
  }

  // Xin quyền (Cập nhật cho Android 12, 13, 14)
  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      // Quyền thông báo cơ bản (Android 13+)
      await androidImplementation?.requestNotificationsPermission();

      // Quyền đặt lịch chính xác từng phút (Android 12+)
      // BẮT BUỘC để báo thức hoạt động đúng giờ
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  // Xin quyền bỏ qua tối ưu hóa pin (Quan trọng cho báo thức)
  Future<void> requestBatteryPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.ignoreBatteryOptimizations.status;
      if (status.isDenied) {
        debugPrint('🔋 Requesting ignore battery optimizations...');
        await Permission.ignoreBatteryOptimizations.request();
      } else {
        debugPrint('✅ Battery optimizations already ignored.');
      }
    }
  }

  // Cấu hình chi tiết thông báo dạng Báo thức
  AndroidNotificationDetails _getAlarmNotificationDetails() {
    return AndroidNotificationDetails(
      'medicine_alarm_channel_v5', // ID kênh (Đổi ID để reset cài đặt âm thanh)
      'Nhắc nhở uống thuốc', // Tên hiển thị
      channelDescription: 'Kênh thông báo quan trọng cho việc uống thuốc',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound:
          null, // Mặc định sẽ dùng âm thanh thông báo của hệ thống (Ting ting)
      enableVibration: true,
      // Rung mạnh: Im lặng, Rung 1s, Nghỉ 0.5s, Rung 1s...
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
      audioAttributesUsage: AudioAttributesUsage
          .notification, // Dùng luồng âm thanh thông báo (Ting ting) thay vì báo thức
      fullScreenIntent: true, // Hiển thị trên màn hình khóa
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.alarm,
    );
  }

  // Hàm hiển thị ngay lập tức (Test)
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool useAlarm = false,
  }) async {
    debugPrint('🔔 Showing notification: ID=$id, Title=$title');
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(android: _getAlarmNotificationDetails()),
      payload: payload,
    );
  }

  // Hàm hiển thị thông báo ngay lập tức (không chờ)
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        NotificationDetails(android: _getAlarmNotificationDetails()),
        payload: payload,
      );
      debugPrint('📢 Immediate notification shown: ID=$id - $title');
    } catch (e) {
      debugPrint('❌ Error showing immediate notification: $e');
    }
  }

  // Hàm lên lịch lặp lại hàng ngày
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
  }) async {
    try {
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

      // Nếu giờ này đã qua rồi HOẶC là ngay bây giờ (tránh nổ ngay lập tức), thì đặt cho ngày mai
      if (scheduledDate.isBefore(now) || scheduledDate.isAtSameMomentAs(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

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
        androidScheduleMode: AndroidScheduleMode
            .exactAllowWhileIdle, // Thay đổi chế độ để đảm bảo báo thức nổ đúng giờ và có tiếng
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents:
            DateTimeComponents.time, // Lặp lại mỗi ngày cùng giờ
        payload: payload,
      );

      debugPrint(
        '✅ Scheduled Daily: ID=$id at ${time.hour}:${time.minute} (Next trigger: $scheduledDate)',
      );
    } catch (e) {
      debugPrint('❌ Error scheduling daily notification: $e');
    }
  }

  // Test Alarm: Nổ sau 10 giây
  Future<void> scheduleTestAlarm() async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = now.add(const Duration(seconds: 10));

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        999999, // ID đặc biệt cho test
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

      debugPrint('✅ Scheduled Test Alarm in 10 seconds');
    } catch (e) {
      debugPrint('❌ Error scheduling test alarm: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
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

  // TEST: Show notification for next 5 minutes check
  Future<void> testShowPendingNotifications() async {
    await logPendingNotifications();
  }

  // Tạo ID duy nhất từ MedicineID và index giờ
  static int generateNotificationId(String medicineId, int timeIndex) {
    try {
      // Lấy hashcode dương
      int hash = medicineId.hashCode.abs();
      // Giới hạn để nằm trong range của Int32
      return (hash % 100000000 * 10) + timeIndex;
    } catch (e) {
      return DateTime.now().millisecondsSinceEpoch ~/ 1000;
    }
  }
}
