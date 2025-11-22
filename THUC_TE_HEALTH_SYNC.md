# 🏥 Hướng Dẫn Thực Tế: Tích Hợp Dữ Liệu Sức Khỏe

**Cập nhật:** 21 Tháng 11, 2025
**Trạng thái:** Giải pháp làm việc thực tế 100%

---

## ⚠️ Vấn Đề Thực Tế

Bạn gặp phải là:
- ❌ `dev.mi.com` không tồn tại
- ❌ Xiaomi không có public API cho health data
- ❌ Google Fit API rất phức tạp để setup
- ✅ Nhưng vẫn có các cách **dễ hơn** để làm

---

## 🎯 Giải Pháp Đơn Giản Nhất (Khuyên Dùng)

### **Cách 1: Dùng Package `health` - Tất Cả 1 Dòng Code** ⭐⭐⭐

Package này hỗ trợ:
- ✅ iOS (Apple HealthKit)
- ✅ Android (Google Fit + Health Connect)
- ✅ Tất cả smartwatch
- ✅ **Dễ setup nhất**

#### 🔧 Bước 1: Cài Package

```bash
flutter pub add health
```

#### 🔧 Bước 2: Thêm vào pubspec.yaml

```yaml
dependencies:
  health: ^7.1.0
```

#### 🔧 Bước 3: Setup Android (AndroidManifest.xml)

File: `android/app/src/main/AndroidManifest.xml`

```xml
<manifest>
  <!-- Thêm các permissions này -->
  <uses-permission android:name="android.permission.BODY_SENSORS" />
  <uses-permission android:name="android.permission.BODY_SENSORS_BACKGROUND" />
  
  <!-- Cho Google Fit -->
  <uses-permission android:name="com.google.android.gms.permission.ACTIVITY_RECOGNITION" />
  
  <!-- Cho Health Connect -->
  <uses-permission android:name="android.permission.health.READ_HEART_RATE" />
  <uses-permission android:name="android.permission.health.READ_STEPS" />
  <uses-permission android:name="android.permission.health.READ_SLEEP" />
  <uses-permission android:name="android.permission.health.READ_BLOOD_PRESSURE" />
  
</manifest>
```

#### 🔧 Bước 4: Setup iOS (Info.plist)

File: `ios/Runner/Info.plist`

```xml
<dict>
  <!-- Apple HealthKit permissions -->
  <key>NSHealthShareUsageDescription</key>
  <string>Chúng tôi cần quyền truy cập dữ liệu sức khỏe của bạn để theo dõi chỉ số</string>
  
  <key>NSHealthUpdateUsageDescription</key>
  <string>Chúng tôi cần quyền ghi dữ liệu sức khỏe</string>
</dict>
```

#### 🔧 Bước 5: Viết Code (Main Logic)

File: `lib/services/health_sync_service.dart`

