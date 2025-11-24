// filepath: lib/services/notification_service_enhanced.dart
// ============================================================
// ENHANCED NOTIFICATION SERVICE - Based on Kotlin Architecture
// ============================================================

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mediminder/models/user_medicine.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/constants.dart';

// ============================================================
// TOP-LEVEL CALLBACKS (Dart background execution)
// ============================================================

/// Callback khi người dùng bấm notification ở background
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('🔔🔔 BACKGROUND Notification tapped!');
  debugPrint('🔔 ID: ${notificationResponse.id}');
  debugPrint('🔔 ActionID: ${notificationResponse.actionId}');
  debugPrint('🔔 Payload: ${notificationResponse.payload}');

  // Xử lý các action background
  _handleBackgroundAction(notificationResponse);
}

/// Xử lý action từ background (Đã uống/Hoãn)
Future<void> _handleBackgroundAction(
  NotificationResponse notificationResponse,
) async {
  final actionId = notificationResponse.actionId;
  final payload = notificationResponse.payload;

  debugPrint(
    '⚙️ Processing background action: $actionId for payload: $payload',
  );

  if (actionId == 'TAKEN_ACTION' && payload != null) {
    await _recordMedicineAsTaken(payload, notificationResponse.id);
  } else if (actionId == 'SNOOZE_ACTION' && payload != null) {
    await _rescheduleNotification(payload, notificationResponse.id);
  }
}

/// Record medicine as taken
Future<void> _recordMedicineAsTaken(String payload, int? notificationId) async {
  try {
    if (!payload.startsWith('medicine:')) return;

    final medicineId = payload.split(':')[1];
    debugPrint('✅ Recording taken: $medicineId');

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

    // Cancel repeat notification
    if (notificationId != null) {
      final service = NotificationService();
      await service.initialize();
      await service.cancelNotification(notificationId);
    }

    debugPrint('✅ Successfully recorded as taken');
  } catch (e) {
    debugPrint('❌ Error recording taken: $e');
  }
}

