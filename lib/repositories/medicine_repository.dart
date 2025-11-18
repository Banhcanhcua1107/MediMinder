import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_medicine.dart';

class MedicineRepository {
  final SupabaseClient supabase;

  MedicineRepository(this.supabase);

  /// Lấy danh sách thuốc của user (có kèm schedule và times)
  Future<List<UserMedicine>> getUserMedicines(String userId) async {
    try {
      final response = await supabase
          .from('user_medicines')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('start_date', ascending: false);

      final medicines = <UserMedicine>[];
      for (var med in response) {
        final userMed = UserMedicine.fromJson(med);

        // Lấy schedules
        final schedules = await _getSchedulesForMedicine(userMed.id);

        // Lấy schedule times
        final times = await _getScheduleTimesForMedicine(userMed.id);

        userMed.schedules = schedules;
        userMed.scheduleTimes = times;

        medicines.add(userMed);
      }

      return medicines;
    } catch (e) {
      print('Error getting user medicines: $e');
      rethrow;
    }
  }

  /// Lấy danh sách thuốc hôm nay (sorted by time)
  Future<List<UserMedicine>> getTodayMedicines(String userId) async {
    try {
      final today = DateTime.now();
      final todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final response = await supabase
          .from('user_medicines')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .lte('start_date', todayStr)
          .or('end_date.is.null,end_date.gte.$todayStr')
          .order('start_date', ascending: false);

      final medicines = <UserMedicine>[];
      for (var med in response) {
        final userMed = UserMedicine.fromJson(med);

        // Lấy schedules
        final schedules = await _getSchedulesForMedicine(userMed.id);

        // Lấy schedule times và sort
        final times = await _getScheduleTimesForMedicine(userMed.id);
        times.sort(
          (a, b) => (a.timeOfDay.hour * 60 + a.timeOfDay.minute).compareTo(
            b.timeOfDay.hour * 60 + b.timeOfDay.minute,
          ),
        );

        userMed.schedules = schedules;
        userMed.scheduleTimes = times;

        medicines.add(userMed);
      }

      // Sort by next intake time
      medicines.sort((a, b) {
        final aNext = a.getNextIntakeTime();
        final bNext = b.getNextIntakeTime();

        if (aNext == null && bNext == null) return 0;
        if (aNext == null) return 1;
        if (bNext == null) return -1;

        final aMinutes = aNext.hour * 60 + aNext.minute;
        final bMinutes = bNext.hour * 60 + bNext.minute;

        return aMinutes.compareTo(bMinutes);
      });

      return medicines;
    } catch (e) {
      print('Error getting today medicines: $e');
      rethrow;
    }
  }

  /// Tạo medicine mới
  Future<UserMedicine> createMedicine({
    required String userId,
    required String name,
    required String dosageStrength,
    required String dosageForm,
    required int quantityPerDose,
    required DateTime startDate,
    DateTime? endDate,
    String? reasonForUse,
    String? notes,
  }) async {
    try {
      final response = await supabase
          .from('user_medicines')
          .insert({
            'user_id': userId,
            'name': name,
            'dosage_strength': dosageStrength,
            'dosage_form': dosageForm,
            'quantity_per_dose': quantityPerDose,
            'start_date': startDate.toIso8601String().split('T')[0],
            'end_date': endDate != null
                ? endDate.toIso8601String().split('T')[0]
                : null,
            'reason_for_use': reasonForUse,
            'notes': notes,
            'is_active': true,
          })
          .select()
          .single();

      return UserMedicine.fromJson(response);
    } catch (e) {
      print('Error creating medicine: $e');
      rethrow;
    }
  }

  /// Update medicine
  Future<UserMedicine> updateMedicine(
    String medicineId, {
    String? name,
    String? dosageStrength,
    String? dosageForm,
    int? quantityPerDose,
    DateTime? startDate,
    DateTime? endDate,
    String? reasonForUse,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (name != null) data['name'] = name;
      if (dosageStrength != null) data['dosage_strength'] = dosageStrength;
      if (dosageForm != null) data['dosage_form'] = dosageForm;
      if (quantityPerDose != null) data['quantity_per_dose'] = quantityPerDose;
      if (startDate != null)
        data['start_date'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null)
        data['end_date'] = endDate.toIso8601String().split('T')[0];
      if (reasonForUse != null) data['reason_for_use'] = reasonForUse;
      if (notes != null) data['notes'] = notes;

      final response = await supabase
          .from('user_medicines')
          .update(data)
          .eq('id', medicineId)
          .select()
          .single();

      return UserMedicine.fromJson(response);
    } catch (e) {
      print('Error updating medicine: $e');
      rethrow;
    }
  }

  /// Soft delete (set is_active = false)
  Future<void> deleteMedicine(String medicineId) async {
    try {
      await supabase
          .from('user_medicines')
          .update({'is_active': false})
          .eq('id', medicineId);
    } catch (e) {
      print('Error deleting medicine: $e');
      rethrow;
    }
  }

  /// Tạo schedule cho medicine
  Future<MedicineSchedule> createSchedule(
    String userMedicineId, {
    required String frequencyType,
    int? customIntervalDays,
    String? daysOfWeek,
  }) async {
    try {
      final response = await supabase
          .from('medicine_schedules')
          .insert({
            'user_medicine_id': userMedicineId,
            'frequency_type': frequencyType,
            'custom_interval_days': customIntervalDays,
            'days_of_week': daysOfWeek,
          })
          .select()
          .single();

      return MedicineSchedule.fromJson(response);
    } catch (e) {
      print('Error creating schedule: $e');
      rethrow;
    }
  }

