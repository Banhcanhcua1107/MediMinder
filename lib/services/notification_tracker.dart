import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'notification_service.dart';

/// ReminderData Model
class ReminderData {
  final String userId;
  final String medicineId;
  final String medicineName;
  final String dosageStrength;
  final int quantityPerDose;
  final DateTime scheduledDateTime;
  final DateTime reminderDateTime;
  final int reminderMinutesBefore;

  ReminderData({
    required this.userId,
    required this.medicineId,
    required this.medicineName,
    required this.dosageStrength,
    required this.quantityPerDose,
    required this.scheduledDateTime,
    required this.reminderDateTime,
    required this.reminderMinutesBefore,
  });

  factory ReminderData.fromJson(Map<String, dynamic> json) {
    return ReminderData(
      userId: json['user_id'],
      medicineId: json['user_medicine_id'],
      medicineName: json['medicine_name'],
      dosageStrength: json['dosage_strength'] ?? 'N/A',
      quantityPerDose: json['quantity_per_dose'] ?? 1,
      scheduledDateTime: DateTime.parse(
        '${json['scheduled_date']} ${json['scheduled_time']}',
      ),
      reminderDateTime: DateTime.parse(json['reminder_scheduled_at']),
      reminderMinutesBefore: json['reminder_minutes_before'] ?? 15,
    );
  }
}

/// NotificationTracker: Quản lý thông báo chính xác + lặp lại
/// - Track notification status (sent/pending/failed)
/// - Handle repeat notifications mỗi 10 phút
/// - Giảm delay bằng native platform channels
class NotificationTracker {
  static final NotificationTracker _instance = NotificationTracker._internal();

  factory NotificationTracker() {
    return _instance;
  }

  NotificationTracker._internal();

  final _supabase = Supabase.instance.client;
  final _notificationService = NotificationService();
  Timer? _checkTimer;
  Timer? _repeatTimer;

  /// Khởi động tracker
  Future<void> initialize() async {
    debugPrint('🔔 NotificationTracker: Initializing...');

    // Bắt đầu check timer (mỗi 30 giây)
    _startCheckTimer();

    // Bắt đầu repeat timer (mỗi 10 phút cho missed)
    _startRepeatTimer();

    debugPrint('✅ NotificationTracker: Initialized');
  }

  /// Dừng tracker
  void dispose() {
    _checkTimer?.cancel();
    _repeatTimer?.cancel();
    debugPrint('🛑 NotificationTracker: Disposed');
  }

  // ============================================================================
  // SCHEDULE: Lên lịch thông báo khi user thêm thuốc
  // ============================================================================

