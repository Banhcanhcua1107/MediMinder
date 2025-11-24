// filepath: lib/models/medicine_intake.dart
// Medicine intake tracking model

class MedicineIntake {
  final String id;
  final String userId;
  final String userMedicineId;
  final String medicineName;
  final String dosageStrength;
  final int quantityPerDose;
  final String scheduledDate;
  final String scheduledTime;
  final String? takenAt;
  final String status; // 'pending', 'taken', 'skipped'
  final DateTime createdAt;
  final DateTime? updatedAt;

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
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert to JSON for database
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_medicine_id': userMedicineId,
      'medicine_name': medicineName,
      'dosage_strength': dosageStrength,
      'quantity_per_dose': quantityPerDose,
      'scheduled_date': scheduledDate,
      'scheduled_time': scheduledTime,
      'taken_at': takenAt,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory MedicineIntake.fromJson(Map<String, dynamic> json) {
    return MedicineIntake(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      userMedicineId: json['user_medicine_id'] as String? ?? '',
      medicineName: json['medicine_name'] as String? ?? '',
      dosageStrength: json['dosage_strength'] as String? ?? '',
      quantityPerDose: json['quantity_per_dose'] as int? ?? 1,
      scheduledDate: json['scheduled_date'] as String? ?? '',
      scheduledTime: json['scheduled_time'] as String? ?? '',
      takenAt: json['taken_at'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Copy with modifications
  MedicineIntake copyWith({
    String? id,
    String? userId,
    String? userMedicineId,
    String? medicineName,
    String? dosageStrength,
    int? quantityPerDose,
    String? scheduledDate,
    String? scheduledTime,
    String? takenAt,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicineIntake(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userMedicineId: userMedicineId ?? this.userMedicineId,
      medicineName: medicineName ?? this.medicineName,
      dosageStrength: dosageStrength ?? this.dosageStrength,
      quantityPerDose: quantityPerDose ?? this.quantityPerDose,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenAt: takenAt ?? this.takenAt,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'MedicineIntake('
        'id: $id, '
        'medicineName: $medicineName, '
        'status: $status, '
        'scheduledTime: $scheduledTime'
        ')';
  }
}
