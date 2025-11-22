import 'package:health/health.dart';
import 'package:mediminder/repositories/health_metrics_repository.dart';

class GoogleFitSyncService {
  final Health _health = Health();
  final HealthMetricsRepository _repository = HealthMetricsRepository();

  /// Danh sách dữ liệu có thể lấy
  final List<HealthDataType> _dataTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.BODY_MASS_INDEX,
  ];

  /// 🔧 Cài đặt Health Connect
  Future<void> installHealthConnect() async {
    try {
      print('📱 Mở cửa hàng để cài Health Connect...');
      await _health.installHealthConnect();
    } catch (e) {
      print('⚠️ Không thể mở cửa hàng: $e');
    }
  }

  /// 1️⃣ Xin phép lần đầu (optional - skip nếu Health Connect đã cài)
  Future<bool> requestPermissions() async {
    try {
      print('🔔 Xin quyền truy cập Google Fit...');
      bool granted = await _health.requestAuthorization(_dataTypes);
      if (granted) {
        print('✅ Quyền được cấp!');
        return true;
      } else {
        print('⚠️ Quyền bị từ chối nhưng vẫn thử lấy dữ liệu');
        return true;
      }
    } catch (e) {
      String errorMsg = e.toString();
      print('⚠️ Cảnh báo xin quyền (không fatal): $e');

      // Nếu Health Connect throw error, assume đã cài và return true
      // Vì Health Connect đã cài, ta sẽ lấy dữ liệu trực tiếp
      if (errorMsg.contains('Google Health Connect')) {
        print('📲 Health Connect đã detect - thử lấy dữ liệu...');
        return true;
      }
      return false;
    }
  }

  /// 2️⃣ Đồng bộ dữ liệu ngày hôm nay
  Future<int> syncTodayData(String userId) async {
    try {
      print('⏳ Đang lấy dữ liệu hôm nay...');

      // Lấy từ lúc nửa đêm đến bây giờ
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      // SKIP permission request - lấy dữ liệu trực tiếp
      // Health Connect đã cài, permission sẽ được handle khi lấy data
      print('📱 Bỏ qua xin quyền - lấy dữ liệu trực tiếp từ Health Connect');

      List<HealthDataPoint> healthData = [];
      try {
        healthData = await _health.getHealthDataFromTypes(
          types: _dataTypes,
          startTime: startOfDay,
          endTime: now,
        );
        print('✅ Lấy được ${healthData.length} data points');
      } catch (e) {
        String errorMsg = e.toString();
        print('❌ Lỗi lấy dữ liệu: $errorMsg');

        // Nếu Health Connect không available, báo user
        if (errorMsg.contains('Google Health Connect is not available')) {
          print('📲 Health Connect chưa cài - vui lòng cài đặt');
          return 0;
        }

        // Nếu lỗi khác, retry 1 lần
        print('🔄 Retry lần 2...');
        await Future.delayed(const Duration(milliseconds: 500));
        try {
          healthData = await _health.getHealthDataFromTypes(
            types: _dataTypes,
            startTime: startOfDay,
            endTime: now,
          );
          print(
            '✅ Retry thành công - Lấy được ${healthData.length} data points',
          );
        } catch (retryError) {
          print('❌ Retry thất bại: $retryError');
          return 0;
        }
      }

      // Lưu vào database
      int savedCount = 0;
      for (var dataPoint in healthData) {
        try {
          bool saved = await _saveHealthData(userId, dataPoint);
          if (saved) savedCount++;
        } catch (e) {
          print('⚠️ Lỗi lưu: $e');
        }
      }

      print('✅ Lưu được $savedCount data points');
      return savedCount;
    } catch (e) {
      print('❌ Lỗi đồng bộ: $e');
      return 0;
    }
  }

  /// 3️⃣ Đồng bộ dữ liệu nhiều ngày
  Future<int> syncHistoricalData(String userId, int days) async {
    try {
      print('⏳ Đang lấy dữ liệu $days ngày trước...');

      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));

      // SKIP permission request - lấy dữ liệu trực tiếp
      print('📱 Bỏ qua xin quyền - lấy dữ liệu trực tiếp từ Health Connect');

      List<HealthDataPoint> healthData = [];
      try {
        healthData = await _health.getHealthDataFromTypes(
          types: _dataTypes,
          startTime: startDate,
          endTime: now,
        );
        print('✅ Lấy được ${healthData.length} data points');
      } catch (e) {
        String errorMsg = e.toString();
        print('❌ Lỗi lấy dữ liệu: $errorMsg');

        if (errorMsg.contains('Google Health Connect is not available')) {
          print('📲 Health Connect chưa cài - vui lòng cài đặt');
          return 0;
        }

        // Retry 1 lần
        print('🔄 Retry lần 2...');
        await Future.delayed(const Duration(milliseconds: 500));
        try {
          healthData = await _health.getHealthDataFromTypes(
            types: _dataTypes,
            startTime: startDate,
            endTime: now,
          );
          print(
            '✅ Retry thành công - Lấy được ${healthData.length} data points',
          );
        } catch (retryError) {
          print('❌ Retry thất bại: $retryError');
          return 0;
        }
      }

      int savedCount = 0;
      for (var dataPoint in healthData) {
        try {
          bool saved = await _saveHealthData(userId, dataPoint);
          if (saved) savedCount++;
        } catch (e) {
          print('⚠️ Lỗi: $e');
        }
      }

      print('✅ Đã lưu $savedCount dữ liệu từ $days ngày trước');
      return savedCount;
    } catch (e) {
      print('❌ Lỗi: $e');
      return 0;
    }
  }

  /// Helper: Lưu từng data point
  Future<bool> _saveHealthData(String userId, HealthDataPoint dataPoint) async {
    try {
      String? metricType;
      double? value;
      String? unit;

      // Phân loại dữ liệu
      switch (dataPoint.typeString) {
        case 'STEPS':
          metricType = 'steps';
          value = (dataPoint.value as num).toDouble();
          unit = 'steps';
          break;

        case 'HEART_RATE':
          metricType = 'heart_rate';
          value = (dataPoint.value as num).toDouble();
          unit = 'bpm';
          break;

        case 'BLOOD_PRESSURE':
          metricType = 'blood_pressure';
          value = (dataPoint.value as num).toDouble();
          unit = 'mmHg';
          break;

        case 'BLOOD_GLUCOSE':
          metricType = 'glucose';
          value = (dataPoint.value as num).toDouble();
          unit = 'mg/dL';
          break;

        case 'BODY_MASS_INDEX':
          metricType = 'bmi';
          value = (dataPoint.value as num).toDouble();
          unit = 'kg/m²';
          break;
      }

      // Lưu vào database nếu có dữ liệu
      if (metricType != null && value != null) {
        await _repository.addHealthMetric(
          userId: userId,
          metricType: metricType,
          valueNumeric: value,
          unit: unit ?? '',
          source: 'google_fit',
          measuredAt: dataPoint.dateFrom,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error saving data: $e');
      return false;
    }
  }

  /// Disconnect (optional)
  Future<void> disconnect() async {
    try {
      await _health.revokePermissions();
      print('✅ Đã ngắt kết nối');
    } catch (e) {
      print('❌ Lỗi ngắt: $e');
    }
  }

  /// Kiểm tra xem có dữ liệu hôm nay không
  Future<bool> hasDataToday() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startOfDay,
        endTime: now,
      );

      return data.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
