# 🚀 Setup Google Fit - Hướng Dẫn Từng Bước

**Cập nhật:** 21 Tháng 11, 2025
**Thời gian:** ~30 phút để setup xong

---

## 📋 Các Bước Setup

### ✅ Bước 1: Cài Google Fit Trên Điện Thoại Test

**Nếu chưa có:**
1. Mở Play Store
2. Tìm "Google Fit"
3. Cài đặt

**Link trực tiếp:**
https://play.google.com/store/apps/details?id=com.google.android.apps.fitness

---

### ✅ Bước 2: Cài Package Health

Chạy lệnh:

```bash
cd d:\LapTrinhUngDungDT\MediMinder_DA\mediminder
flutter pub add health
```

**Kết quả dự kiến:**
```
✓ Added health
Running "flutter pub get" in mediminder...
Successfully added health to pubspec.yaml
```

---

### ✅ Bước 3: Cấu Hình Android

File: `android/app/build.gradle.kts`

**Tìm section `android { ... }`** và thêm:

```gradle
android {
    compileSdk 34  // Đảm bảo >= 33
    
    defaultConfig {
        applicationId "com.mediminder.app"
        minSdk 21  // Google Fit yêu cầu >= 21
        targetSdk 34
        // ... các config khác
    }
    
    // THÊM PHẦN NÀY
    packagingOptions {
        exclude 'META-INF/proguard/androidx-*.pro'
    }
}
```

**Thêm dependencies** (nếu chưa có):

```gradle
dependencies {
    // Health package dependencies
    implementation 'androidx.work:work-runtime-ktx:2.8.1'
    implementation 'com.google.android.gms:play-services-fitness:21.1.0'
    
    // Existing dependencies...
}
```

---

### ✅ Bước 4: Cấu Hình AndroidManifest.xml

File: `android/app/src/main/AndroidManifest.xml`

**Thêm permissions (bên trong `<manifest>`):**

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    package="com.mediminder.app">

    <!-- Permissions for Health/Fitness -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <!-- For Google Fit -->
    <uses-permission android:name="com.google.android.gms.permission.ACTIVITY_RECOGNITION" />
    
    <!-- For Health data -->
    <uses-permission android:name="android.permission.BODY_SENSORS" />
    <uses-permission android:name="android.permission.BODY_SENSORS_BACKGROUND" />

    <application
        android:label="MediMinder"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Activity declarations... -->
        
    </application>
</manifest>
```

---

### ✅ Bước 5: Tạo Health Sync Service

**File:** `lib/services/google_fit_sync_service.dart`

Tạo file mới với nội dung:

```dart
import 'package:health/health.dart';
import 'package:mediminder/repositories/health_metrics_repository.dart';

class GoogleFitSyncService {
  final Health _health = Health();
  final HealthMetricsRepository _repository = HealthMetricsRepository();

