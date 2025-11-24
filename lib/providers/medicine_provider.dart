import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_medicine.dart';
import '../repositories/medicine_repository.dart';
import '../services/notification_service.dart';

class MedicineProvider extends ChangeNotifier {
  final MedicineRepository _medicineRepository;
  final NotificationService _notificationService = NotificationService();
  List<UserMedicine> _medicines = [];
  bool _isLoading = false;
  String? _error;

  MedicineProvider(SupabaseClient supabase)
    : _medicineRepository = MedicineRepository(supabase);

  List<UserMedicine> get medicines => _medicines;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMedicines(String userId) async {
    _isLoading = true;
    _error = null;
    // notifyListeners(); // Avoid notifying here to prevent build errors during init

    try {
      _medicines = await _medicineRepository.getUserMedicines(userId);
      // Ensure each medicine that already exists gets its reminders scheduled
      await _scheduleNotificationsForMedicines(_medicines);
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error fetching medicines: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMedicine(String medicineId) async {
    try {
      debugPrint('🗑️ Provider: Starting delete for medicine $medicineId');

      // 1. Cancel notifications
      final notificationService = NotificationService();
      for (int i = 0; i < 20; i++) {
        await notificationService.cancelNotification(
          NotificationService.generateNotificationId(medicineId, i),
        );
      }
      debugPrint('✅ Notifications cancelled for $medicineId');

      // 2. Delete from DB
      await _medicineRepository.deleteMedicine(medicineId);
      debugPrint('✅ Medicine deleted from database');

      // 3. Update local state
      _medicines.removeWhere((m) => m.id == medicineId);
      debugPrint('✅ Medicine removed from local state');

      notifyListeners();
      debugPrint('✅ Listeners notified');
    } catch (e) {
      debugPrint('❌ Error deleting medicine: $e');
      rethrow;
    }
  }

  Future<void> toggleTaken(
    String userId,
    UserMedicine medicine,
    MedicineScheduleTime scheduleTime,
    bool taken,
  ) async {
    try {
      final client = Supabase.instance.client;

      if (taken) {
        // Create intake record
        final intake = {
          'user_id': userId,
          'user_medicine_id': medicine.id,
          'medicine_name': medicine.name,
          'dosage_strength': medicine.dosageStrength,
          'quantity_per_dose': medicine.quantityPerDose,
          'scheduled_date':
              '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
          'scheduled_time':
              '${scheduleTime.timeOfDay.hour.toString().padLeft(2, '0')}:${scheduleTime.timeOfDay.minute.toString().padLeft(2, '0')}:00',
          'status': 'taken',
          'taken_at': DateTime.now().toIso8601String(),
        };

        await client.from('medicine_intakes').insert(intake);

        // Update local state blindly for responsiveness, or refetch
        // Ideally we should update the specific medicine object in the list
        // For now, let's just refetch to be safe and simple, or update manually if performance is key.
        // Let's update manually to avoid full reload flicker

        // Note: UserMedicine model might need to be updated to include the new intake
        // But since getTodayMedicines fetches intakes, we might need to manually add it to the list
        // This part depends on how UserMedicine parses intakes.
        // Let's just refetch for correctness first.
        await fetchMedicines(userId);
      } else {
        // Remove intake record
        final dateStr =
            '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
        final timeStr =
            '${scheduleTime.timeOfDay.hour.toString().padLeft(2, '0')}:${scheduleTime.timeOfDay.minute.toString().padLeft(2, '0')}:00';

        await client
            .from('medicine_intakes')
            .delete()
            .eq('user_id', userId)
            .eq('user_medicine_id', medicine.id)
            .eq('scheduled_date', dateStr)
            .eq('scheduled_time', timeStr)
            .eq('status', 'taken');

        await fetchMedicines(userId);
      }
    } catch (e) {
      debugPrint('❌ Error toggling taken status: $e');
      rethrow;
    }
  }

  Future<void> _scheduleNotificationsForMedicines(
    List<UserMedicine> medicines,
  ) async {
    if (medicines.isEmpty) return;

    try {
      for (final medicine in medicines) {
        if (!medicine.isActive || medicine.scheduleTimes.isEmpty) continue;

        for (int i = 0; i < medicine.scheduleTimes.length; i++) {
          final timeOfDay = medicine.scheduleTimes[i].timeOfDay;
          final notificationId = NotificationService.generateNotificationId(
            medicine.id,
            i,
          );

          await _notificationService.cancelNotification(notificationId);
          await _notificationService.scheduleDailyNotification(
            id: notificationId,
            title: 'Đến giờ uống thuốc! 💊',
            body:
                '${medicine.name} - ${medicine.dosageStrength}, ${medicine.quantityPerDose} viên',
            time: timeOfDay,
            payload: 'medicine:${medicine.id}',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error scheduling notifications for existing medicines: $e');
    }
  }
}
