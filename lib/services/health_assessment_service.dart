/// Health assessment service for analyzing health metrics
class HealthAssessmentService {
  /// BMI Categories
  static const double bmiUnderweight = 18.5;
  static const double bmiNormal = 25.0;
  static const double bmiOverweight = 30.0;

  /// Blood Pressure thresholds (systolic/diastolic)
  static const int bpNormalSystolic = 120;
  static const int bpElevatedSystolic = 130;
  static const int bpStage1Systolic = 140;
  static const int bpStage2Systolic = 180;

  static const int bpNormalDiastolic = 80;
  static const int bpElevatedDiastolic = 80;
  static const int bpStage1Diastolic = 90;
  static const int bpStage2Diastolic = 120;

  /// Heart Rate thresholds (bpm)
  static const int hrMinNormal = 60;
  static const int hrMaxNormal = 100;
  static const int hrMinWarning = 40;
  static const int hrMaxWarning = 120;

  /// Glucose thresholds (mg/dL) - Fasting
  static const double glucoseLowNormal = 70;
  static const double glucoseNormal = 100;
  static const double glucosePrediabetic = 126;
  static const double glucoseDiabetic = 200;

  /// Cholesterol thresholds (mg/dL)
  static const double cholesterolDesirable = 200;
  static const double cholesterolBorderline = 240;

  /// BMI Assessment
  static BMIAssessment assessBMI(double bmi) {
    if (bmi < bmiUnderweight) {
      return BMIAssessment(
        category: 'bmiUnderweight',
        status: 'caution',
        value: bmi,
      );
    } else if (bmi < bmiNormal) {
      return BMIAssessment(category: 'bmiNormal', status: 'good', value: bmi);
    } else if (bmi < bmiOverweight) {
      return BMIAssessment(
        category: 'bmiOverweight',
        status: 'caution',
        value: bmi,
      );
    } else {
      return BMIAssessment(category: 'bmiObese', status: 'warning', value: bmi);
    }
  }

  /// Blood Pressure Assessment
  static BloodPressureAssessment assessBloodPressure(
    int systolic,
    int diastolic,
  ) {
    String status;
    String category;

    // Check by systolic first, then diastolic
    if (systolic >= bpStage2Systolic || diastolic >= bpStage2Diastolic) {
      status = 'warning';
      category = 'bpStage2';
    } else if (systolic >= bpStage1Systolic || diastolic >= bpStage1Diastolic) {
      status = 'caution';
      category = 'bpStage1';
    } else if (systolic >= bpElevatedSystolic ||
        diastolic >= bpElevatedDiastolic) {
      status = 'caution';
      category = 'bpElevated';
    } else {
      status = 'good';
      category = 'bpNormal';
    }

    return BloodPressureAssessment(
      category: category,
      status: status,
      systolic: systolic,
      diastolic: diastolic,
    );
  }

  /// Heart Rate Assessment
  static HeartRateAssessment assessHeartRate(int heartRate) {
    String status;
    String category;

    if (heartRate < hrMinWarning || heartRate > hrMaxWarning) {
      status = 'warning';
      if (heartRate < hrMinWarning) {
        category = 'hrSlow';
      } else {
        category = 'hrFast';
      }
    } else if (heartRate < hrMinNormal || heartRate > hrMaxNormal) {
      status = 'caution';
      if (heartRate < hrMinNormal) {
        category = 'hrSlow';
      } else {
        category = 'hrFast';
      }
    } else {
      status = 'good';
      category = 'hrNormal';
    }

    return HeartRateAssessment(
      category: category,
      status: status,
      value: heartRate,
    );
  }

  /// Glucose Assessment (Fasting blood sugar)
  static GlucoseAssessment assessGlucose(double glucose) {
    String status;
    String category;

    if (glucose < glucoseLowNormal) {
      status = 'warning';
      category = 'glucoseLow';
    } else if (glucose < glucoseNormal) {
      status = 'good';
      category = 'glucoseNormal';
    } else if (glucose < glucosePrediabetic) {
      status = 'caution';
      category = 'glucosePrediabetic';
    } else if (glucose < glucoseDiabetic) {
      status = 'warning';
      category = 'glucoseDiabetic';
    } else {
      status = 'warning';
      category = 'glucoseHigh';
    }

    return GlucoseAssessment(
      category: category,
      status: status,
      value: glucose,
    );
  }

  /// Cholesterol Assessment
  static CholesterolAssessment assessCholesterol(double cholesterol) {
    String status;
    String category;

    if (cholesterol < cholesterolDesirable) {
      status = 'good';
      category = 'cholesterolDesirable';
    } else if (cholesterol < cholesterolBorderline) {
      status = 'caution';
      category = 'cholesterolBorderline';
    } else {
      status = 'warning';
      category = 'cholesterolHigh';
    }

    return CholesterolAssessment(
      category: category,
      status: status,
      value: cholesterol,
    );
  }

  /// Get overall health status
  static String getOverallStatus(
    BMIAssessment? bmi,
    BloodPressureAssessment? bp,
    HeartRateAssessment? hr,
  ) {
    final statuses = <String>[];
    if (bmi != null) statuses.add(bmi.status);
    if (bp != null) statuses.add(bp.status);
    if (hr != null) statuses.add(hr.status);

    if (statuses.contains('warning')) return 'warning';
    if (statuses.contains('caution')) return 'caution';
    if (statuses.contains('good')) return 'good';
    return 'normal';
  }

  /// Get color based on status
  static String getStatusColor(String status) {
    switch (status) {
      case 'excellent':
      case 'good':
        return '#10B981'; // Green
      case 'normal':
        return '#3B82F6'; // Blue
      case 'caution':
        return '#F59E0B'; // Amber
      case 'warning':
        return '#EF4444'; // Red
      default:
        return '#6B7280'; // Gray
    }
  }

  /// Get status icon based on status
  static String getStatusIcon(String status) {
    switch (status) {
      case 'excellent':
      case 'good':
        return '✓'; // Check
      case 'normal':
        return '•'; // Dot
      case 'caution':
        return '⚠'; // Warning
      case 'warning':
        return '✕'; // X
      default:
        return '?';
    }
  }
}

/// BMI Assessment Result
class BMIAssessment {
  final String category;
  final String status;
  final double value;

  BMIAssessment({
    required this.category,
    required this.status,
    required this.value,
  });
}

/// Blood Pressure Assessment Result
class BloodPressureAssessment {
  final String category;
  final String status;
  final int systolic;
  final int diastolic;

  BloodPressureAssessment({
    required this.category,
    required this.status,
    required this.systolic,
    required this.diastolic,
  });
}

/// Heart Rate Assessment Result
class HeartRateAssessment {
  final String category;
  final String status;
  final int value;

  HeartRateAssessment({
    required this.category,
    required this.status,
    required this.value,
  });
}

/// Glucose Assessment Result
class GlucoseAssessment {
  final String category;
  final String status;
  final double value;

  GlucoseAssessment({
    required this.category,
    required this.status,
    required this.value,
  });
}

/// Cholesterol Assessment Result
class CholesterolAssessment {
  final String category;
  final String status;
  final double value;

  CholesterolAssessment({
    required this.category,
    required this.status,
    required this.value,
  });
}
