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

  /// Lên lịch kiểm tra thuốc hàng giờ
  Future<void> scheduleMedicineCheckTask() async {
    try {
      await Workmanager().registerPeriodicTask(
        taskCheckMedicineReminder,
        taskCheckMedicineReminder,
        frequency: const Duration(minutes: 30), // Kiểm tra mỗi 30 phút
        initialDelay: const Duration(seconds: 10),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );

      debugPrint('✅ Medicine check task scheduled (every 30 minutes)');
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
    int notificationsScheduled = 0;

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

        // Nếu cách giờ uống dưới 5 phút, gửi thông báo
        final differenceInMinutes = scheduledDateTime.difference(now).inMinutes;

        if (differenceInMinutes > 0 && differenceInMinutes <= 5) {
          // Thông báo sắp tới
          await notificationService.showNotification(
            id: notificationId,
            title: 'Nhắc uống thuốc',
            body:
                '${medicine.name} (${medicine.dosageStrength}) - ${medicine.quantityPerDose} viên',
            payload: 'medicine:${medicine.id}',
          );

          notificationsScheduled++;
          debugPrint(
            '📲 Notification sent for ${medicine.name} at ${scheduleTime.timeOfDay.hour}:${scheduleTime.timeOfDay.minute.toString().padLeft(2, '0')}',
          );
        }
      }
    }

    debugPrint(
      '✅ Medicine check completed - $notificationsScheduled notifications scheduled',
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
