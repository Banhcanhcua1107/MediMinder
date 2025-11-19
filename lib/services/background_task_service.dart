// filepath: lib/services/background_task_service.dart
import 'package:workmanager/workmanager.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';
import '../repositories/medicine_repository.dart';
import '../config/constants.dart';

/// Task ID constants
const String taskCheckMedicineReminder = 'check_medicine_reminder';
const String taskBackgroundMedicineSync = 'background_medicine_sync';

/// Top-level callback dispatcher - phải là top-level function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      debugPrint('🔄 Background task started: $taskName');

      switch (taskName) {
        case taskCheckMedicineReminder:
          await _handleMedicineCheckTask();
          break;

        case taskBackgroundMedicineSync:
          await _handleMedicineSyncTask();
          break;

        default:
          debugPrint('❌ Unknown task: $taskName');
          return Future.value(false);
      }

      debugPrint('✅ Background task completed: $taskName');
      return Future.value(true);
    } catch (e) {
      debugPrint('❌ Background task error: $taskName - $e');
      return Future.value(false);
    }
  });
}

/// Service quản lý background tasks
class BackgroundTaskService {
  static final BackgroundTaskService _instance =
      BackgroundTaskService._internal();

  factory BackgroundTaskService() {
    return _instance;
  }

  BackgroundTaskService._internal();

  bool _isInitialized = false;

  /// Khởi tạo background task service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Khởi tạo Workmanager
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

      _isInitialized = true;
      debugPrint('✅ Background Task Service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing Background Task Service: $e');
    }
  }

  /// Lên lịch kiểm tra thuốc hàng giờ (mỗi 15 phút để không bỏ lỡ)
  Future<void> scheduleMedicineCheckTask() async {
    try {
      await Workmanager().registerPeriodicTask(
        taskCheckMedicineReminder,
        taskCheckMedicineReminder,
        frequency: const Duration(
          minutes: 15,
        ), // Kiểm tra mỗi 15 phút để không bỏ lỡ
        initialDelay: const Duration(seconds: 5),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );

      debugPrint('✅ Medicine check task scheduled (every 15 minutes)');
    } catch (e) {
      debugPrint('❌ Error scheduling medicine check task: $e');
    }
  }

  /// Lên lịch sync dữ liệu hàng 6 giờ
  Future<void> scheduleMedicineSyncTask() async {
    try {
      await Workmanager().registerPeriodicTask(
        taskBackgroundMedicineSync,
        taskBackgroundMedicineSync,
        frequency: const Duration(hours: 6),
        initialDelay: const Duration(seconds: 20),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );

      debugPrint('✅ Medicine sync task scheduled (every 6 hours)');
    } catch (e) {
      debugPrint('❌ Error scheduling medicine sync task: $e');
    }
  }

  /// Hủy tất cả tasks
  Future<void> cancelAllTasks() async {
    try {
      await Workmanager().cancelAll();
      debugPrint('✅ All background tasks cancelled');
    } catch (e) {
      debugPrint('❌ Error cancelling tasks: $e');
    }
  }

  /// Hủy task cụ thể
  Future<void> cancelTask(String taskId) async {
    try {
      await Workmanager().cancelByTag(taskId);
      debugPrint('✅ Task cancelled: $taskId');
    } catch (e) {
      debugPrint('❌ Error cancelling task: $e');
    }
  }
}

