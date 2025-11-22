import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/health_metric.dart';

class HealthMetricsRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================================
  // USER HEALTH PROFILE OPERATIONS
  // ============================================================================

  /// Lấy health profile của user hiện tại
  Future<HealthProfile?> getUserHealthProfile(String userId) async {
    try {
      final response = await _supabase
          .from('user_health_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return HealthProfile.fromJson(response);
    } catch (e) {
      print('❌ Error fetching health profile: $e');
      rethrow;
    }
  }

  /// Tạo health profile mới cho user
  Future<HealthProfile> createHealthProfile(
    String userId, {
    double? bmi,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    int? heartRate,
    double? glucoseLevel,
    double? cholesterolLevel,
    String? notes,
  }) async {
    try {
      final response = await _supabase
          .from('user_health_profiles')
          .insert({
            'user_id': userId,
            'bmi': bmi,
            'blood_pressure_systolic': bloodPressureSystolic,
            'blood_pressure_diastolic': bloodPressureDiastolic,
            'heart_rate': heartRate,
            'glucose_level': glucoseLevel,
            'cholesterol_level': cholesterolLevel,
            'notes': notes,
          })
          .select()
          .single();

      return HealthProfile.fromJson(response);
    } catch (e) {
      print('❌ Error creating health profile: $e');
      rethrow;
    }
  }

  /// Cập nhật health profile
  Future<HealthProfile> updateHealthProfile(
    String userId, {
    double? bmi,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    int? heartRate,
    double? glucoseLevel,
    double? cholesterolLevel,
    String? notes,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (bmi != null) updateData['bmi'] = bmi;
      if (bloodPressureSystolic != null) {
        updateData['blood_pressure_systolic'] = bloodPressureSystolic;
      }
      if (bloodPressureDiastolic != null) {
        updateData['blood_pressure_diastolic'] = bloodPressureDiastolic;
      }
      if (heartRate != null) updateData['heart_rate'] = heartRate;
      if (glucoseLevel != null) updateData['glucose_level'] = glucoseLevel;
      if (cholesterolLevel != null) {
        updateData['cholesterol_level'] = cholesterolLevel;
      }
      if (notes != null) updateData['notes'] = notes;

      updateData['last_updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('user_health_profiles')
          .update(updateData)
          .eq('user_id', userId)
          .select()
          .single();

      return HealthProfile.fromJson(response);
    } catch (e) {
      print('❌ Error updating health profile: $e');
      rethrow;
    }
  }

  // ============================================================================
  // HEALTH METRIC HISTORY OPERATIONS
  // ============================================================================

  /// Thêm metric vào lịch sử
  Future<HealthMetric> addHealthMetric({
    required String userId,
    required String metricType,
    required double valueNumeric,
    int? valueSecondary,
    required String unit,
    String source = 'manual',
    String? notes,
    DateTime? measuredAt,
  }) async {
    try {
      final response = await _supabase
          .from('health_metric_history')
          .insert({
            'user_id': userId,
            'metric_type': metricType,
            'value_numeric': valueNumeric,
            'value_secondary': valueSecondary,
            'unit': unit,
            'source': source,
            'notes': notes,
            'measured_at': (measuredAt ?? DateTime.now()).toIso8601String(),
          })
          .select()
          .single();

      return HealthMetric.fromJson(response);
    } catch (e) {
      print('❌ Error adding health metric: $e');
      rethrow;
    }
  }

  /// Lấy lịch sử của một loại metric (e.g., tất cả BMI measurements)
  Future<List<HealthMetric>> getMetricHistory(
    String userId,
    String metricType, {
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 100,
  }) async {
    try {
      final response = await _supabase
          .from('health_metric_history')
          .select()
          .eq('user_id', userId)
          .eq('metric_type', metricType)
          .order('measured_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((e) => HealthMetric.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching metric history: $e');
      rethrow;
    }
  }

  /// Lấy metrics theo ngày
  Future<List<HealthMetric>> getTodayMetrics(String userId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('health_metric_history')
          .select()
          .eq('user_id', userId)
          .gte('measured_at', startOfDay.toIso8601String())
          .lt('measured_at', endOfDay.toIso8601String())
          .order('measured_at', ascending: false);

      return (response as List)
          .map((e) => HealthMetric.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching today metrics: $e');
      rethrow;
    }
  }

  /// Lấy metrics của tuần này
  Future<List<HealthMetric>> getWeeklyMetrics(String userId) async {
    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      final response = await _supabase
          .from('health_metric_history')
          .select()
          .eq('user_id', userId)
          .gte('measured_at', weekAgo.toIso8601String())
          .order('measured_at', ascending: false);

      return (response as List)
          .map((e) => HealthMetric.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching weekly metrics: $e');
      rethrow;
    }
  }

  /// Lấy metrics của tháng này
  Future<List<HealthMetric>> getMonthlyMetrics(String userId) async {
    try {
      final now = DateTime.now();
      final monthAgo = now.subtract(const Duration(days: 30));

      final response = await _supabase
          .from('health_metric_history')
          .select()
          .eq('user_id', userId)
          .gte('measured_at', monthAgo.toIso8601String())
          .order('measured_at', ascending: false);

      return (response as List)
          .map((e) => HealthMetric.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching monthly metrics: $e');
      rethrow;
    }
  }

  /// Lấy metric mới nhất của một loại
  Future<HealthMetric?> getLatestMetric(
    String userId,
    String metricType,
  ) async {
    try {
      final response = await _supabase
          .from('health_metric_history')
          .select()
          .eq('user_id', userId)
          .eq('metric_type', metricType)
          .order('measured_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return HealthMetric.fromJson(response);
    } catch (e) {
      print('❌ Error fetching latest metric: $e');
      rethrow;
    }
  }

  /// Lấy tất cả metrics mới nhất của user (một cho mỗi loại)
  Future<Map<String, HealthMetric>> getLatestMetricsForAllTypes(
    String userId,
  ) async {
    try {
      final metricTypes = [
        'bmi',
        'blood_pressure',
        'heart_rate',
        'glucose',
        'cholesterol',
      ];
      final result = <String, HealthMetric>{};

      for (final type in metricTypes) {
        final metric = await getLatestMetric(userId, type);
        if (metric != null) {
          result[type] = metric;
        }
      }

      return result;
    } catch (e) {
      print('❌ Error fetching latest metrics: $e');
      rethrow;
    }
  }

  /// Lấy aggregate data (average, min, max) cho một metric trong khoảng thời gian
  Future<Map<String, dynamic>> getMetricAggregate(
    String userId,
    String metricType, {
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final response = await _supabase
          .from('health_metric_history')
          .select()
          .eq('user_id', userId)
          .eq('metric_type', metricType)
          .gte('measured_at', fromDate.toIso8601String())
          .lte('measured_at', toDate.toIso8601String())
          .order('measured_at', ascending: false);

      if ((response as List).isEmpty) {
        return {'average': null, 'min': null, 'max': null, 'count': 0};
      }

      final values = (response as List)
          .map((e) => (e as Map<String, dynamic>)['value_numeric'] as double)
          .toList();

      return {
        'average': values.reduce((a, b) => a + b) / values.length,
        'min': values.reduce((a, b) => a < b ? a : b),
        'max': values.reduce((a, b) => a > b ? a : b),
        'count': values.length,
      };
    } catch (e) {
      print('❌ Error fetching metric aggregate: $e');
      rethrow;
    }
  }

  /// Delete một metric từ lịch sử
  Future<void> deleteHealthMetric(String metricId) async {
    try {
      await _supabase.from('health_metric_history').delete().eq('id', metricId);
    } catch (e) {
      print('❌ Error deleting health metric: $e');
      rethrow;
    }
  }

  /// Update một metric trong lịch sử
  Future<HealthMetric> updateHealthMetric(
    String metricId, {
    double? valueNumeric,
    int? valueSecondary,
    String? notes,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (valueNumeric != null) updateData['value_numeric'] = valueNumeric;
      if (valueSecondary != null)
        updateData['value_secondary'] = valueSecondary;
      if (notes != null) updateData['notes'] = notes;

      final response = await _supabase
          .from('health_metric_history')
          .update(updateData)
          .eq('id', metricId)
          .select()
          .single();

      return HealthMetric.fromJson(response);
    } catch (e) {
      print('❌ Error updating health metric: $e');
      rethrow;
    }
  }
}