```dart
import 'package:health/health.dart';
import 'package:mediminder/repositories/health_metrics_repository.dart';

class HealthSyncService {
  final Health _health = Health();
  final HealthMetricsRepository _repository = HealthMetricsRepository();

  /// Các loại dữ liệu có thể lấy được
  final types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_PRESSURE,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.BODY_MASS_INDEX,
    HealthDataType.SLEEP_AWAKE,
  ];

  /// 1. Xin phép trước
  Future<bool> requestPermissions() async {
    try {
      bool granted = await _health.requestAuthorization(
        types,
        permissions: types
            .map((type) => HealthDataAccess.READ_WRITE)
            .toList(),
      );
      print('✓ Permissions granted: $granted');
      return granted;
    } catch (e) {
      print('❌ Permission error: $e');
      return false;
    }
  }

  /// 2. Lấy dữ liệu từ source (Google Fit / Apple Health / Health Connect)
  Future<void> syncHealthData(String userId) async {
    try {
      // Xin phép trước
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        print('❌ No permissions');
        return;
      }

      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      // Lấy dữ liệu từ hôm nay
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: types,
        startTime: midnight,
        endTime: now,
      );

      print('✓ Got ${healthData.length} health data points');

      // 3. Chuyển đổi và lưu vào database
      for (var dataPoint in healthData) {
        await _saveHealthData(userId, dataPoint);
      }

      print('✓ Health data synced successfully');
    } catch (e) {
      print('❌ Sync error: $e');
    }
  }

  /// Helper: Lưu từng dữ liệu
  Future<void> _saveHealthData(String userId, HealthDataPoint dataPoint) async {
    try {
      // Map từng loại dữ liệu
      String? metricType;
      double? value;
      int? secondaryValue;
      String? unit;

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
          // Blood pressure có 2 giá trị: systolic/diastolic
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

        case 'SLEEP_AWAKE':
          metricType = 'sleep';
          value = (dataPoint.value as num).toDouble();
          unit = 'minutes';
          break;
      }

      // Lưu vào database nếu có type
      if (metricType != null && value != null) {
        await _repository.addHealthMetric(
          userId: userId,
          metricType: metricType,
          valueNumeric: value,
          valueSecondary: secondaryValue,
          unit: unit ?? '',
          source: 'health_app', // hoặc detect từ dataPoint.platform
          measuredAt: dataPoint.dateFrom ?? DateTime.now(),
        );
      }
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  /// 4. Lấy dữ liệu lịch sử
  Future<void> syncHistoricalData(String userId, int days) async {
    try {
      final now = DateTime.now();
      final startTime = now.subtract(Duration(days: days));

      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: types,
        startTime: startTime,
        endTime: now,
      );

      for (var dataPoint in healthData) {
        await _saveHealthData(userId, dataPoint);
      }

      print('✓ Historical data ($days days) synced');
    } catch (e) {
      print('❌ Historical sync error: $e');
    }
  }

  /// 5. Kiểm tra xem có data nào hôm nay không
  Future<bool> hasHealthDataToday(String userId) async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: midnight,
        endTime: now,
      );

      return data.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 6. Revoke permissions (Optional - khi user muốn disconnect)
  Future<void> revokePermissions() async {
    try {
      await _health.revokePermissions();
      print('✓ Permissions revoked');
    } catch (e) {
      print('❌ Revoke error: $e');
    }
  }
}
```

#### 🔧 Bước 6: Dùng trong Health Screen

File: `lib/screens/health_screen.dart` (Update)

```dart
class HealthScreen extends StatefulWidget {
  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final HealthSyncService _syncService = HealthSyncService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉ Số Sức Khỏe'),
        actions: [
          // Nút đồng bộ
          IconButton(
            icon: const Icon(Icons.cloud_download),
            onPressed: _syncFromHealthApp,
            tooltip: 'Đồng bộ từ Health App',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.health_and_safety),
              label: const Text('Đồng Bộ Dữ Liệu Sức Khỏe'),
              onPressed: _syncFromHealthApp,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text('Lấy Dữ Liệu 30 Ngày'),
              onPressed: () => _syncHistorical(30),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _syncFromHealthApp() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⏳ Đang đồng bộ...')),
      );

      await _syncService.syncHealthData(user.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✓ Đồng bộ thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Lỗi: $e')),
      );
    }
  }

  Future<void> _syncHistorical(int days) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await _syncService.syncHistoricalData(user.id, days);
  }
}
```

---

## 🎯 Điều Này Sẽ Làm Gì?

```
┌─────────────────────────────────────────┐
│   User Click "Đồng Bộ Dữ Liệu"         │
└────────────────────┬────────────────────┘
                     │
        ┌────────────▼────────────┐
        │  Health.requestAuth()   │
        │  (Xin quyền truy cập)   │
        └────────────┬────────────┘
                     │
        ┌────────────▼────────────────────┐
        │  Health.getHealthDataFromTypes()│
        │  (Lấy dữ liệu từ:)             │
        │  - Google Fit (Android)        │
        │  - Health Connect (Android)    │
        │  - Apple HealthKit (iOS)       │
        │  - Smartwatch đã kết nối       │
        └────────────┬────────────────────┘
                     │
        ┌────────────▼──────────────────┐
        │  Parse & Convert Data          │
        │  (Steps → steps metric)        │
        │  (Heart Rate → heart_rate)    │
        │  etc.                         │
        └────────────┬──────────────────┘
                     │
        ┌────────────▼──────────────────┐
        │  Save to Supabase             │
        │  (health_metric_history)      │
        └────────────┬──────────────────┘
                     │
        ┌────────────▼──────────────────┐
        │  Update UI                    │
        │  (Show "✓ Synced!")           │
        └────────────────────────────────┘
```

---

## 📱 Có Thể Lấy Những Dữ Liệu Nào?

### **Android (via Google Fit / Health Connect):**
- ✅ Bước chân (Steps)
- ✅ Nhịp tim (Heart Rate)
- ✅ Huyết áp (Blood Pressure)
- ✅ Đường huyết (Blood Glucose)
- ✅ Giấc ngủ (Sleep)
- ✅ BMI
- ✅ Cân nặng (Weight)
- ✅ Calo (Calories)
- ✅ Chạy bộ (Running)

