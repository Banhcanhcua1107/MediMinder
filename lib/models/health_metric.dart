// Model cho Health Metric
class HealthMetric {
  final String id;
  final String userId;
  final String
  metricType; // 'bmi', 'blood_pressure', 'heart_rate', 'glucose', 'cholesterol'
  final double? valueNumeric;
  final int? valueSecondary; // Dùng cho blood_pressure diastolic
  final String unit;
  final String source; // 'manual', 'mi_fitness', 'redmi_watch'
  final String? notes;
  final DateTime measuredAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  HealthMetric({
    required this.id,
    required this.userId,
    required this.metricType,
    this.valueNumeric,
    this.valueSecondary,
    required this.unit,
    required this.source,
    this.notes,
    required this.measuredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor từ JSON (từ Supabase)
  factory HealthMetric.fromJson(Map<String, dynamic> json) {
    return HealthMetric(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      metricType: json['metric_type'] as String,
      valueNumeric: json['value_numeric'] != null
          ? double.parse(json['value_numeric'].toString())
          : null,
      valueSecondary: json['value_secondary'] as int?,
      unit: json['unit'] as String? ?? '',
      source: json['source'] as String? ?? 'manual',
      notes: json['notes'] as String?,
      measuredAt: DateTime.parse(json['measured_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Convert to JSON (để gửi lên Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'metric_type': metricType,
      'value_numeric': valueNumeric,
      'value_secondary': valueSecondary,
      'unit': unit,
      'source': source,
      'notes': notes,
      'measured_at': measuredAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // CopyWith method
  HealthMetric copyWith({
    String? id,
    String? userId,
    String? metricType,
    double? valueNumeric,
    int? valueSecondary,
    String? unit,
    String? source,
    String? notes,
    DateTime? measuredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthMetric(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      metricType: metricType ?? this.metricType,
      valueNumeric: valueNumeric ?? this.valueNumeric,
      valueSecondary: valueSecondary ?? this.valueSecondary,
      unit: unit ?? this.unit,
      source: source ?? this.source,
      notes: notes ?? this.notes,
      measuredAt: measuredAt ?? this.measuredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Model cho Health Profile (current state)
class HealthProfile {
  final String id;
  final String userId;
  final double? bmi;
  final int? bloodPressureSystolic;
  final int? bloodPressureDiastolic;
  final int? heartRate;
  final double? glucoseLevel;
  final double? cholesterolLevel;
  final String? notes;
  final DateTime lastUpdatedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  HealthProfile({
    required this.id,
    required this.userId,
    this.bmi,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.heartRate,
    this.glucoseLevel,
    this.cholesterolLevel,
    this.notes,
    required this.lastUpdatedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HealthProfile.fromJson(Map<String, dynamic> json) {
    return HealthProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      bmi: json['bmi'] != null ? double.parse(json['bmi'].toString()) : null,
      bloodPressureSystolic: json['blood_pressure_systolic'] as int?,
      bloodPressureDiastolic: json['blood_pressure_diastolic'] as int?,
      heartRate: json['heart_rate'] as int?,
      glucoseLevel: json['glucose_level'] != null
          ? double.parse(json['glucose_level'].toString())
          : null,
      cholesterolLevel: json['cholesterol_level'] != null
          ? double.parse(json['cholesterol_level'].toString())
          : null,
      notes: json['notes'] as String?,
      lastUpdatedAt: DateTime.parse(json['last_updated_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'bmi': bmi,
      'blood_pressure_systolic': bloodPressureSystolic,
      'blood_pressure_diastolic': bloodPressureDiastolic,
      'heart_rate': heartRate,
      'glucose_level': glucoseLevel,
      'cholesterol_level': cholesterolLevel,
      'notes': notes,
      'last_updated_at': lastUpdatedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Check if profile has any data
  bool get hasData =>
      bmi != null ||
      bloodPressureSystolic != null ||
      heartRate != null ||
      glucoseLevel != null ||
      cholesterolLevel != null;

  HealthProfile copyWith({
    String? id,
    String? userId,
    double? bmi,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    int? heartRate,
    double? glucoseLevel,
    double? cholesterolLevel,
    String? notes,
    DateTime? lastUpdatedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bmi: bmi ?? this.bmi,
      bloodPressureSystolic:
          bloodPressureSystolic ?? this.bloodPressureSystolic,
      bloodPressureDiastolic:
          bloodPressureDiastolic ?? this.bloodPressureDiastolic,
      heartRate: heartRate ?? this.heartRate,
      glucoseLevel: glucoseLevel ?? this.glucoseLevel,
      cholesterolLevel: cholesterolLevel ?? this.cholesterolLevel,
      notes: notes ?? this.notes,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
