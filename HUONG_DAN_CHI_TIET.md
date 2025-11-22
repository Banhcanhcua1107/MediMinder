# 📋 HƯỚNG DẪN CHI TIẾT - Hệ Thống Theo Dõi Chỉ Số Sức Khỏe

**Ngày cập nhật:** 21 tháng 11, 2025
**Phiên bản:** 1.0
**Trạng thái:** Sẵn sàng triển khai

---

## 📚 Mục Lục

1. [Giới Thiệu Hệ Thống](#1-giới-thiệu-hệ-thống)
2. [Cách Cài Đặt Cơ Sở Dữ Liệu](#2-cách-cài-đặt-cơ-sở-dữ-liệu)
3. [Cấu Trúc Tệp Và Folder](#3-cấu-trúc-tệp-và-folder)
4. [Hướng Dẫn Tích Hợp Mã](#4-hướng-dẫn-tích-hợp-mã)
5. [Cách Sử Dụng Repository](#5-cách-sử-dụng-repository)
6. [Hướng Dẫn Giao Diện Người Dùng](#6-hướng-dẫn-giao-diện-người-dùng)
7. [Tích Hợp Redmi Watch](#7-tích-hợp-redmi-watch)
8. [Kiểm Tra Và Test](#8-kiểm-tra-và-test)
9. [Khắc Phục Sự Cố](#9-khắc-phục-sự-cố)
10. [Câu Hỏi Thường Gặp](#10-câu-hỏi-thường-gặp)

---

## 1. Giới Thiệu Hệ Thống

### Mục Đích
Hệ thống theo dõi chỉ số sức khỏe cho phép người dùng:
- ✅ **Nhập thủ công** chỉ số sức khỏe (BMI, huyết áp, nhịp tim, v.v.)
- ✅ **Đồng bộ tự động** dữ liệu từ Redmi Watch / Mi Fitness
- ✅ **Xem tiến độ** theo ngày, tuần, tháng
- ✅ **Lưu trữ lịch sử** tất cả các chỉ số đo được

### Các Chỉ Số Được Hỗ Trợ

| Chỉ Số | Viết Tắt | Đơn Vị | Phạm Vi Bình Thường |
|--------|----------|--------|------------------|
| **Chỉ Số Khối Cơ Thể** | BMI | kg/m² | 18.5 - 24.9 |
| **Huyết Áp** | BP | mmHg | 120/80 |
| **Nhịp Tim** | HR | bpm | 60 - 100 |
| **Đường Huyết** | Glucose | mg/dL | 70 - 100 (khi đói) |
| **Cholesterol** | Chol | mg/dL | < 200 |

### Kiến Trúc Hệ Thống

```
┌─────────────────────────────────────────────────────────┐
│                   Flutter UI Layer                      │
│  (HealthScreen, AddHealthProfileScreen, Charts)        │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│            Repository Layer (Data Access)              │
│  (HealthMetricsRepository - 15+ methods)               │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│         Service Layer (Business Logic)                 │
│  (MiFitnessIntegrationService for Redmi Watch)        │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│      Supabase PostgreSQL (Backend Database)            │
│  (user_health_profiles, health_metric_history)        │
└─────────────────────────────────────────────────────────┘
```

---

## 2. Cách Cài Đặt Cơ Sở Dữ Liệu

### 📌 Bước 1: Mở Supabase Console

1. Truy cập: [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Đăng nhập với tài khoản của bạn
3. Chọn project **MediMinder**

### 📌 Bước 2: Chạy Migration SQL

1. **Mở SQL Editor:**
   - Click vào **"SQL Editor"** ở sidebar bên trái
   - Click **"New Query"**

2. **Copy toàn bộ code từ file:**
   ```
   MIGRATION_ADD_HEALTH_METRICS.sql
   ```

3. **Paste vào SQL Editor** trong Supabase

4. **Nhấp "RUN"** để chạy

📸 **Kết quả dự kiến:**
```
✓ Tables created successfully
✓ Indexes created
✓ RLS policies enabled
✓ Triggers created
```

### 📌 Bước 3: Xác Minh Cơ Sở Dữ Liệu

Sau khi chạy xong, kiểm tra:

1. **Bảng được tạo:**
   - Click **"Table Editor"** 
   - Kiểm tra có 2 bảng:
     - `user_health_profiles` 
     - `health_metric_history`

2. **RLS Policies:**
   - Click vào bảng `user_health_profiles`
   - Click **"Authentication"** → **"Policies"**
   - Kiểm tra có 4 policies:
     - `SELECT - Users can view own profile`
     - `INSERT - Users can create own profile`
     - `UPDATE - Users can update own profile`
     - `DELETE - Users can delete own profile`

3. **Indexes được tạo:**
   - Click vào bảng `health_metric_history`
   - Scroll xuống **"Indexes"**
   - Kiểm tra 4 indexes tồn tại

**✅ Nếu mọi thứ OK → Tiếp tục bước 3**

---

## 3. Cấu Trúc Tệp Và Folder

### Danh Sách Tệp Được Tạo

```
lib/
├── models/
│   └── health_metric.dart              # ✅ HealthMetric & HealthProfile classes
│
├── repositories/
│   └── health_metrics_repository.dart  # ✅ Data access layer (15+ methods)
│
├── services/
│   └── mi_fitness_integration_service.dart  # ✅ Redmi Watch integration
│
└── screens/
    └── health_screen.dart              # ✅ Main UI (CẦN TẠO LẠI)

Tệp Migration:
└── MIGRATION_ADD_HEALTH_METRICS.sql    # ✅ Database schema

Tệp Tài Liệu:
├── HEALTH_METRICS_IMPLEMENTATION.md
├── HEALTH_SETUP_QUICK_GUIDE.md
├── HEALTH_SYSTEM_SUMMARY.md
├── ARCHITECTURE_DIAGRAMS.md
└── HUONG_DAN_CHI_TIET.md (file này)
```

### Tệp Nào Đã Được Xóa
- ❌ `lib/screens/health_screen.dart` (bị xóa, cần tạo lại)

### Tệp Nào Cần Cập Nhật
- ⚠️ `lib/screens/add_health_screen.dart` (cần thêm tích hợp repository)

---

## 4. Hướng Dẫn Tích Hợp Mã

### 📌 Bước 1: Tạo Health Screen Mới

File: `lib/screens/health_screen.dart`

Tạo tệp mới với nội dung:

```dart
import 'package:flutter/material.dart';
import 'package:mediminder/models/health_metric.dart';
import 'package:mediminder/repositories/health_metrics_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({Key? key}) : super(key: key);

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  late HealthMetricsRepository _repository;
  HealthProfile? _healthProfile;
  List<HealthMetric> _weeklyMetrics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = HealthMetricsRepository();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final profile = await _repository.getUserHealthProfile(user.id);
      final weeklyMetrics = await _repository.getWeeklyMetrics(user.id);

      setState(() {
        _healthProfile = profile;
        _weeklyMetrics = weeklyMetrics;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_healthProfile?.hasData != true) {
      return _buildEmptyState();
    }

    return _buildContent();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.health_and_safety, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Không có dữ liệu sức khỏe',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy thêm chỉ số sức khỏe của bạn để bắt đầu',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/add_health');
            },
            icon: const Icon(Icons.add),
            label: const Text('Nhập Chỉ Số Sức Khỏe'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Tích hợp Redmi Watch
            },
            icon: const Icon(Icons.watch_later_outlined),
            label: const Text('Đồng Bộ từ Redmi Watch'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            if (_healthProfile?.bmi != null) _buildBMICard(),
            const SizedBox(height: 16),
            if (_healthProfile?.bloodPressureSystolic != null ||
                _healthProfile?.heartRate != null)
              _buildVitalsGrid(),
            const SizedBox(height: 16),
            if (_weeklyMetrics.isNotEmpty) _buildWeeklyProgressCard(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chỉ Số Sức Khỏe',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'Cập nhật: ${DateFormat('HH:mm, dd/MM').format(DateTime.now())}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadData,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context).pushNamed('/add_health');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBMICard() {
    final bmi = _healthProfile!.bmi!;
    final normalizedValue = (bmi / 40 * 100).clamp(0.0, 100.0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chỉ Số Khối Cơ Thể (BMI)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${bmi.toStringAsFixed(1)} kg/m²',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: normalizedValue / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getBMIColor(bmi),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getBMIStatus(bmi),
              style: TextStyle(
                fontSize: 12,
                color: _getBMIColor(bmi),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          if (_healthProfile?.bloodPressureSystolic != null)
            _buildVitalCard(
              title: 'Huyết Áp',
              value:
                  '${_healthProfile!.bloodPressureSystolic}/${_healthProfile!.bloodPressureDiastolic}',
              unit: 'mmHg',
              icon: Icons.favorite,
            ),
          if (_healthProfile?.heartRate != null)
            _buildVitalCard(
              title: 'Nhịp Tim',
              value: '${_healthProfile!.heartRate}',
              unit: 'bpm',
              icon: Icons.favorite,
            ),
          if (_healthProfile?.glucoseLevel != null)
            _buildVitalCard(
              title: 'Đường Huyết',
              value: '${_healthProfile!.glucoseLevel}',
              unit: 'mg/dL',
              icon: Icons.bloodtype,
            ),
          if (_healthProfile?.cholesterolLevel != null)
            _buildVitalCard(
              title: 'Cholesterol',
              value: '${_healthProfile!.cholesterolLevel}',
              unit: 'mg/dL',
              icon: Icons.trending_up,
            ),
        ],
      ),
    );
  }

  Widget _buildVitalCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Text(
              unit,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressCard() {
    // Group by date
    final Map<String, List<HealthMetric>> groupedByDate = {};
    for (final metric in _weeklyMetrics) {
      final dateKey = DateFormat('dd/MM').format(metric.measuredAt!);
      groupedByDate.putIfAbsent(dateKey, () => []).add(metric);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Tiến Độ Tuần',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: groupedByDate.length,
            itemBuilder: (context, index) {
              final entries = groupedByDate.entries.toList();
              final dateKey = entries[index].key;
              final metrics = entries[index].value;

              final avgValue = metrics
                      .map((m) => m.valueNumeric ?? 0)
                      .reduce((a, b) => a + b) /
                  metrics.length;
              final normalizedHeight = (avgValue / 100 * 100).clamp(0.0, 100.0);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: 30,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: normalizedHeight / 100 * 100,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateKey,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  String _getBMIStatus(double bmi) {
    if (bmi < 18.5) return 'Thiếu cân';
    if (bmi < 25) return 'Bình thường';
    if (bmi < 30) return 'Thừa cân';
    return 'Béo phì';
  }
}
```

### 📌 Bước 2: Cập Nhật AddHealthProfileScreen

File: `lib/screens/add_health_screen.dart`

Tìm phương thức `_handleSave()` và thay thế:

**Cũ:**
```dart
void _handleSave() {
  // TODO: Implement save
}
```

**Mới:**
```dart
void _handleSave() async {
  try {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập')),
      );
      return;
    }

    final repository = HealthMetricsRepository();

    // Create or update profile
    await repository.createHealthProfile(
      userId: user.id,
      bmi: _bmiController.text.isEmpty ? null : double.parse(_bmiController.text),
      bloodPressureSystolic: _systolicController.text.isEmpty 
          ? null 
          : int.parse(_systolicController.text),
      bloodPressureDiastolic: _diastolicController.text.isEmpty 
          ? null 
          : int.parse(_diastolicController.text),
      heartRate: _heartRateController.text.isEmpty 
          ? null 
          : int.parse(_heartRateController.text),
      glucoseLevel: _glucoseController.text.isEmpty 
          ? null 
          : double.parse(_glucoseController.text),
      cholesterolLevel: _cholesterolController.text.isEmpty 
          ? null 
          : double.parse(_cholesterolController.text),
      notes: _notesController.text,
    );

    // Add to metric history
    if (_bmiController.text.isNotEmpty) {
      await repository.addHealthMetric(
        userId: user.id,
        metricType: 'bmi',
        valueNumeric: double.parse(_bmiController.text),
        unit: 'kg/m²',
        source: 'manual',
      );
    }

    // Similar for other metrics...

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✓ Đã lưu chỉ số sức khỏe')),
    );

    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lỗi: $e')),
    );
  }
}
```

### 📌 Bước 3: Cập Nhật pubspec.yaml

Đảm bảo các dependencies sau đã được thêm:

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^1.10.0
  intl: ^0.19.0
```

Chạy:
```bash
flutter pub get
```

---

## 5. Cách Sử Dụng Repository

### Khởi Tạo Repository

```dart
final repository = HealthMetricsRepository();
```

### Phương Thức Chính

#### 1️⃣ **Tạo/Cập Nhật Hồ Sơ Sức Khỏe**

```dart
await repository.createHealthProfile(
  userId: 'user-id-here',
  bmi: 24.5,
  bloodPressureSystolic: 120,
  bloodPressureDiastolic: 80,
  heartRate: 72,
  glucoseLevel: 95.0,
  cholesterolLevel: 190.0,
  notes: 'Good health status',
);
```

#### 2️⃣ **Lấy Hồ Sơ Hiện Tại**

```dart
final profile = await repository.getUserHealthProfile('user-id');
if (profile != null && profile.hasData) {
  print('BMI: ${profile.bmi}');
  print('Heart Rate: ${profile.heartRate}');
}
```

#### 3️⃣ **Thêm Chỉ Số Mới**

```dart
await repository.addHealthMetric(
  userId: 'user-id',
  metricType: 'blood_pressure', // bmi, blood_pressure, heart_rate, glucose, cholesterol
  valueNumeric: 120.0,
  valueSecondary: 80, // Cho huyết áp
  unit: 'mmHg',
  source: 'manual', // manual, mi_fitness, redmi_watch
);
```

#### 4️⃣ **Lấy Chỉ Số Trong 7 Ngày**

```dart
final weeklyMetrics = await repository.getWeeklyMetrics('user-id');
// Trả về list các chỉ số từ 7 ngày trước
```

#### 5️⃣ **Lấy Chỉ Số Trong 30 Ngày**

```dart
final monthlyMetrics = await repository.getMonthlyMetrics('user-id');
```

#### 6️⃣ **Lấy Chỉ Số Hôm Nay**

```dart
final todayMetrics = await repository.getTodayMetrics('user-id');
```

#### 7️⃣ **Lấy Chỉ Số Mới Nhất**

```dart
final latest = await repository.getLatestMetricsForAllTypes('user-id');
// Trả về map:
// {
//   'bmi': HealthMetric(...),
//   'blood_pressure': HealthMetric(...),
//   ...
// }
```

#### 8️⃣ **Tính Trung Bình/Min/Max**

```dart
final stats = await repository.getMetricAggregate(
  userId: 'user-id',
  metricType: 'heart_rate',
  fromDate: DateTime.now().subtract(Duration(days: 7)),
  toDate: DateTime.now(),
);

print('Average: ${stats['average']}');
print('Min: ${stats['min']}');
print('Max: ${stats['max']}');
print('Count: ${stats['count']}');
```

---

## 6. Hướng Dẫn Giao Diện Người Dùng

### Màn Hình Health (Trống)

```
┌─────────────────────────────────┐
│  [=]        Chỉ Số Sức Khỏe   [≡] │
├─────────────────────────────────┤
│                                 │
│         ❤️ (Icon lớn)            │
│                                 │
│   Không có dữ liệu sức khỏe      │
│                                 │
│  Hãy thêm chỉ số sức khỏe       │
│  của bạn để bắt đầu             │
│                                 │
│  ┌─────────────────────────────┐ │
│  │ [+] Nhập Chỉ Số Sức Khỏe   │ │
│  └─────────────────────────────┘ │
│                                 │
│  ┌─────────────────────────────┐ │
│  │ [⌚] Đồng Bộ từ Redmi Watch │ │
│  └─────────────────────────────┘ │
│                                 │
└─────────────────────────────────┘
```

### Màn Hình Health (Có Dữ Liệu)

```
┌──────────────────────────────────┐
│  Chỉ Số Sức Khỏe      [🔄]  [+]  │
│  Cập nhật: 14:30, 21/11         │
├──────────────────────────────────┤
│                                  │
│  ┌──────────────────────────────┐│
│  │ Chỉ Số Khối Cơ Thể (BMI)    ││
│  │                  24.5 kg/m² ││
│  │ ████████░░░░░░░░░░░░░░░░░░ ││
│  │ Bình thường                  ││
│  └──────────────────────────────┘│
│                                  │
│  ┌────────────────┐ ┌────────────┐│
│  │ Huyết Áp      │ │ Nhịp Tim   ││
│  │ 120/80 mmHg   │ │ 72 bpm    ││
│  │                │ │            ││
│  │ ❤️ Bình thường │ │ ❤️ Bình   ││
│  │                │ │    thường  ││
│  └────────────────┘ └────────────┘│
│                                  │
│  ┌────────────────┐ ┌────────────┐│
│  │ Đường Huyết    │ │ Cholesterol││
│  │ 95 mg/dL       │ │ 190 mg/dL  ││
│  │                │ │            ││
│  │ 🩸 Bình thường  │ │ 📈 Bình   ││
│  │                │ │    thường  ││
│  └────────────────┘ └────────────┘│
│                                  │
│  Tiến Độ Tuần                    │
│  ██ ██ ██ ██ ██ ██ ██           │
│  21 22 23 24 25 26 27            │
│                                  │
└──────────────────────────────────┘
```

### Màn Hình Nhập Dữ Liệu (Add Health Screen)

```
┌──────────────────────────────────┐
│  Thêm Chỉ Số Sức Khỏe      [X]   │
├──────────────────────────────────┤
│                                  │
│  Chỉ Số Khối Cơ Thể (BMI)       │
│  ┌──────────────────────────────┐│
│  │ 24.5                         ││
│  └──────────────────────────────┘│
│                                  │
│  Huyết Áp (mmHg)                │
│  ┌──────────────┐ ┌──────────────┐│
│  │ 120 Hệ Thống │ │ 80 Tâm Trương││
│  └──────────────┘ └──────────────┘│
│                                  │
│  Nhịp Tim (bpm)                 │
│  ┌──────────────────────────────┐│
│  │ 72                           ││
│  └──────────────────────────────┘│
│                                  │
│  Đường Huyết (mg/dL)            │
│  ┌──────────────────────────────┐│
│  │ 95                           ││
│  └──────────────────────────────┘│
│                                  │
│  Cholesterol (mg/dL)            │
│  ┌──────────────────────────────┐│
│  │ 190                          ││
│  └──────────────────────────────┘│
│                                  │
│  Ghi Chú                         │
│  ┌──────────────────────────────┐│
│  │ Good health status           ││
│  └──────────────────────────────┘│
│                                  │
│  ┌──────────────────────────────┐│
│  │      [LƯU]              [HỦY]││
│  └──────────────────────────────┘│
│                                  │
└──────────────────────────────────┘
```

---

## 7. Tích Hợp Redmi Watch

### 📌 Chuẩn Bị

Để tích hợp Redmi Watch, bạn cần:

1. **Tài khoản Xiaomi Cloud:**
   - Truy cập: [https://account.xiaomi.com](https://account.xiaomi.com)
   - Đăng nhập hoặc tạo tài khoản

2. **Mi Fitness Developer Console:**
   - Truy cập: [https://dev.mi.com](https://dev.mi.com)
   - Đăng ký ứng dụng
   - Lấy `Client ID` và `Client Secret`

3. **OAuth Callback URL:**
   - Thiết lập: `https://yourdomain.com/auth/callback`

### 📌 Cấu Hình MiFitnessIntegrationService

File: `lib/services/mi_fitness_integration_service.dart`

```dart
class MiFitnessIntegrationService {
  // TODO: Thêm Client ID & Secret
  static const String MI_OAUTH_BASE_URL = 
    'https://account.xiaomi.com/oauth2/authorize';
  static const String MI_API_BASE_URL = 
    'https://api.mfit.xiaomi.com';
  
  // Lưu Client ID & Secret của bạn
  static const String CLIENT_ID = 'YOUR_CLIENT_ID_HERE';
  static const String CLIENT_SECRET = 'YOUR_CLIENT_SECRET_HERE';
}
```

### 📌 Cách Hoạt Động

```
1. Người dùng click "Đồng Bộ từ Redmi Watch"
   │
   ▼
2. Mở WebView để xác thực Xiaomi
   │
   ▼
3. Người dùng đăng nhập tài khoản Xiaomi
   │
   ▼
4. Cho phép ứng dụng truy cập dữ liệu sức khỏe
   │
   ▼
5. Nhận Access Token
   │
   ▼
6. Gọi Mi Fitness API để lấy dữ liệu:
   - Daily Steps
   - Heart Rate
   - Sleep Data
   │
   ▼
7. Chuyển đổi dữ liệu sang HealthMetric format
   │
   ▼
8. Lưu vào health_metric_history (source: 'mi_fitness')
   │
   ▼
9. Cập nhật user_health_profiles
   │
   ▼
10. Hiển thị dữ liệu trên HealthScreen
```

### 📌 Hướng Dẫn Triển Khai Tương Lai

**Giai Đoạn 1 (Tuần 1-2):**
- ✅ Setup Xiaomi Developer Account
- ✅ Lấy Client ID & Secret
- ✅ Thiết lập OAuth Callback URL

**Giai Đoạn 2 (Tuần 2-3):**
- 🔄 Triển khai OAuth Flow
- 🔄 Xây dựng WebView for Authentication
- 🔄 Token Storage & Refresh

**Giai Đoạn 3 (Tuần 3-4):**
- 🔄 Triển khai API Calls
- 🔄 Data Transformation
- 🔄 Save to Repository

**Giai Đoạn 4 (Tuần 4):**
- 🔄 Auto-Sync Scheduling
- 🔄 Background Tasks
- 🔄 Testing & QA

---

## 8. Kiểm Tra Và Test

### 📌 Bước 1: Kiểm Tra Database

Chạy các truy vấn này trong Supabase SQL Editor:

```sql
-- 1. Kiểm tra bảng user_health_profiles
SELECT * FROM user_health_profiles WHERE user_id = 'your-user-id';

-- 2. Kiểm tra bảng health_metric_history
SELECT * FROM health_metric_history 
WHERE user_id = 'your-user-id' 
ORDER BY measured_at DESC;

-- 3. Kiểm tra RLS policies
SELECT * FROM pg_policies 
WHERE tablename IN ('user_health_profiles', 'health_metric_history');

-- 4. Kiểm tra indexes
SELECT * FROM pg_indexes 
WHERE tablename IN ('user_health_profiles', 'health_metric_history');
```

### 📌 Bước 2: Unit Tests

Tạo file: `test/repositories/health_metrics_repository_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mediminder/models/health_metric.dart';
import 'package:mediminder/repositories/health_metrics_repository.dart';

void main() {
  group('HealthMetricsRepository', () {
    late HealthMetricsRepository repository;

    setUp(() {
      repository = HealthMetricsRepository();
    });

    test('HealthMetric fromJson works correctly', () {
      final json = {
        'id': 'test-id',
        'user_id': 'user-id',
        'metric_type': 'bmi',
        'value_numeric': 24.5,
        'unit': 'kg/m²',
        'source': 'manual',
        'measured_at': '2025-11-21T10:30:00Z',
      };

      final metric = HealthMetric.fromJson(json);
      
      expect(metric.id, 'test-id');
      expect(metric.metricType, 'bmi');
      expect(metric.valueNumeric, 24.5);
    });

    test('HealthProfile hasData returns true when bmi is set', () {
      final profile = HealthProfile(
        id: 'id',
        userId: 'user-id',
        bmi: 24.5,
        bloodPressureSystolic: null,
        bloodPressureDiastolic: null,
        heartRate: null,
        glucoseLevel: null,
        cholesterolLevel: null,
        notes: null,
        lastUpdatedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(profile.hasData, true);
    });
  });
}
```

Chạy tests:
```bash
flutter test test/repositories/health_metrics_repository_test.dart
```

### 📌 Bước 3: Integration Tests

Tạo file: `test/screens/health_screen_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediminder/screens/health_screen.dart';

void main() {
  group('HealthScreen', () {
    testWidgets('Shows empty state when no data', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HealthScreen(),
        ),
      );

      expect(find.text('Không có dữ liệu sức khỏe'), findsOneWidget);
      expect(find.byIcon(Icons.health_and_safety), findsOneWidget);
    });

    testWidgets('Shows loading spinner initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HealthScreen(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });
}
```

Chạy tests:
```bash
flutter test test/screens/health_screen_test.dart
```

### 📌 Bước 4: Manual Testing Checklist

- [ ] Ứng dụng khởi động không lỗi
- [ ] HealthScreen hiển thị trạng thái rỗng
- [ ] Click "Nhập Chỉ Số" → AddHealthScreen mở
- [ ] Nhập BMI = 24.5, lưu
- [ ] HealthScreen cập nhật và hiển thị BMI
- [ ] Chart hiển thị đúng
- [ ] Refresh button hoạt động
- [ ] Dữ liệu vẫn giữ nguyên sau khi đóng/mở app
- [ ] Thêm chỉ số mới mỗi ngày
- [ ] Chart cập nhật chính xác với dữ liệu mới

---

## 9. Khắc Phục Sự Cố

### ❌ Lỗi: "auth.currentUser is null"

**Nguyên nhân:** Người dùng chưa đăng nhập

**Cách sửa:**
```dart
if (Supabase.instance.client.auth.currentUser == null) {
  // Chuyển hướng sang trang đăng nhập
  Navigator.of(context).pushNamed('/login');
  return;
}
```

### ❌ Lỗi: "RLS policy violation"

**Nguyên nhân:** RLS policies chưa được bật

**Cách sửa:**
1. Mở Supabase Console
2. Table Editor → Chọn bảng
3. Authentication → Policies
4. Bật tất cả 4 policies

### ❌ Lỗi: "health_metric_history table not found"

**Nguyên nhân:** Migration SQL chưa chạy

**Cách sửa:**
1. Mở SQL Editor
2. Chạy lại MIGRATION_ADD_HEALTH_METRICS.sql
3. Xác minh bảng được tạo trong Table Editor

### ❌ Lỗi: "Chart not displaying correctly"

**Nguyên nhân:** Normalization value sai

**Cách sửa:**
Kiểm tra công thức:
```dart
final normalizedHeight = (avgValue / 100 * 100).clamp(0.0, 100.0);
// Đây chỉ là chia 100, sau đó nhân 100
// Nên chỉnh sửa thành:
final normalizedHeight = ((avgValue / MAX_VALUE) * 100).clamp(0.0, 100.0);
// Trong đó MAX_VALUE phụ thuộc vào metric type
```

### ❌ Lỗi: "NoSuchMethodError: value_numeric"

**Nguyên nhân:** Column name không đúng

**Cách sửa:**
Kiểm tra tên column trong SQL:
```sql
-- Xem các column trong health_metric_history
SELECT * FROM information_schema.columns 
WHERE table_name = 'health_metric_history';
```

---

## 10. Câu Hỏi Thường Gặp

### ❓ Q1: Làm cách nào để xóa dữ liệu cũ?

**Trả lời:**
```dart
// Xóa một metric cụ thể
await repository.deleteHealthMetric(metricId);

// Xóa tất cả dữ liệu của người dùng
await Supabase.instance.client
    .from('health_metric_history')
    .delete()
    .eq('user_id', userId);
```

### ❓ Q2: Tôi có thể tích hợp Fitbit hoặc Apple Health không?

**Trả lời:**
Có thể! Cấu trúc repository cho phép nhiều nguồn dữ liệu:
```dart
// Có thể là 'manual', 'mi_fitness', 'fitbit', 'apple_health', v.v.
await repository.addHealthMetric(
  userId: userId,
  source: 'fitbit', // hoặc 'apple_health'
  ...
);
```

### ❓ Q3: Làm sao để so sánh tiến độ?

**Trả lời:**
```dart
// Lấy dữ liệu tuần trước
final lastWeek = await repository.getMetricAggregate(
  userId: userId,
  metricType: 'heart_rate',
  fromDate: DateTime.now().subtract(Duration(days: 14)),
  toDate: DateTime.now().subtract(Duration(days: 7)),
);

// Lấy dữ liệu tuần này
final thisWeek = await repository.getMetricAggregate(
  userId: userId,
  metricType: 'heart_rate',
  fromDate: DateTime.now().subtract(Duration(days: 7)),
  toDate: DateTime.now(),
);

// So sánh
final difference = thisWeek['average']! - lastWeek['average']!;
```

### ❓ Q4: Tôi có thể xuất dữ liệu không?

**Trả lời:**
```dart
// Lấy tất cả dữ liệu
final allMetrics = await repository.getMonthlyMetrics(userId);

// Chuyển sang JSON
final jsonData = allMetrics.map((m) => m.toJson()).toList();

// Lưu hoặc chia sẻ
// Có thể lưu sang CSV, PDF, hoặc gửi qua email
```

### ❓ Q5: Tôi cần gì để triển khai lên production?

**Trả lời:**
1. ✅ Hoàn thành migration SQL
2. ✅ Kiểm tra tất cả RLS policies
3. ✅ Kiểm tra tất cả unit tests
4. ✅ Kiểm tra manual testing
5. ✅ Cấu hình OAuth cho Xiaomi (nếu cần)
6. ✅ Thiết lập monitoring & logging
7. ✅ Backup database

### ❓ Q6: Làm sao để reset/cleanup dữ liệu?

**Trả lời:**
```bash
# Xóa tất cả dữ liệu (cẩn thận!)
flutter pub run migrate_sql --down

# Hoặc chạy lại migration
flutter pub run migrate_sql --up
```

---

## 📞 Hỗ Trợ & Liên Lạc

Nếu gặp vấn đề:

1. **Kiểm tra tài liệu:**
   - HEALTH_METRICS_IMPLEMENTATION.md
   - HEALTH_SETUP_QUICK_GUIDE.md
   - ARCHITECTURE_DIAGRAMS.md

2. **Kiểm tra logs:**
   ```bash
   flutter logs
   ```

3. **Kiểm tra Supabase:**
   - Mở Supabase Console
   - Xem Logs → Query Logs
   - Kiểm tra errors

4. **Liên hệ:**
   - Repository: [GitHub Link]
   - Email: support@mediminder.com

---

## 🎯 Roadmap Tiếp Theo

### Tuần 1 (Hiện Tại)
- ✅ Database Schema
- ✅ Models & Repository
- ✅ HealthScreen UI
- ⏳ Integration Testing

### Tuần 2-3
- 🔄 Xiaomi OAuth Integration
- 🔄 Mi Fitness API Implementation
- 🔄 Auto-Sync Feature

### Tuần 4
- 🔄 Notification System
- 🔄 Data Export (CSV, PDF)
- 🔄 Advanced Analytics

### Tuần 5+
- 🔄 Apple Health Integration
- 🔄 Fitbit Integration
- 🔄 Machine Learning Predictions
- 🔄 Social Features (share, compare)

---

## 📄 Tài Liệu Liên Quan

- **MIGRATION_ADD_HEALTH_METRICS.sql** - Database schema
- **HEALTH_METRICS_IMPLEMENTATION.md** - Technical details
- **HEALTH_SETUP_QUICK_GUIDE.md** - Quick setup
- **ARCHITECTURE_DIAGRAMS.md** - System diagrams
- **HEALTH_SYSTEM_SUMMARY.md** - Project overview

---

**Phiên bản:** 1.0
**Cập nhật lần cuối:** 21 Tháng 11, 2025
**Trạng thái:** ✅ Sẵn sàng triển khai
