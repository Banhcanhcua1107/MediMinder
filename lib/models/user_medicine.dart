import 'package:flutter/material.dart';

/// Model đại diện cho một loại thuốc của user
class UserMedicine {
  final String id;
  final String userId;
  final String name;
  final String dosageStrength; // e.g., '500mg'
  final String dosageForm; // 'tablet', 'capsule', 'liquid', 'injection'
  final int quantityPerDose; // Số viên/lần
  final DateTime startDate;
  final DateTime? endDate;
  final String? reasonForUse;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Để lưu schedule và times khi query
  List<MedicineSchedule> schedules;
  List<MedicineScheduleTime> scheduleTimes;
  List<MedicineIntake> intakes; // Lịch sử uống

  UserMedicine({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosageStrength,
    required this.dosageForm,
    required this.quantityPerDose,
    required this.startDate,
    this.endDate,
    this.reasonForUse,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.schedules = const [],
    this.scheduleTimes = const [],
    this.intakes = const [],
  });

  /// Từ JSON (từ Supabase)
  factory UserMedicine.fromJson(Map<String, dynamic> json) {
    return UserMedicine(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      dosageStrength: json['dosage_strength'] ?? '',
      dosageForm: json['dosage_form'] ?? '',
      quantityPerDose: json['quantity_per_dose'] ?? 1,
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      reasonForUse: json['reason_for_use'],
      notes: json['notes'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// Sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'dosage_strength': dosageStrength,
      'dosage_form': dosageForm,
      'quantity_per_dose': quantityPerDose,
      'start_date': startDate.toIso8601String().split('T')[0], // YYYY-MM-DD
      'end_date': endDate != null
          ? endDate!.toIso8601String().split('T')[0]
          : null,
      'reason_for_use': reasonForUse,
      'notes': notes,
      'is_active': isActive,
    };
  }

  /// Copy with để update một số fields
  UserMedicine copyWith({
    String? id,
    String? userId,
    String? name,
    String? dosageStrength,
    String? dosageForm,
    int? quantityPerDose,
    DateTime? startDate,
    DateTime? endDate,
    String? reasonForUse,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<MedicineSchedule>? schedules,
    List<MedicineScheduleTime>? scheduleTimes,
    List<MedicineIntake>? intakes,
  }) {
    return UserMedicine(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dosageStrength: dosageStrength ?? this.dosageStrength,
      dosageForm: dosageForm ?? this.dosageForm,
      quantityPerDose: quantityPerDose ?? this.quantityPerDose,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reasonForUse: reasonForUse ?? this.reasonForUse,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      schedules: schedules ?? this.schedules,
      scheduleTimes: scheduleTimes ?? this.scheduleTimes,
      intakes: intakes ?? this.intakes,
    );
  }

  /// Kiểm tra xem thuốc còn hợp lệ không (trong khoảng ngày)
  bool isValidToday() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final startDateOnly = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    if (todayDate.isBefore(startDateOnly)) return false;
    if (endDate != null) {
      final endDateOnly = DateTime(endDate!.year, endDate!.month, endDate!.day);
      if (todayDate.isAfter(endDateOnly)) return false;
    }
    return isActive;
  }

  /// Lấy giờ uống tiếp theo (gần nhất)
  TimeOfDay? getNextIntakeTime() {
    if (scheduleTimes.isEmpty) return null;

    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;

    // Tìm giờ sắp tới nhất
    MedicineScheduleTime? nextTime;
    int? nextMinutes;

    for (var time in scheduleTimes) {
      final minutes = time.timeOfDay.hour * 60 + time.timeOfDay.minute;
      if (minutes >= nowMinutes) {
        if (nextMinutes == null || minutes < nextMinutes) {
          nextTime = time;
          nextMinutes = minutes;
        }
      }
    }

    return nextTime?.timeOfDay;
  }

  /// Tính số phút còn lại đến giờ uống tiếp theo
  int? getMinutesUntilNextIntake() {
    final nextTime = getNextIntakeTime();
    if (nextTime == null) return null;

    final now = TimeOfDay.now();
    final nextMinutes = nextTime.hour * 60 + nextTime.minute;
    final nowMinutes = now.hour * 60 + now.minute;

    final diff = nextMinutes - nowMinutes;
    return diff > 0 ? diff : null;
  }

  /// Format thời gian đến giờ uống tiếp theo
  String getTimeUntilNextIntakeText() {
    final minutes = getMinutesUntilNextIntake();
    if (minutes == null) return 'Sắp tới';

    if (minutes < 60) {
      return 'Trong $minutes phút';
    } else {
      final hours = (minutes / 60).toStringAsFixed(0);
      return 'Trong $hours giờ';
    }
  }
}