/// Reschedule notification (snooze)
Future<void> _rescheduleNotification(
  String payload,
  int? notificationId,
) async {
  try {
    debugPrint('⏱️ Rescheduling notification (snooze 10 min)');

    if (notificationId != null) {
      final service = NotificationService();
      await service.initialize();

      final now = tz.TZDateTime.now(tz.local);
      final snoozeTime = now.add(const Duration(minutes: 10));

      // Rescheduled notification với ID khác để không đè
      await service._flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId + 10000, // Offset ID để khác
        '🔔 Nhắc nhở lại: Uống thuốc',
        'Bạn vừa hoãn 10 phút trước đó',
        snoozeTime,
        NotificationDetails(
          android: service._getAlarmNotificationDetails(showActions: true),
          iOS: const DarwinNotificationDetails(
            presentSound: true,
            interruptionLevel: InterruptionLevel.critical,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      debugPrint('✅ Snoozed until: $snoozeTime');
    }
  } catch (e) {
    debugPrint('❌ Error rescheduling: $e');
  }
}

// ============================================================
// MAIN NOTIFICATION SERVICE CLASS
// ============================================================

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // ============================================================
  // INITIALIZATION (Similar to Android AlarmManager setup)
  // ============================================================

  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('🚀 Initializing Enhanced Notification Service...');

    // 1. Timezone setup (Vietnam)
    tz_data.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('✅ Timezone: $timeZoneName');
    } catch (e) {
      debugPrint('⚠️ Timezone error: $e');
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
      } catch (_) {
        tz.setLocalLocation(tz.local);
      }
    }

    // 2. Platform-specific initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

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
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // 3. Create notification channel for Android 8+ (CRITICAL)
    await _createNotificationChannel();

    _isInitialized = true;
    debugPrint('✅ Enhanced Notification Service initialized');
  }

  /// Create notification channel (Like Android's NotificationChannel)
  Future<void> _createNotificationChannel() async {
    if (!Platform.isAndroid) return;

    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(
          AndroidNotificationChannel(
            'medicine_alarm_channel_v6',
            'Nhắc nhở uống thuốc',
            description: 'Kênh thông báo quan trọng',
            importance: Importance.max,
            enableVibration: true,
            playSound: true,
            audioAttributesUsage: AudioAttributesUsage.alarm,
          ),
        );
        debugPrint('✅ Notification Channel created: medicine_alarm_channel_v6');
      }
    } catch (e) {
      debugPrint('❌ Error creating channel: $e');
    }
  }

  /// Foreground notification response handler
  void _onNotificationResponse(NotificationResponse details) {
    debugPrint('🔔 Foreground notification: ${details.payload}');
    debugPrint('🔔 Action: ${details.actionId}');
  }

  // ============================================================
  // PERMISSIONS (Like Android permissions)
  // ============================================================

  Future<void> requestPermissions() async {
    debugPrint('🔐 Requesting notification permissions...');

    if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      final androidImpl = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      // POST_NOTIFICATIONS (Android 13+)
      await androidImpl?.requestNotificationsPermission();

      // SCHEDULE_EXACT_ALARM (Android 12+)
      await androidImpl?.requestExactAlarmsPermission();
    }

    debugPrint('✅ Permissions requested');
  }

  Future<void> requestBatteryPermission() async {
    if (!Platform.isAndroid) return;

    debugPrint('🔋 Requesting battery optimization bypass...');

    final status = await Permission.ignoreBatteryOptimizations.status;
    if (status.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }

    debugPrint('✅ Battery optimization handled');
  }

  // ============================================================
  // SCHEDULING METHODS (Like AlarmManager.setExactAndAllowWhileIdle)
  // ============================================================

  /// Schedule notification 1 minute BEFORE the intended time
  /// (Like: If should take at 08:00, alarm triggers at 07:59)
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
    int advanceMinutes = 1, // Notify 1 minute before
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);

      // Calculate target time with advance notification
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      ).subtract(Duration(minutes: advanceMinutes));

      // If time has passed, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Debug info
      final minutesUntil = scheduledDate.difference(now).inMinutes;
      debugPrint(
        '📅 [SCHEDULE] ID=$id, Time=${time.hour}:${time.minute}, '
        'Trigger=${scheduledDate.hour}:${scheduledDate.minute} '
        '(${advanceMinutes}min before), In ${minutesUntil}min',
      );

      // Schedule with daily repetition
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
        matchDateTimeComponents: DateTimeComponents.time, // Daily repeat
        payload: payload,
      );

      // Verify scheduled
      await logPendingNotifications();
      debugPrint('✅ Scheduled successfully');
    } catch (e) {
      debugPrint('❌ Error scheduling: $e');
    }
  }

  /// Schedule one-time notification (không lặp lại)
  Future<void> scheduleOneTimeNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    String? payload,
  }) async {
    try {
      final tzDateTime = tz.TZDateTime.from(dateTime, tz.local);

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
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
        payload: payload,
      );

      debugPrint('✅ One-time notification scheduled for $dateTime');
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
  }

  /// Show immediate notification (kiểm tra)
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
      debugPrint('📢 Immediate notification shown: $title');
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
  }

  // ============================================================
  // NOTIFICATION DETAILS (Android-specific)
  // ============================================================

  AndroidNotificationDetails _getAlarmNotificationDetails({
    bool showActions = true,
  }) {
    return AndroidNotificationDetails(
      'medicine_alarm_channel_v6',
      'Nhắc nhở uống thuốc',
      channelDescription: 'Kênh thông báo quan trọng',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: null, // Use system alarm sound
      enableVibration: true,
      vibrationPattern: Int64List.fromList([
        0,
        1000,
        500,
        1000,
        500,
        1000,
      ]), // Strong
      audioAttributesUsage: AudioAttributesUsage.alarm,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.alarm,
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

  // ============================================================
  // MANAGEMENT METHODS
  // ============================================================

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    debugPrint('🗑️ Cancelled notification: $id');
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    debugPrint('🗑️ Cancelled all notifications');
  }

  Future<void> logPendingNotifications() async {
    final pending = await _flutterLocalNotificationsPlugin
        .pendingNotificationRequests();
    debugPrint('📋 Pending: ${pending.length}');
    for (var p in pending) {
      debugPrint('   - ID=${p.id}: ${p.title}');
    }
  }

  // ============================================================
  // UTILITY
  // ============================================================

  static int generateNotificationId(String medicineId, int timeIndex) {
    try {
      int hash = medicineId.hashCode.abs();
      return (hash % 100000000 * 10) + timeIndex;
    } catch (e) {
      return DateTime.now().millisecondsSinceEpoch ~/ 1000;
    }
  }
}
