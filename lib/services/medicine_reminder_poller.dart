import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/medicine_repository.dart';
import 'notification_service.dart';

/// MedicineReminderPoller: Kiểm tra liên tục (mỗi phút) để show notification ngay tức thì
/// Không dựa vào Android alarm/zonedSchedule mà tự chủ động gọi showNotification()
class MedicineReminderPoller {
  static final MedicineReminderPoller _instance =
      MedicineReminderPoller._internal();

  factory MedicineReminderPoller() => _instance;

  MedicineReminderPoller._internal();

  Timer? _pollingTimer;
  bool _isRunning = false;
  final Set<int> _notificationsSentToday = {};

  /// Bắt đầu polling
  void startPolling({Duration checkInterval = const Duration(minutes: 1)}) {
    if (_isRunning) {
      debugPrint('⚠️ MedicineReminderPoller already running');
      return;
    }

    _isRunning = true;
    debugPrint(
      '🔄 MedicineReminderPoller started (check every ${checkInterval.inSeconds}s)',
    );

    _pollingTimer = Timer.periodic(checkInterval, (_) async {
      await _checkAndShowReminders();
    });

    // Chạy lần đầu ngay lập tức
    _checkAndShowReminders();
  }

  /// Dừng polling
  void stopPolling() {
    _pollingTimer?.cancel();
    _isRunning = false;
    debugPrint('🛑 MedicineReminderPoller stopped');
  }

  /// Kiểm tra xem có thuốc cần nhắc lúc này không và show ngay
  Future<void> _checkAndShowReminders() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) return;

      // Lấy danh sách thuốc hôm nay
      final medicineRepository = MedicineRepository(supabase);
      final medicines = await medicineRepository.getTodayMedicines(user.id);

      if (medicines.isEmpty) return;

      final now = DateTime.now();
      final notificationService = NotificationService();
      await notificationService.initialize();

      int shown = 0;

      for (final medicine in medicines) {
        if (!medicine.isActive) continue;

        for (int i = 0; i < medicine.scheduleTimes.length; i++) {
          final scheduledDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            medicine.scheduleTimes[i].timeOfDay.hour,
            medicine.scheduleTimes[i].timeOfDay.minute,
          );

          final diffSeconds = scheduledDateTime.difference(now).inSeconds.abs();
          final notificationId = NotificationService.generateNotificationId(
            medicine.id,
            i,
          );

          // Show nếu trong ±30 giây và chưa show hôm nay
          if (diffSeconds <= 30 &&
              !_notificationsSentToday.contains(notificationId)) {
            _notificationsSentToday.add(notificationId);

            debugPrint(
              '🔔 [POLLER] Showing immediate reminder for ${medicine.name}',
            );

            await notificationService.showNotification(
              id: notificationId,
              title: 'Đến giờ uống thuốc! 💊',
              body:
                  '${medicine.name} - ${medicine.dosageStrength}, ${medicine.quantityPerDose} viên',
              payload: 'medicine:${medicine.id}',
            );

            shown++;
          }
        }
      }

      if (shown > 0) {
        debugPrint('✅ [POLLER] Showed $shown reminders');
      }

      // Reset mỗi ngày
      await _resetIfNewDay();
    } catch (e) {
      debugPrint('❌ Error in MedicineReminderPoller: $e');
    }
  }

  /// Reset danh sách notifications khi đổi ngày
  Future<void> _resetIfNewDay() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastResetDate = prefs.getString('lastPollerReset');
      final todayStr = DateTime.now().toIso8601String().split('T')[0];

      if (lastResetDate != todayStr) {
        _notificationsSentToday.clear();
        await prefs.setString('lastPollerReset', todayStr);
        debugPrint('🔄 [POLLER] Reset notifications for new day');
      }
    } catch (e) {
      debugPrint('⚠️ Error resetting poller: $e');
    }
  }
}