/// Model đại diện cho tần suất uống thuốc
class MedicineSchedule {
  final String id;
  final String userMedicineId;
  final String frequencyType; // 'daily', 'alternate_days', 'custom'
  final int?
  customIntervalDays; // Cho 'custom': cách X ngày (null nếu không phải custom)
  final String?
  daysOfWeek; // Cho 'custom': bitmap thứ trong tuần (e.g., '1111100')
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicineSchedule({
    required this.id,
    required this.userMedicineId,
    required this.frequencyType,
    this.customIntervalDays,
    this.daysOfWeek,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicineSchedule.fromJson(Map<String, dynamic> json) {
    return MedicineSchedule(
      id: json['id'] ?? '',
      userMedicineId: json['user_medicine_id'] ?? '',
      frequencyType: json['frequency_type'] ?? 'daily',
      customIntervalDays: json['custom_interval_days'],
      daysOfWeek: json['days_of_week'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_medicine_id': userMedicineId,
      'frequency_type': frequencyType,
      'custom_interval_days': customIntervalDays,
      'days_of_week': daysOfWeek,
    };
  }

  /// Lấy text mô tả tần suất
  String getFrequencyText() {
    switch (frequencyType) {
      case 'daily':
        return 'Hàng ngày';
      case 'alternate_days':
        return 'Cách ngày';
      case 'custom':
        if (customIntervalDays != null) {
          return 'Cách $customIntervalDays ngày';
        } else if (daysOfWeek != null) {
          return _getDaysOfWeekText(daysOfWeek!);
        }
        return 'Tuỳ chỉnh';
      default:
        return 'Không xác định';
    }
  }

  static String _getDaysOfWeekText(String daysOfWeek) {
    final daysNames = [
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
      'CN',
    ];
    final selectedDays = <String>[];

    for (int i = 0; i < daysOfWeek.length; i++) {
      if (daysOfWeek[i] == '1') {
        selectedDays.add(daysNames[i]);
      }
    }

    if (selectedDays.isEmpty) return 'Không có ngày';
    if (selectedDays.length == 7) return 'Hàng ngày';

    return selectedDays.join(', ');
  }
}

/// Model đại diện cho giờ uống trong ngày
class MedicineScheduleTime {
  final String id;
  final String medicineScheduleId;
  final TimeOfDay timeOfDay;
  final int orderIndex;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicineScheduleTime({
    required this.id,
    required this.medicineScheduleId,
    required this.timeOfDay,
    required this.orderIndex,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicineScheduleTime.fromJson(Map<String, dynamic> json) {
    // Parse TIME từ string 'HH:MM:SS'
    final timeStr = json['time_of_day'] as String;
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    return MedicineScheduleTime(
      id: json['id'] ?? '',
      medicineScheduleId: json['medicine_schedule_id'] ?? '',
      timeOfDay: TimeOfDay(hour: hour, minute: minute),
      orderIndex: json['order_index'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final timeStr =
        '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}:00';
    return {
      'id': id,
      'medicine_schedule_id': medicineScheduleId,
      'time_of_day': timeStr,
      'order_index': orderIndex,
    };
  }

  /// Format giờ theo 24h hoặc 12h (VN dùng 24h)
  String getTimeText() {
    return '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
  }
}

/// Model cho medicine intake (lịch sử uống)
class MedicineIntake {
  final String id;
  final String userId;
  final String userMedicineId;
  final String medicineName;
  final String dosageStrength;
  final int quantityPerDose;
  final DateTime scheduledDate;
  final TimeOfDay scheduledTime;
  final DateTime? takenAt;
  final String status; // 'pending', 'taken', 'skipped', 'missed'
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicineIntake({
    required this.id,
    required this.userId,
    required this.userMedicineId,
    required this.medicineName,
    required this.dosageStrength,
    required this.quantityPerDose,
    required this.scheduledDate,
    required this.scheduledTime,
    this.takenAt,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicineIntake.fromJson(Map<String, dynamic> json) {
    final timeStr = json['scheduled_time'] as String;
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    return MedicineIntake(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userMedicineId: json['user_medicine_id'] ?? '',
      medicineName: json['medicine_name'] ?? '',
      dosageStrength: json['dosage_strength'] ?? '',
      quantityPerDose: json['quantity_per_dose'] ?? 1,
      scheduledDate: DateTime.parse(json['scheduled_date']),
      scheduledTime: TimeOfDay(hour: hour, minute: minute),
      takenAt: json['taken_at'] != null
          ? DateTime.parse(json['taken_at'])
          : null,
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final timeStr =
        '${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}:00';
    return {
      'id': id,
      'user_id': userId,
      'user_medicine_id': userMedicineId,
      'medicine_name': medicineName,
      'dosage_strength': dosageStrength,
      'quantity_per_dose': quantityPerDose,
      'scheduled_date': scheduledDate.toIso8601String().split('T')[0],
      'scheduled_time': timeStr,
      'taken_at': takenAt?.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }

  /// Lấy text trạng thái
  String getStatusText() {
    switch (status) {
      case 'pending':
        return 'Chưa uống';
      case 'taken':
        return 'Đã uống';
      case 'skipped':
        return 'Bỏ qua';
      case 'missed':
        return 'Quên uống';
      default:
        return 'Không xác định';
    }
  }

  /// Lấy icon color dựa vào status
  Color getStatusColor() {
    switch (status) {
      case 'pending':
        return const Color(0xFF64748B); // Gray
      case 'taken':
        return const Color(0xFF22C55E); // Green
      case 'skipped':
        return const Color(0xFF3B82F6); // Blue
      case 'missed':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF64748B);
    }
  }
}
