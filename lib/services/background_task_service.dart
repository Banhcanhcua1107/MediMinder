// filepath: lib/services/background_task_service.dart
import 'package:workmanager/workmanager.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';
import '../repositories/medicine_repository.dart';
import '../config/constants.dart';
import '../models/user_medicine.dart';

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

  /// Lên lịch kiểm tra thuốc hàng giờ (mỗi 4 giờ để refill schedule)
  Future<void> scheduleMedicineCheckTask() async {
    try {
      await Workmanager().registerPeriodicTask(
        taskCheckMedicineReminder,
        taskCheckMedicineReminder,
        frequency: const Duration(minutes: 15),
        initialDelay: const Duration(seconds: 10),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );

      debugPrint('✅ Medicine scheduling task scheduled (every 4 hours)');
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

/// Xử lý task kiểm tra thuốc (Updated: Scheduling Mode)
Future<void> _handleMedicineCheckTask() async {
  try {
    debugPrint('🔔 Background medicine scheduling task executing...');

    // Khởi tạo Supabase (trong isolate cần khởi tạo lại)
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
      debugPrint('⚠️ No user logged in, skipping scheduling');
      return;
    }

    // Lấy dữ liệu thuốc hôm nay
    final medicineRepository = MedicineRepository(supabase);

    // 1. Thử lấy từ cache trước
    List<UserMedicine> medicines = await medicineRepository.getLocalMedicines();

    if (medicines.isNotEmpty) {
      debugPrint('⚡ Loaded ${medicines.length} medicines from local cache');
    } else {
      // 2. Nếu cache rỗng, mới gọi API
      debugPrint('⚠️ Local cache empty, fetching from Supabase...');
      medicines = await medicineRepository.getTodayMedicines(user.id);
    }

    if (medicines.isEmpty) {
      debugPrint('ℹ️ No medicines to schedule');
      return;
    }

    // Khởi tạo NotificationService
    final notificationService = NotificationService();
    await notificationService.initialize();

    final now = DateTime.now();

    int medicinesScheduled = 0;

    // Schedule cho từng thuốc
    for (var medicine in medicines) {
      if (!medicine.isActive) continue;

      // Schedule lặp lại hàng ngày cho từng giờ uống
      for (int i = 0; i < medicine.scheduleTimes.length; i++) {
        final scheduleTime = medicine.scheduleTimes[i];
        final timeOfDay = scheduleTime.timeOfDay;

        await notificationService.scheduleDailyNotification(
          id: NotificationService.generateNotificationId(medicine.id, i),
          title: 'Đến giờ uống thuốc! 💊',
          body:
              '${medicine.name} - ${medicine.dosageStrength}, ${medicine.quantityPerDose} viên',
          time: timeOfDay,
          payload: 'medicine:${medicine.id}',
        );
      }
      medicinesScheduled++;
    }

    debugPrint(
      '✅ Medicine scheduling completed - $medicinesScheduled medicines scheduled for next 7 days',
    );

    await _showImmediateRemindersIfNeeded(
      notificationService,
      medicines,
      now: now,
    );
  } catch (e) {
    debugPrint('❌ Error in medicine check task: $e');
  }
}

Future<void> _showImmediateRemindersIfNeeded(
  NotificationService notificationService,
  List<UserMedicine> medicines, {
  required DateTime now,
}) async {
  const immediateWindowSeconds = 60;
  final triggeredIds = <int>{};

  for (final medicine in medicines) {
    if (!medicine.isActive) continue;
    if (!medicine.isScheduledForDate(now)) continue;

    for (int i = 0; i < medicine.scheduleTimes.length; i++) {
      final scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        medicine.scheduleTimes[i].timeOfDay.hour,
        medicine.scheduleTimes[i].timeOfDay.minute,
      );

      final diffSeconds = scheduledDateTime.difference(now).inSeconds;
      if (diffSeconds.abs() > immediateWindowSeconds) continue;

      final notificationId = NotificationService.generateNotificationId(
        medicine.id,
        i,
      );
      if (triggeredIds.contains(notificationId)) continue;
      triggeredIds.add(notificationId);

      debugPrint(
        '⏰ Immediate reminder triggered for ${medicine.name} at ${scheduledDateTime.toIso8601String()}',
      );

      await notificationService.showNotification(
        id: notificationId,
        title: 'Đến giờ uống thuốc! 💊',
        body:
            '${medicine.name} - ${medicine.dosageStrength}, ${medicine.quantityPerDose} viên',
        payload: 'medicine:${medicine.id}',
        useAlarm: true,
      );
    }
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

    // Lấy dữ liệu thuốc và lưu vào cache (trong getTodayMedicines đã có save)
    final medicineRepository = MedicineRepository(supabase);
    final medicines = await medicineRepository.getTodayMedicines(user.id);

    debugPrint(
      '✅ Medicine sync completed - ${medicines.length} medicines synced',
    );
  } catch (e) {
    debugPrint('❌ Error in medicine sync task: $e');
  }
}