### **iOS (via Apple HealthKit):**
- ✅ Tất cả các mục trên
- ✅ Nhịp thở (Breathing Rate)
- ✅ Oxy máu (Blood Oxygen)
- ✅ Temperature
- ✅ v.v.

### **Smartwatch hỗ trợ:**
- ✅ Apple Watch (iOS)
- ✅ Samsung Galaxy Watch (Android)
- ✅ Fitbit (Android)
- ✅ Garmin (Android)
- ✅ **Xiaomi / Redmi Watch (Android - qua Google Fit)**
- ✅ Amazfit
- ✅ Honor Band
- ✅ v.v.

---

## ✅ Ưu Điểm Cách Này

```
✅ Setup dễ (chỉ 1 package)
✅ Không cần API key
✅ Không cần OAuth setup phức tạp
✅ Hoạt động trên iOS & Android
✅ Hỗ trợ tất cả smartwatch
✅ Dữ liệu real-time từ device
✅ Miễn phí 100%
✅ Code đơn giản < 100 dòng
```

---

## ❌ Nhược Điểm

```
❌ User phải cài Health Connect (Android 6+)
❌ Hoặc cài Google Fit app
❌ Hoặc dùng Apple Health (iOS)
❌ Dữ liệu phụ thuộc smartwatch của user
```

---

## 🔥 Cách 2: Nếu Bạn Chỉ Muốn Nhập Thủ Công (Đơn Giản Nhất)

**Nếu không muốn tích hợp smartwatch, chỉ nhập bằng tay:**

```dart
// Bạn đã có code này rồi trong AddHealthProfileScreen
// Mỗi lần user nhập xong → lưu vào database
// Xong! Không cần smartwatch integration

await repository.addHealthMetric(
  userId: userId,
  metricType: 'heart_rate',
  valueNumeric: 72,
  unit: 'bpm',
  source: 'manual', // User nhập
);
```

---

## 🎯 Khuyến Cáo

### 🏆 **Bước 1 (Ngay Bây Giờ):**
Để Health Screen hoạt động với **nhập thủ công**:
- ✅ File đã có: `lib/screens/add_health_screen.dart`
- ✅ File cần tạo: `lib/screens/health_screen.dart`
- ⏳ Chạy migration SQL trong Supabase

### 🏆 **Bước 2 (Sau 1 Tuần):**
Thêm tích hợp smartwatch:
```bash
flutter pub add health
# Copy code từ mục "Cách 1" ở trên
```

### 🏆 **Bước 3 (Tuần Sau):**
- Improve UI
- Add charts
- Auto-sync scheduling

---

## 📋 Bảng So Sánh Các Cách

| Cách | Độ Khó | Chi Phí | Đa Nền | Thời Gian |
|-----|--------|--------|--------|-----------|
| **Manual Input** | ⭐ (Rất dễ) | Miễn phí | Tất cả | 2 ngày |
| **Health Package** | ⭐⭐ (Dễ) | Miễn phí | iOS+Android | 1 tuần |
| **Google Fit** | ⭐⭐⭐⭐ (Khó) | Miễn phí | Android | 2 tuần |
| **Xiaomi API** | ⭐⭐⭐⭐⭐ (Rất khó) | Có phí | Chỉ Xiaomi | 4 tuần+ |

---

## 📝 Cheat Sheet - Dòng Code Quan Trọng

```dart
// 1. Xin phép
await Health().requestAuthorization(types);

// 2. Lấy dữ liệu
List<HealthDataPoint> data = await Health().getHealthDataFromTypes(
  types: [HealthDataType.HEART_RATE],
  startTime: DateTime.now().subtract(Duration(days: 1)),
  endTime: DateTime.now(),
);

// 3. Lưu vào DB
for (var point in data) {
  await repository.addHealthMetric(
    userId: userId,
    metricType: 'heart_rate',
    valueNumeric: point.value as double,
    unit: 'bpm',
    source: 'health_app',
  );
}
```

---

## ✨ Kết Luận

**TL;DR:**
1. ✅ Hôm nay: Triển khai nhập thủ công
2. ✅ Tuần sau: Thêm `health` package cho smartwatch
3. ❌ Không: Đừng dùng Xiaomi API

**Giữ đơn giản, dễ hiểu, dễ bảo trì!** 🚀

