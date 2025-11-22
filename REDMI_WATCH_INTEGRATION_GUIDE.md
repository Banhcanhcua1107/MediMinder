# 🔗 Hướng Dẫn Tích Hợp Redmi Watch & Mi Fitness

**Cập nhật:** 21 Tháng 11, 2025
**Trạng thái:** Chi tiết các giải pháp thực tế

---

## 📌 Các Cách Tích Hợp Dữ Liệu Sức Khỏe

### ✅ Cách 1: Google Fit API (Khuyên Dùng) ⭐

**Ưu điểm:**
- ✅ Dễ tích hợp nhất
- ✅ Hỗ trợ chính thức từ Google
- ✅ Hoạt động trên tất cả thiết bị Android
- ✅ Miễn phí 100%

**Nhược điểm:**
- ❌ Chỉ hoạt động trên Android
- ❌ Cần người dùng cài Google Fit trên điện thoại

**Các Thiết Bị Hỗ Trợ:**
- Samsung Galaxy Watch
- Garmin
- Fitbit
- Realme Band
- **Redmi Watch (nếu cài Google Fit)**
- Hầu hết smartwatch Android

#### 🔑 Bước 1: Tạo Google Cloud Project

1. Truy cập: [https://console.cloud.google.com](https://console.cloud.google.com)
2. Tạo project mới: **"MediMinder Health"**
3. Bật API: **Google Fit API**
4. Tạo OAuth 2.0 Credentials:
   - Type: **OAuth Client ID**
   - Application type: **Android**
   - Nhập package name: `com.mediminder.app`
   - Nhập SHA-1 fingerprint:
     ```bash
     # Lấy SHA-1 của keystore
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```

#### 🔑 Bước 2: Cài Đặt Flutter Package

```bash
flutter pub add google_fit
flutter pub add google_sign_in
```

#### 🔑 Bước 3: Implement Code

**File:** `lib/services/google_fit_integration_service.dart`

```dart
import 'package:google_fit/google_fit.dart';
import 'package:mediminder/repositories/health_metrics_repository.dart';

class GoogleFitIntegrationService {
  final HealthMetricsRepository _repository = HealthMetricsRepository();

  /// Authenticate with Google Fit
  Future<bool> authenticate() async {
    try {
      bool? isAuthorized = await GoogleFit.requestAuthorization();
      return isAuthorized ?? false;
    } catch (e) {
      print('Google Fit Auth Error: $e');
      return false;
    }
  }

  /// Get today's step count
  Future<int> getTodaySteps(String userId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      var stepsData = await GoogleFit.getActivityData(
        startOfDay,
        DateTime.now(),
      );

      // stepsData returns list of activities
      int totalSteps = 0;
      if (stepsData != null) {
        for (var activity in stepsData) {
          totalSteps += activity['steps'] as int? ?? 0;
        }
      }

      // Save to database
      await _repository.addHealthMetric(
        userId: userId,
        metricType: 'steps',
        valueNumeric: totalSteps.toDouble(),
        unit: 'steps',
        source: 'google_fit',
      );

      return totalSteps;
    } catch (e) {
      print('Error getting steps: $e');
      return 0;
    }
  }

  /// Get heart rate data
  Future<List<double>> getHeartRateData(String userId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      // Note: Google Fit API returns limited heart rate data
      // For detailed heart rate, user needs wearable with heart rate sensor
      var heartRateData = await GoogleFit.getHeartRateBySamples(
        startOfDay,
        DateTime.now(),
      );

      List<double> rates = [];
      if (heartRateData != null) {
        for (var data in heartRateData) {
          final hr = (data['value'] as num?)?.toDouble() ?? 0.0;
          if (hr > 0) {
            rates.add(hr);
            
            // Save each measurement
            await _repository.addHealthMetric(
              userId: userId,
              metricType: 'heart_rate',
              valueNumeric: hr,
              unit: 'bpm',
              source: 'google_fit',
            );
          }
        }
      }

      return rates;
    } catch (e) {
      print('Error getting heart rate: $e');
      return [];
    }
  }

  /// Get sleep data
  Future<double> getSleepData(String userId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day - 1);

      var sleepData = await GoogleFit.getSleep(
        startOfDay,
        DateTime.now(),
      );

      double totalSleep = 0;
      if (sleepData != null && sleepData is List) {
        for (var data in sleepData) {
          // Sleep duration in milliseconds
          final duration = (data['duration'] as int?)?.toDouble() ?? 0.0;
          totalSleep += duration / (1000 * 60 * 60); // Convert to hours
        }
      }

      // Save to database
      await _repository.addHealthMetric(
        userId: userId,
        metricType: 'sleep',
        valueNumeric: totalSleep,
        unit: 'hours',
        source: 'google_fit',
      );

      return totalSleep;
    } catch (e) {
      print('Error getting sleep: $e');
      return 0;
    }
  }

  /// Sync all available data
  Future<void> syncAllData(String userId) async {
    try {
      await getTodaySteps(userId);
      await getHeartRateData(userId);
      await getSleepData(userId);
      print('✓ Sync from Google Fit completed');
    } catch (e) {
      print('Error syncing data: $e');
    }
  }

  /// Disconnect Google Fit
  Future<void> disconnect() async {
    try {
      await GoogleFit.disconnect();
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }
}
```

#### 🔑 Bước 4: Update Health Screen

```dart
ElevatedButton.icon(
  onPressed: () async {
    final service = GoogleFitIntegrationService();
    final isAuth = await service.authenticate();
    
    if (isAuth) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await service.syncAllData(user.id);
        _loadData(); // Refresh UI
      }
    }
  },
  icon: const Icon(Icons.fitness_center),
  label: const Text('Đồng Bộ từ Google Fit'),
),
```

---

### ✅ Cách 2: Health Connect API (Google - Mới Nhất) ⭐⭐

**Ưu điểm:**
- ✅ API mới nhất từ Google
- ✅ Hỗ trợ nhiều ứng dụng health
- ✅ Bảo mật tốt hơn
- ✅ Hỗ trợ cả Android và iOS (sắp tới)

**Nhược điểm:**
- ❌ Chỉ hỗ trợ Android 6.0+
- ❌ Cần cài Health Connect app

**Các Thiết Bị Hỗ Trợ:**
- Tất cả Android watches
- Samsung Galaxy Watch
- Xiaomi Watch (qua Health Connect)
- Fitbit
- Garmin

#### 🔑 Bước 1: Cài Package

```bash
flutter pub add health_connect
```

#### 🔑 Bước 2: Implement Code

**File:** `lib/services/health_connect_integration_service.dart`

```dart
import 'package:health_connect/health_connect.dart';
import 'package:mediminder/repositories/health_metrics_repository.dart';

class HealthConnectIntegrationService {
  final HealthMetricsRepository _repository = HealthMetricsRepository();
  final healthConnect = HealthConnect();

  /// Request permissions
  Future<bool> requestPermissions() async {
    try {
      final permissions = [
        HealthConnectDataTypes.steps,
        HealthConnectDataTypes.heart_rate,
        HealthConnectDataTypes.sleep,
        HealthConnectDataTypes.blood_pressure,
      ];

      final granted = await healthConnect.requestAuthorization(permissions);
      return granted;
    } catch (e) {
      print('Permission Error: $e');
      return false;
    }
  }

  /// Get steps
  Future<int> getSteps(String userId, {Duration lookback = const Duration(days: 1)}) async {
    try {
      final now = DateTime.now();
      final start = now.subtract(lookback);

      final records = await healthConnect.readRecords(
        recordTypes: [RecordType.steps],
        timeRangeFilter: TimeRangeFilter(startTime: start, endTime: now),
      );

      int totalSteps = 0;
      for (var record in records) {
        if (record is StepsRecord) {
          totalSteps += record.count;
          
          // Save to DB
          await _repository.addHealthMetric(
            userId: userId,
            metricType: 'steps',
            valueNumeric: record.count.toDouble(),
            unit: 'steps',
            source: 'health_connect',
            measuredAt: record.endTime ?? DateTime.now(),
          );
        }
      }

      return totalSteps;
    } catch (e) {
      print('Error getting steps: $e');
      return 0;
    }
  }

  /// Get heart rate
  Future<List<int>> getHeartRate(String userId, {Duration lookback = const Duration(days: 1)}) async {
    try {
      final now = DateTime.now();
      final start = now.subtract(lookback);

      final records = await healthConnect.readRecords(
        recordTypes: [RecordType.heart_rate],
        timeRangeFilter: TimeRangeFilter(startTime: start, endTime: now),
      );

      List<int> rates = [];
      for (var record in records) {
        if (record is HeartRateRecord) {
          for (var sample in record.samples) {
            rates.add(sample.beatsPerMinute);

            // Save to DB
            await _repository.addHealthMetric(
              userId: userId,
              metricType: 'heart_rate',
              valueNumeric: sample.beatsPerMinute.toDouble(),
              unit: 'bpm',
              source: 'health_connect',
              measuredAt: sample.time ?? DateTime.now(),
            );
          }
        }
      }

      return rates;
    } catch (e) {
      print('Error getting heart rate: $e');
      return [];
    }
  }

  /// Get blood pressure
  Future<void> getBloodPressure(String userId, {Duration lookback = const Duration(days: 1)}) async {
    try {
      final now = DateTime.now();
      final start = now.subtract(lookback);

      final records = await healthConnect.readRecords(
        recordTypes: [RecordType.blood_pressure],
        timeRangeFilter: TimeRangeFilter(startTime: start, endTime: now),
      );

      for (var record in records) {
        if (record is BloodPressureRecord) {
          // Save systolic
          await _repository.addHealthMetric(
            userId: userId,
            metricType: 'blood_pressure',
            valueNumeric: record.systolic.toDouble(),
            valueSecondary: record.diastolic,
            unit: 'mmHg',
            source: 'health_connect',
            measuredAt: record.time ?? DateTime.now(),
          );
        }
      }
    } catch (e) {
      print('Error getting blood pressure: $e');
    }
  }

  /// Get sleep
  Future<double> getSleep(String userId, {Duration lookback = const Duration(days: 1)}) async {
    try {
      final now = DateTime.now();
      final start = now.subtract(lookback);

      final records = await healthConnect.readRecords(
        recordTypes: [RecordType.sleep],
        timeRangeFilter: TimeRangeFilter(startTime: start, endTime: now),
      );

      double totalHours = 0;
      for (var record in records) {
        if (record is SleepSessionRecord) {
          final duration = record.endTime!.difference(record.startTime!);
          final hours = duration.inMinutes / 60.0;
          totalHours += hours;

          // Save to DB
          await _repository.addHealthMetric(
            userId: userId,
            metricType: 'sleep',
            valueNumeric: hours,
            unit: 'hours',
            source: 'health_connect',
            measuredAt: record.startTime ?? DateTime.now(),
          );
        }
      }

      return totalHours;
    } catch (e) {
      print('Error getting sleep: $e');
      return 0;
    }
  }

  /// Sync all data
  Future<void> syncAll(String userId) async {
    try {
      await getSteps(userId);
      await getHeartRate(userId);
      await getBloodPressure(userId);
      await getSleep(userId);
      print('✓ Health Connect sync completed');
    } catch (e) {
      print('Error syncing: $e');
    }
  }
}
```

---

### ✅ Cách 3: Samsung Health API (Nếu User Dùng Samsung)

**Ưu điểm:**
- ✅ Tích hợp sâu với Samsung devices
- ✅ Dữ liệu chi tiết

**Nhược điểm:**
- ❌ Chỉ hoạt động trên Samsung
- ❌ Phức tạp hơn

**Package:**
```bash
flutter pub add samsung_health
```

---

### ✅ Cách 4: Apple HealthKit (iOS Users)

**Package:**
```bash
flutter pub add health
```

**Code:**
```dart
import 'package:health/health.dart';

Future<void> syncAppleHealth(String userId) async {
  final health = Health();
  
  final types = [
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_PRESSURE,
    HealthDataType.BODY_MASS_INDEX,
    HealthDataType.SLEEP,
  ];

  // Request permissions
  await health.requestAuthorization(types);

  // Get data from last 24 hours
  final now = DateTime.now();
  final yesterday = now.subtract(Duration(days: 1));

  final data = await health.getHealthDataFromTypes(
    types: types,
    startTime: yesterday,
    endTime: now,
  );

  // Save to repository
  for (var point in data) {
    await _repository.addHealthMetric(
      userId: userId,
      metricType: point.typeString,
      valueNumeric: point.value as double,
      unit: point.unit,
      source: 'apple_health',
    );
  }
}
```

---

### ✅ Cách 5: Manual Sync từ Mi Fitness App (Dự Phòng)

**Nếu không thể tích hợp API trực tiếp:**

1. **Export dữ liệu từ Mi Fitness:**
   - Mở Mi Fitness app
   - Settings → Data → Export
   - Chọn định dạng CSV

2. **Import vào MediMinder:**
   - Tạo file picker
   - Parse CSV
   - Save to database

**Code:**
```dart
import 'package:file_picker/file_picker.dart';
import 'dart:io';

Future<void> importCsvData(String userId) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );

  if (result != null && result.files.isNotEmpty) {
    final file = File(result.files.first.path!);
    final lines = await file.readAsLines();

    // Parse CSV
    for (var line in lines.skip(1)) { // Skip header
      final fields = line.split(',');
      
      // Assuming format: date,time,metric_type,value,unit
      await _repository.addHealthMetric(
        userId: userId,
        metricType: fields[2],
        valueNumeric: double.parse(fields[3]),
        unit: fields[4],
        source: 'mi_fitness_export',
      );
    }
  }
}
```

---

### ✅ Cách 6: REST API từ Xiaomi Cloud (Nếu Có Tài Khoản Enterprise)

**Yêu cầu:**
- Tài khoản Xiaomi Developer Enterprise
- Thực hiện KYC verification

**Endpoint:**
```
https://api.mi.com/v3/oauth/authorize
https://api.mi.com/v3/user/profile
https://api.mi.com/v3/fitness/data
```

**Chi phí:** Có thể tính phí dựa trên API calls

---

## 📊 Bảng So Sánh

| Phương Pháp | Dễ Dùng | Hỗ Trợ | Chi Phí | Khuyên Dùng |
|-----------|---------|--------|---------|-----------|
| **Google Fit** | ⭐⭐⭐⭐ | Android | Miễn phí | ✅ Chọn cái này |
| **Health Connect** | ⭐⭐⭐⭐ | Android 6+ | Miễn phí | ✅ Mới nhất |
| **Apple HealthKit** | ⭐⭐⭐⭐ | iOS | Miễn phí | ✅ Cho iOS |
| **Samsung Health** | ⭐⭐⭐ | Samsung | Miễn phí | Chỉ Samsung |
| **Xiaomi REST API** | ⭐⭐ | Xiaomi | Có phí | ❌ Không khuyên |
| **CSV Import** | ⭐⭐⭐ | Tất cả | Miễn phí | ✅ Dự phòng |

---

## 🎯 Khuyến Cáo

### 🏆 Giải pháp tốt nhất: **Google Fit + Health Connect**

```dart
class HealthSyncService {
  /// Try multiple sources in order
  Future<void> syncHealth(String userId) async {
    try {
      // Thử Health Connect trước (mới nhất)
      final healthConnect = HealthConnectIntegrationService();
      if (await healthConnect.requestPermissions()) {
        await healthConnect.syncAll(userId);
        return;
      }
    } catch (e) {
      print('Health Connect failed: $e');
    }

    try {
      // Fallback to Google Fit
      final googleFit = GoogleFitIntegrationService();
      if (await googleFit.authenticate()) {
        await googleFit.syncAllData(userId);
        return;
      }
    } catch (e) {
      print('Google Fit failed: $e');
    }

    // Nếu tất cả đều fail
    print('⚠️ No health sync available');
  }
}
```

---

## 🔐 Bảo Mật

### ✅ Best Practices

1. **Không lưu trữ tokens trong plain text:**
```dart
import 'flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

// Save token
await storage.write(
  key: 'health_token',
  value: accessToken,
);

// Retrieve token
final token = await storage.read(key: 'health_token');
```

2. **Xin phép từng lần:**
```dart
// Android & iOS đều yêu cầu permissions trước khi access
await healthConnect.requestPermissions();
```

3. **Encrypt data khi gửi:**
```dart
// Sử dụng HTTPS
// Implement certificate pinning nếu cần
```

---

## ❓ FAQ

### Q: Cái nào hoạt động với Redmi Watch?

**A:** Redmi Watch hoạt động tốt nhất với:
1. **Google Fit** (nếu cài Google Fit trên watch)
2. **Health Connect** (nếu Redmi Watch hỗ trợ)
3. **Manual Export từ Mi Fitness**

### Q: Tôi có thể kết hợp nhiều source không?

**A:** Có! Lưu giữ `source` field:
```dart
// Combine data from multiple sources
source: 'google_fit' // or 'health_connect', 'mi_fitness', etc.
```

### Q: Làm sao biết user đã cho phép access?

**A:** Check permissions:
```dart
final hasPermission = await googleFit.authenticate();
if (!hasPermission) {
  // Show dialog to request permissions
}
```

### Q: Có thể auto-sync không?

**A:** Có, dùng WorkManager:
```dart
import 'package:workmanager/workmanager.dart';

void main() {
  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask(
    'sync_health',
    'syncHealthData',
    frequency: Duration(hours: 1),
  );
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await syncHealth(userId);
    return true;
  });
}
```

### Q: Có offline support không?

**A:** Có, lưu locally rồi sync khi online:
```dart
// Save locally (Hive/SQLite)
await localDb.save(healthMetric);

// Sync when online
if (await isConnected()) {
  await repository.addHealthMetric(healthMetric);
}
```

---

## 📝 Danh Sách Dependencies

```yaml
dependencies:
  # Android/Web
  google_fit: ^1.1.0
  google_sign_in: ^6.1.0
  health_connect: ^0.1.0
  
  # iOS
  health: ^7.1.0
  
  # Utilities
  flutter_secure_storage: ^9.0.0
  workmanager: ^0.5.1
  file_picker: ^6.0.0
  intl: ^0.19.0
```

Install:
```bash
flutter pub add google_fit google_sign_in health_connect health flutter_secure_storage workmanager file_picker intl
```

---

## ✅ Checklist Triển Khai

- [ ] Chọn phương pháp tích hợp (khuyến cáo: Google Fit + Health Connect)
- [ ] Tạo Google Cloud Project (nếu dùng Google Fit)
- [ ] Cài đặt Flutter packages
- [ ] Implement integration service
- [ ] Update Health Screen UI
- [ ] Test trên thực tế
- [ ] Implement auto-sync (nếu muốn)
- [ ] Thiết lập secure token storage
- [ ] Deploy lên production

---

**Kết Luận:** Không nên dùng Xiaomi REST API trực tiếp. Thay vào đó, dùng **Google Fit hoặc Health Connect** vì dễ hơn và an toàn hơn! 🎯