  /// Schedule reminders cho medicine vừa được thêm
  Future<void> scheduleRemindersForMedicine({
    required String userId,
    required String medicineId,
    required String medicineName,
    required String dosageStrength,
    required int quantityPerDose,
    required int reminderMinutesBefore,
    required List<TimeOfDay> scheduleTimes,
  }) async {
    try {
      debugPrint(
        '📅 Scheduling reminders for $medicineName (reminder: ${reminderMinutesBefore}min before)',
      );

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      for (final timeOfDay in scheduleTimes) {
        final scheduledDateTime = DateTime(
          today.year,
          today.month,
          today.day,
          timeOfDay.hour,
          timeOfDay.minute,
        );

        // Nếu thời gian đã qua hôm nay, schedule cho ngày mai
        final finalScheduledDateTime = scheduledDateTime.isBefore(now)
            ? scheduledDateTime.add(const Duration(days: 1))
            : scheduledDateTime;

        final reminderDateTime = finalScheduledDateTime.subtract(
          Duration(minutes: reminderMinutesBefore),
        );

        // Tạo tracking record
        await _createNotificationTracking(
          userId: userId,
          medicineId: medicineId,
          medicineName: medicineName,
          dosageStrength: dosageStrength,
          quantityPerDose: quantityPerDose,
          scheduledDateTime: finalScheduledDateTime,
          reminderDateTime: reminderDateTime,
          reminderMinutesBefore: reminderMinutesBefore,
        );

        debugPrint(
          '✅ Scheduled reminder for $medicineName at ${timeOfDay.hour}:${timeOfDay.minute.toString().padLeft(2, '0')}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error scheduling reminders: $e');
    }
  }

  // ============================================================================
  // SEND: Gửi thông báo chính xác
  // ============================================================================

  Future<void> sendReminder({
    required String userId,
    required String medicineId,
    required String medicineName,
    required String dosageStrength,
    required int quantityPerDose,
    required int reminderMinutesBefore,
  }) async {
    try {
      final notificationId = _generateNotificationId(medicineId, 'reminder');

      debugPrint(
        '📢 Sending reminder notification: $medicineName (ID: $notificationId)',
      );

      // Gửi notification
      await _notificationService.showNotification(
        id: notificationId,
        title: '💊 Nhắc nhở uống thuốc',
        body:
            '$medicineName - $dosageStrength ($quantityPerDose viên)\n'
            'Sẽ uống sau $reminderMinutesBefore phút',
        useAlarm: true,
      );

      // Update database: Mark as sent
      await _updateNotificationStatus(
        medicineId: medicineId,
        status: 'sent',
        sentAt: DateTime.now(),
      );

      debugPrint('✅ Reminder notification sent');
    } catch (e) {
      debugPrint('❌ Error sending reminder: $e');

      // Update database: Mark as failed
      await _updateNotificationStatus(medicineId: medicineId, status: 'failed');
    }
  }

  /// Gửi thông báo lặp lại (khi user chưa uống sau 10 phút)
  Future<void> sendRepeatReminder({
    required String userId,
    required String medicineId,
    required String medicineName,
    required int repeatCount,
  }) async {
    try {
      final notificationId = _generateNotificationId(
        medicineId,
        'repeat_${repeatCount}',
      );

      debugPrint(
        '🔔 Sending repeat reminder #$repeatCount for $medicineName (ID: $notificationId)',
      );

      await _notificationService.showNotification(
        id: notificationId,
        title: '⏰ Nhắc nhở uống thuốc (lần $repeatCount)',
        body:
            'Bạn chưa uống $medicineName!\n'
            'Vui lòng uống ngay hoặc bấm "Bỏ qua"',
        useAlarm: true,
      );

      // Update repeat count và next reminder time
      await _updateRepeatCount(
        medicineId: medicineId,
        repeatCount: repeatCount,
        nextReminderAt: DateTime.now().add(const Duration(minutes: 10)),
      );

      debugPrint('✅ Repeat reminder #$repeatCount sent');
    } catch (e) {
      debugPrint('❌ Error sending repeat reminder: $e');
    }
  }

  // ============================================================================
  // MARK TAKEN: Đánh dấu đã uống - dừng repeat notifications
  // ============================================================================

  Future<void> markAsTaken({
    required String userId,
    required String medicineId,
    required DateTime scheduledDateTime,
  }) async {
    try {
      debugPrint('✅ Marking medicine as taken: $medicineId');

      final dateStr = scheduledDateTime.toString().split(' ')[0];

      // Cập nhật database
      await _supabase
          .from('notification_tracking')
          .update({
            'intake_status': 'taken',
            'taken_at': DateTime.now().toIso8601String(),
          })
          .eq('user_medicine_id', medicineId)
          .eq('scheduled_date', dateStr)
          .order('updated_at', ascending: false)
          .limit(1);

      debugPrint('✅ Medicine marked as taken, repeat reminders cancelled');
    } catch (e) {
      debugPrint('❌ Error marking as taken: $e');
    }
  }

  /// Đánh dấu bỏ qua
  Future<void> markAsSkipped({
    required String medicineId,
    required DateTime scheduledDateTime,
  }) async {
    try {
      debugPrint('⏭️ Marking medicine as skipped: $medicineId');

      final dateStr = scheduledDateTime.toString().split(' ')[0];

      await _supabase
          .from('notification_tracking')
          .update({'intake_status': 'skipped'})
          .eq('user_medicine_id', medicineId)
          .eq('scheduled_date', dateStr)
          .order('updated_at', ascending: false)
          .limit(1);

      debugPrint('✅ Medicine marked as skipped');
    } catch (e) {
      debugPrint('❌ Error marking as skipped: $e');
    }
  }

  // ============================================================================
  // PRIVATE: Helper methods
  // ============================================================================

  void _startCheckTimer() {
    _checkTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      try {
        debugPrint('⏱️ Checking for reminders to send...');

        final userId = _supabase.auth.currentUser?.id;
        if (userId == null) return;

        final now = DateTime.now();
        final dateStr = now.toString().split(' ')[0];

        // Lấy reminders cần gửi
        final reminders = await _supabase
            .from('notification_tracking')
            .select()
            .eq('user_id', userId)
            .eq('scheduled_date', dateStr)
            .eq('notification_status', 'pending')
            .eq('intake_status', 'pending');

        for (final reminder in reminders) {
          final reminderDt = DateTime.parse(reminder['reminder_scheduled_at']);
          final diffSeconds = reminderDt.difference(now).inSeconds.abs();

          // Send nếu trong ±30 giây từ lịch scheduled
          if (diffSeconds < 30) {
            await sendReminder(
              userId: userId,
              medicineId: reminder['user_medicine_id'],
              medicineName: reminder['medicine_name'],
              dosageStrength: reminder['dosage_strength'] ?? 'N/A',
              quantityPerDose: reminder['quantity_per_dose'] ?? 1,
              reminderMinutesBefore: reminder['reminder_minutes_before'] ?? 15,
            );
          }
        }
      } catch (e) {
        debugPrint('❌ Error in check timer: $e');
      }
    });
  }

  void _startRepeatTimer() {
    _repeatTimer = Timer.periodic(const Duration(minutes: 10), (_) async {
      try {
        debugPrint('🔄 Checking for repeat reminders...');

        final userId = _supabase.auth.currentUser?.id;
        if (userId == null) return;

        final dateStr = DateTime.now().toString().split(' ')[0];
        final now = DateTime.now();

        // Lấy notifications cần repeat
        final toRepeat = await _supabase
            .from('notification_tracking')
            .select()
            .eq('user_id', userId)
            .eq('scheduled_date', dateStr)
            .eq('intake_status', 'pending')
            .eq('notification_status', 'sent')
            .not('next_reminder_at', 'is', null)
            .lt('next_reminder_at', now.toIso8601String());

        for (final item in toRepeat) {
          final repeatCount = (item['repeat_count'] as int? ?? 0) + 1;

          // Limit: Chỉ nhắc 5 lần (mỗi 10 phút = 50 phút)
          if (repeatCount <= 5) {
            await sendRepeatReminder(
              userId: userId,
              medicineId: item['user_medicine_id'],
              medicineName: item['medicine_name'],
              repeatCount: repeatCount,
            );
          } else {
            // Đánh dấu missed nếu vượt 5 lần nhắc
            await _supabase
                .from('notification_tracking')
                .update({'intake_status': 'missed'})
                .eq('id', item['id']);

            debugPrint('❌ Medicine ${item['medicine_name']} marked as MISSED');
          }
        }
      } catch (e) {
        debugPrint('❌ Error in repeat timer: $e');
      }
    });
  }

  Future<void> _createNotificationTracking({
    required String userId,
    required String medicineId,
    required String medicineName,
    required String dosageStrength,
    required int quantityPerDose,
    required DateTime scheduledDateTime,
    required DateTime reminderDateTime,
    required int reminderMinutesBefore,
  }) async {
    try {
      final dateStr = scheduledDateTime.toString().split(' ')[0];
      final timeStr =
          '${scheduledDateTime.hour.toString().padLeft(2, '0')}:${scheduledDateTime.minute.toString().padLeft(2, '0')}:00';

      await _supabase.from('notification_tracking').insert({
        'user_id': userId,
        'user_medicine_id': medicineId,
        'medicine_schedule_time_id': 'temp_id',
        'scheduled_date': dateStr,
        'scheduled_time': timeStr,
        'reminder_scheduled_at': reminderDateTime.toIso8601String(),
        'notification_status': 'pending',
        'intake_status': 'pending',
        'repeat_count': 0,
      });
    } catch (e) {
      debugPrint('❌ Error creating notification tracking: $e');
    }
  }

  Future<void> _updateNotificationStatus({
    required String medicineId,
    required String status,
    DateTime? sentAt,
  }) async {
    try {
      final dateStr = DateTime.now().toString().split(' ')[0];

      final update = <String, dynamic>{'notification_status': status};
      if (sentAt != null) {
        update['notification_sent_at'] = sentAt.toIso8601String();
      }

      await _supabase
          .from('notification_tracking')
          .update(update)
          .eq('user_medicine_id', medicineId)
          .eq('scheduled_date', dateStr);
    } catch (e) {
      debugPrint('❌ Error updating notification status: $e');
    }
  }

  Future<void> _updateRepeatCount({
    required String medicineId,
    required int repeatCount,
    required DateTime nextReminderAt,
  }) async {
    try {
      final dateStr = DateTime.now().toString().split(' ')[0];

      await _supabase
          .from('notification_tracking')
          .update({
            'repeat_count': repeatCount,
            'last_reminder_at': DateTime.now().toIso8601String(),
            'next_reminder_at': nextReminderAt.toIso8601String(),
          })
          .eq('user_medicine_id', medicineId)
          .eq('scheduled_date', dateStr)
          .order('updated_at', ascending: false)
          .limit(1);
    } catch (e) {
      debugPrint('❌ Error updating repeat count: $e');
    }
  }

  int _generateNotificationId(String medicineId, String suffix) {
    return (medicineId.hashCode.toString() + suffix).hashCode
        .toUnsigned(32)
        .toInt();
  }
}