  /// Danh sách dữ liệu có thể lấy
  final List<HealthDataType> _dataTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_PRESSURE,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.BODY_MASS_INDEX,
  ];

  /// 1️⃣ Xin phép lần đầu
  Future<bool> requestPermissions() async {
    try {
      print('🔔 Xin quyền truy cập Google Fit...');
      
      bool granted = await _health.requestAuthorization(_dataTypes);
      
      if (granted) {
        print('✅ Quyền được cấp!');
        return true;
      } else {
        print('❌ Quyền bị từ chối');
        return false;
      }
    } catch (e) {
      print('❌ Lỗi xin quyền: $e');
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

      // Xin quyền trước
      bool hasPermission = await requestPermissions();
      if (!hasPermission) {
        print('❌ Không có quyền!');
        return 0;
      }

      // Lấy dữ liệu
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: _dataTypes,
        startTime: startOfDay,
        endTime: now,
      );

      print('✅ Lấy được ${healthData.length} data points');

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

      bool hasPermission = await requestPermissions();
      if (!hasPermission) return 0;

      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: _dataTypes,
        startTime: startDate,
        endTime: now,
      );

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
          measuredAt: dataPoint.dateFrom ?? DateTime.now(),
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
```

---

### ✅ Bước 6: Tạo Health Screen

**File:** `lib/screens/health_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:mediminder/services/google_fit_sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({Key? key}) : super(key: key);

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final GoogleFitSyncService _syncService = GoogleFitSyncService();
  bool _isLoading = false;
  String _status = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉ Số Sức Khỏe'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.health_and_safety,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Đồng Bộ Dữ Liệu Sức Khỏe',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kết nối với Google Fit để lấy dữ liệu từ smartwatch',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              
              // Nút đồng bộ hôm nay
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _syncToday,
                icon: const Icon(Icons.cloud_download),
                label: const Text('Đồng Bộ Hôm Nay'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  backgroundColor: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),
              
              // Nút lấy dữ liệu 7 ngày
              ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _syncHistorical(7),
                icon: const Icon(Icons.history),
                label: const Text('Lấy Dữ Liệu 7 Ngày'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Nút lấy dữ liệu 30 ngày
              ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _syncHistorical(30),
                icon: const Icon(Icons.calendar_month),
                label: const Text('Lấy Dữ Liệu 30 Ngày'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Loading indicator
              if (_isLoading)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('⏳ Đang xử lý...'),
                  ],
                )
              else if (_status.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _status.contains('✅')
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _status.contains('✅')
                          ? Colors.green.shade900
                          : Colors.red.shade900,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _syncToday() async {
    await _performSync(() => _syncService.syncTodayData(_getUserId()));
  }

  Future<void> _syncHistorical(int days) async {
    await _performSync(() => _syncService.syncHistoricalData(_getUserId(), days));
  }

  Future<void> _performSync(Future<int> Function() syncFn) async {
    setState(() {
      _isLoading = true;
      _status = '';
    });

    try {
      final count = await syncFn();
      setState(() {
        _status = '✅ Đã lưu $count dữ liệu thành công!';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Lỗi: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getUserId() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Vui lòng đăng nhập')),
      );
      throw Exception('User not authenticated');
    }
    return user.id;
  }
}
```

---

### ✅ Bước 7: Cập Nhật Navigation

**File:** `lib/main.dart` hoặc `lib/app.dart`

Thêm route để HealthScreen có thể được access:

```dart
routes: {
  '/health': (context) => const HealthScreen(),
  // ... các routes khác
},
```

Hoặc nếu dùng GoRouter:

```dart
GoRoute(
  path: '/health',
  builder: (context, state) => const HealthScreen(),
),
```

---

### ✅ Bước 8: Test Trên Thiết Bị

**Chuẩn bị:**

1. **Kết nối điện thoại Android vào máy tính**

2. **Bật Developer Mode:**
   - Settings → About phone
   - Tap "Build Number" 7 lần
   - Quay lại Settings → Developer Options
   - Bật "USB Debugging"

3. **Chạy app:**
   ```bash
   flutter run
   ```

4. **Test Google Fit:**
   - Mở app MediMinder
   - Vào Health Screen
   - Click "Đồng Bộ Hôm Nay"
   - Nó sẽ hiện popup xin quyền
   - Chọn "Allow"
   - ✅ Done!

---

## 🎯 Flow Thực Tế

```
┌─────────────────────────────────────────┐
│   User Mở Health Screen                 │
└────────────────────┬────────────────────┘
                     │
        ┌────────────▼────────────┐
        │  Click "Đồng Bộ"       │
        └────────────┬────────────┘
                     │
        ┌────────────▼─────────────────┐
        │ GoogleFitSyncService.sync()  │
        └────────────┬─────────────────┘
                     │
        ┌────────────▼──────────────────┐
        │ Health.requestAuthorization() │
        │ (Popup xin quyền)             │
        └────────────┬──────────────────┘
                     │
        ┌────────────▼──────────────────┐
        │ User click "Allow"            │
        └────────────┬──────────────────┘
                     │
        ┌────────────▼──────────────────┐
        │ Health.getHealthDataFromTypes()
        │ (Kết nối Google Fit)          │
        │ (Lấy data từ smartwatch)      │
        └────────────┬──────────────────┘
                     │
        ┌────────────▼──────────────────┐
        │ Loop qua data:                │
        │ - Parse từng dataPoint       │
        │ - Map sang metricType        │
        │ - Save vào Supabase          │
        └────────────┬──────────────────┘
                     │
        ┌────────────▼──────────────────┐
        │ UI: "✅ Đã lưu 42 dữ liệu"  │
        └────────────────────────────────┘
```

---

## ✅ Checklist

- [ ] Cài Google Fit trên điện thoại test
- [ ] Chạy `flutter pub add health`
- [ ] Cập nhật `build.gradle.kts`
- [ ] Cập nhật `AndroidManifest.xml`
- [ ] Tạo `google_fit_sync_service.dart`
- [ ] Tạo `health_screen.dart`
- [ ] Cập nhật navigation
- [ ] Kết nối điện thoại & test
- [ ] ✅ Done!

---

## 🐛 Troubleshooting

### ❌ "Permission denied"
- Kiểm tra AndroidManifest.xml có đầy đủ permissions
- Restart app
- Clear app data → Settings → Apps → MediMinder → Clear Storage

### ❌ "Google Fit not found"
- Cài Google Fit từ Play Store
- Đảm bảo tài khoản Google đã login

### ❌ "No data returned"
- Đảm bảo Google Fit có dữ liệu
- Mở Google Fit app → Kiểm tra có data không
- Thêm dữ liệu test thủ công trong Google Fit

### ❌ "compile error"
- Chạy: `flutter clean && flutter pub get`
- Rebuild Android: `flutter run --verbose`

---

## ✨ Tiếp Theo

Sau khi setup xong:
1. ✅ Test trên 5+ thiết bị khác nhau
2. ✅ Thêm UI để hiển thị dữ liệu
3. ✅ Thêm chart để visualize
4. ✅ Auto-sync mỗi giờ (dùng WorkManager)
5. ✅ Deploy lên production

---

**Xong! Bạn giờ có Google Fit integration hoàn chỉnh! 🚀**

