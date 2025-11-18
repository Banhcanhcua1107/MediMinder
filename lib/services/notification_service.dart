// filepath: lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/material.dart';

/// Service quản lý thông báo cục bộ
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Khởi tạo notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Khởi tạo timezone
    tz_data.initializeTimeZones();

    // Android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
        );

    // Combine settings
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // Initialize plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onSelectNotification,
    );

    // Yêu cầu permission (iOS)
    await _requestIOSPermissions();

    _isInitialized = true;
    debugPrint('✅ Notification Service initialized');
  }

  /// Yêu cầu permission iOS
  Future<void> _requestIOSPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Callback khi nhận thông báo ở foreground (iOS)
  static Future<void> _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    debugPrint('📱 iOS notification received: $id - $title - $body');
  }

  /// Callback khi click vào notification
  static Future<void> _onSelectNotification(
    NotificationResponse notificationResponse,
  ) async {
    final String? payload = notificationResponse.payload;
    debugPrint('🔔 Notification clicked: $payload');

    // TODO: Handle navigation based on payload
    // Ví dụ: if (payload == 'medicine') => Mở medicine list screen
  }

  /// Hiển thị thông báo ngay lập tức
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
            'medicine_channel',
            'Medicine Reminders',
            channelDescription: 'Nhắc nhở uống thuốc',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'Uống thuốc',
            enableVibration: true,
            enableLights: true,
            color: Color(0xFF196EB0),
            playSound: true,
            showWhen: true,
            fullScreenIntent: true, // Hiển thị full screen khi tắt màn hình
            ongoing: false,
          );

      const DarwinNotificationDetails iosNotificationDetails =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      debugPrint('✅ Notification shown: $id - $title');
    } catch (e) {
      debugPrint('❌ Error showing notification: $e');
    }
  }

  /// Lên lịch thông báo tại thời điểm cụ thể
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
            'medicine_channel',
            'Medicine Reminders',
            channelDescription: 'Nhắc nhở uống thuốc',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'Uống thuốc',
            enableVibration: true,
            enableLights: true,
            color: Color(0xFF196EB0),
            playSound: true,
            showWhen: true,
            fullScreenIntent: true, // Hiển thị full screen khi tắt màn hình
          );

      const DarwinNotificationDetails iosNotificationDetails =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      debugPrint('✅ Notification scheduled: $id - $title at $scheduledDate');
    } catch (e) {
      debugPrint('❌ Error scheduling notification: $e');
    }
  }

  /// Lên lịch thông báo định kỳ hàng ngày
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
  }) async {
    try {
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // Nếu thời gian đã qua hôm nay, lên lịch cho ngày mai
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
            'medicine_channel',
            'Medicine Reminders',
            channelDescription: 'Nhắc nhở uống thuốc',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'Uống thuốc',
            enableVibration: true,
            enableLights: true,
            color: Color(0xFF196EB0),
            playSound: true,
            showWhen: true,
            fullScreenIntent: true, // Hiển thị full screen khi tắt màn hình
          );

      const DarwinNotificationDetails iosNotificationDetails =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );

      // Sử dụng zonedSchedule với matchDateTimeComponents để lặp hàng ngày
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Lặp hàng ngày
        payload: payload,
      );

      debugPrint(
        '✅ Daily notification scheduled: $id - $title at ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
      );
    } catch (e) {
      debugPrint('❌ Error scheduling daily notification: $e');
    }
  }

  /// Hủy thông báo theo ID
  Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      debugPrint('✅ Notification cancelled: $id');
    } catch (e) {
      debugPrint('❌ Error cancelling notification: $e');
    }
  }

  /// Hủy tất cả thông báo
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('✅ All notifications cancelled');
    } catch (e) {
      debugPrint('❌ Error cancelling all notifications: $e');
    }
  }

  /// Lấy pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      final List<PendingNotificationRequest> pendingNotifications =
          await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      debugPrint('📋 Pending notifications: ${pendingNotifications.length}');
      return pendingNotifications;
    } catch (e) {
      debugPrint('❌ Error getting pending notifications: $e');
      return [];
    }
  }

  /// Tạo ID thông báo từ medicine + time
  static int generateNotificationId(String medicineId, int timeIndex) {
    // Kết hợp medicineId + timeIndex để tạo ID duy nhất
    // Ví dụ: medicineId="med123" + timeIndex=0 => ID=123000
    try {
      final medicineNum = int.parse(
        medicineId.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      return (medicineNum * 10) + timeIndex;
    } catch (e) {
      // Fallback: dùng hash code
      return (medicineId.hashCode.abs() * 10) + timeIndex;
    }
  }
}