  /// Update schedule
  Future<MedicineSchedule> updateSchedule(
    String scheduleId, {
    String? frequencyType,
    int? customIntervalDays,
    String? daysOfWeek,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (frequencyType != null) data['frequency_type'] = frequencyType;
      if (customIntervalDays != null)
        data['custom_interval_days'] = customIntervalDays;
      if (daysOfWeek != null) data['days_of_week'] = daysOfWeek;

      final response = await supabase
          .from('medicine_schedules')
          .update(data)
          .eq('id', scheduleId)
          .select()
          .single();

      return MedicineSchedule.fromJson(response);
    } catch (e) {
      print('Error updating schedule: $e');
      rethrow;
    }
  }

  /// Lấy schedules của một medicine
  Future<List<MedicineSchedule>> _getSchedulesForMedicine(
    String userMedicineId,
  ) async {
    try {
      final response = await supabase
          .from('medicine_schedules')
          .select()
          .eq('user_medicine_id', userMedicineId);

      return (response as List)
          .map((s) => MedicineSchedule.fromJson(s))
          .toList();
    } catch (e) {
      print('Error getting schedules: $e');
      return [];
    }
  }

  /// Lấy schedule times của một medicine
  Future<List<MedicineScheduleTime>> _getScheduleTimesForMedicine(
    String userMedicineId,
  ) async {
    try {
      final schedules = await _getSchedulesForMedicine(userMedicineId);
      if (schedules.isEmpty) return [];

      final times = <MedicineScheduleTime>[];
      for (var schedule in schedules) {
        final response = await supabase
            .from('medicine_schedule_times')
            .select()
            .eq('medicine_schedule_id', schedule.id)
            .order('order_index', ascending: true);

        times.addAll(
          (response as List)
              .map((t) => MedicineScheduleTime.fromJson(t))
              .toList(),
        );
      }

      return times;
    } catch (e) {
      print('Error getting schedule times: $e');
      return [];
    }
  }

  /// Tạo schedule time
  Future<MedicineScheduleTime> createScheduleTime(
    String medicineScheduleId, {
    required TimeOfDay timeOfDay,
    required int orderIndex,
  }) async {
    try {
      final timeStr =
          '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}:00';

      final response = await supabase
          .from('medicine_schedule_times')
          .insert({
            'medicine_schedule_id': medicineScheduleId,
            'time_of_day': timeStr,
            'order_index': orderIndex,
          })
          .select()
          .single();

      return MedicineScheduleTime.fromJson(response);
    } catch (e) {
      print('Error creating schedule time: $e');
      rethrow;
    }
  }

  /// Delete schedule time
  Future<void> deleteScheduleTime(String scheduleTimeId) async {
    try {
      await supabase
          .from('medicine_schedule_times')
          .delete()
          .eq('id', scheduleTimeId);
    } catch (e) {
      print('Error deleting schedule time: $e');
      rethrow;
    }
  }

  /// Lấy medicine intakes (lịch sử uống)
  Future<List<MedicineIntake>> getMedicineIntakes(
    String userId, {
    DateTime? date,
    String? status,
  }) async {
    try {
      var query = supabase
          .from('medicine_intakes')
          .select()
          .eq('user_id', userId);

      if (date != null) {
        final dateStr =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        query = query.eq('scheduled_date', dateStr);
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('scheduled_time', ascending: true);

      return (response as List).map((i) => MedicineIntake.fromJson(i)).toList();
    } catch (e) {
      print('Error getting medicine intakes: $e');
      return [];
    }
  }

  /// Tạo medicine intake
  Future<MedicineIntake> createMedicineIntake({
    required String userId,
    required String userMedicineId,
    required String medicineName,
    required String dosageStrength,
    required int quantityPerDose,
    required DateTime scheduledDate,
    required TimeOfDay scheduledTime,
  }) async {
    try {
      final timeStr =
          '${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}:00';
      final dateStr =
          '${scheduledDate.year}-${scheduledDate.month.toString().padLeft(2, '0')}-${scheduledDate.day.toString().padLeft(2, '0')}';

      final response = await supabase
          .from('medicine_intakes')
          .insert({
            'user_id': userId,
            'user_medicine_id': userMedicineId,
            'medicine_name': medicineName,
            'dosage_strength': dosageStrength,
            'quantity_per_dose': quantityPerDose,
            'scheduled_date': dateStr,
            'scheduled_time': timeStr,
            'status': 'pending',
          })
          .select()
          .single();

      return MedicineIntake.fromJson(response);
    } catch (e) {
      print('Error creating medicine intake: $e');
      rethrow;
    }
  }

  /// Update medicine intake status
  Future<MedicineIntake> updateMedicineIntakeStatus(
    String intakeId, {
    required String status,
    String? notes,
  }) async {
    try {
      final data = {
        'status': status,
        if (status == 'taken') 'taken_at': DateTime.now().toIso8601String(),
        if (notes != null) 'notes': notes,
      };

      final response = await supabase
          .from('medicine_intakes')
          .update(data)
          .eq('id', intakeId)
          .select()
          .single();

      return MedicineIntake.fromJson(response);
    } catch (e) {
      print('Error updating medicine intake: $e');
      rethrow;
    }
  }
}