/// Xử lý task kiểm tra thuốc
Future<void> _handleMedicineCheckTask() async {
  try {
    debugPrint('🔔 Background medicine check task executing...');

    // Khởi tạo Supabase (trong isolate cần reinitialize)
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey, // Thay bằng key thực tế
      );
    } catch (e) {
      debugPrint('⚠️ Supabase already initialized: $e');
    }

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      debugPrint('⚠️ No user logged in, skipping medicine check');
      return;
    }

    // Lấy dữ liệu thuốc hôm nay
    final medicineRepository = MedicineRepository(supabase);
    final medicines = await medicineRepository.getTodayMedicines(user.id);

    if (medicines.isEmpty) {
      debugPrint('ℹ️ No medicines today');
      return;
    }

    // Khởi tạo NotificationService
    final notificationService = NotificationService();
    await notificationService.initialize();

    final now = DateTime.now();
    int notificationsTriggered = 0;

    debugPrint(
      '📋 Checking ${medicines.length} medicines at ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
    );

    // Kiểm tra từng thuốc
    for (var medicine in medicines) {
      if (medicine.scheduleTimes.isEmpty) continue;

      // Kiểm tra từng giờ uống
      for (int i = 0; i < medicine.scheduleTimes.length; i++) {
        final scheduleTime = medicine.scheduleTimes[i];
        final notificationId = NotificationService.generateNotificationId(
          medicine.id,
          i,
        );

        // Tính toán thời gian uống
        final scheduledDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          scheduleTime.timeOfDay.hour,
          scheduleTime.timeOfDay.minute,
        );

        // Hiệu số giây (để chính xác hơn)
        final differenceInSeconds = scheduledDateTime.difference(now).inSeconds;
        final differenceInMinutes = differenceInSeconds ~/ 60;

        // Kiểm tra xem đã gửi thông báo hôm nay chưa
        final todayStr =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

        // Lấy thông tin từ database xem lần cuối gửi khi nào
        final scheduleTimeData = await supabase
            .from('medicine_schedule_times')
            .select('last_notification_sent_date, notification_sent_count')
            .eq('id', scheduleTime.id)
            .single();

        final lastSentDate =
            scheduleTimeData['last_notification_sent_date'] as String?;
        final hasAlreadySentToday = lastSentDate == todayStr;

        // Trigger notification nếu:
        // 1. Giờ uống đã tới (differenceInSeconds <= 0)
        // 2. HOẶC cách giờ uống dưới 3 phút (cho phép lỗi system clock)
        // 3. VÀ chưa gửi hôm nay
        if (!hasAlreadySentToday &&
            differenceInSeconds <= 0 &&
            differenceInSeconds > -120) {
          // Thông báo ngay lập tức vì đã tới giờ
          await notificationService.showImmediateNotification(
            id: notificationId,
            title: '⏰ Đến giờ uống thuốc! 💊',
            body:
                '${medicine.name} (${medicine.dosageStrength}) - ${medicine.quantityPerDose} viên',
            payload: 'medicine:${medicine.id}',
          );

          // Cập nhật database - ghi nhận đã gửi hôm nay
          try {
            await supabase
                .from('medicine_schedule_times')
                .update({
                  'last_notification_sent_date': todayStr,
                  'notification_sent_count':
                      ((scheduleTimeData['notification_sent_count'] ?? 0)
                          as int) +
                      1,
                })
                .eq('id', scheduleTime.id);

            debugPrint(
              '💾 Marked notification as sent for today: ${scheduleTime.id}',
            );
          } catch (e) {
            debugPrint('⚠️ Error updating notification status: $e');
          }

          notificationsTriggered++;
          debugPrint(
            '🔔 Notification triggered for ${medicine.name} at ${scheduleTime.timeOfDay.hour}:${scheduleTime.timeOfDay.minute.toString().padLeft(2, '0')} (diff: $differenceInSeconds sec)',
          );
        } else if (!hasAlreadySentToday &&
            differenceInMinutes > 0 &&
            differenceInMinutes <= 3) {
          // Thông báo sắp tới (trong 3 phút tới) - chỉ nếu chưa gửi hôm nay
          await notificationService.showImmediateNotification(
            id: notificationId,
            title: 'Nhắc uống thuốc',
            body:
                '${medicine.name} (${medicine.dosageStrength}) - ${medicine.quantityPerDose} viên - Trong $differenceInMinutes phút',
            payload: 'medicine:${medicine.id}',
          );

          notificationsTriggered++;
          debugPrint(
            '📲 Advance notification sent for ${medicine.name} (in $differenceInMinutes minutes)',
          );
        } else if (hasAlreadySentToday) {
          debugPrint(
            '⏭️ Skipped notification for ${medicine.name} - already sent today (last: $lastSentDate)',
          );
        }
      }
    }

    debugPrint(
      '✅ Medicine check completed - $notificationsTriggered notifications triggered',
    );
  } catch (e) {
    debugPrint('❌ Error in medicine check task: $e');
  }
}

/// Xử lý task sync dữ liệu
Future<void> _handleMedicineSyncTask() async {
  try {
    debugPrint('🔄 Syncing medicine data from Supabase...');

    // Khởi tạo Supabase
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('⚠️ Supabase already initialized: $e');
    }

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      debugPrint('⚠️ No user logged in, skipping sync');
      return;
    }

    // Lấy dữ liệu thuốc
    final medicineRepository = MedicineRepository(supabase);
    final medicines = await medicineRepository.getUserMedicines(user.id);

    debugPrint(
      '✅ Medicine sync completed - ${medicines.length} medicines synced',
    );

    // TODO: Lưu vào local storage nếu cần
    // Ví dụ: Lưu vào SharedPreferences để offline support
  } catch (e) {
    debugPrint('❌ Error in medicine sync task: $e');
  }
}
