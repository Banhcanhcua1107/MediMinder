# 🚀 Quick Setup Guide - Health Metrics System

## Bước 1: Setup Database (2 phút)

### 1.1 Chạy Migration SQL
1. Mở Supabase Console → SQL Editor
2. Copy toàn bộ code từ `MIGRATION_ADD_HEALTH_METRICS.sql`
3. Paste vào SQL Editor
4. Click "RUN"

✅ Sẽ tạo 2 bảng:
- `user_health_profiles` - Thông tin sức khỏe hiện tại
- `health_metric_history` - Lịch sử các lần đo

---

## Bước 2: Code Integration (5 phút)

### 2.1 Cập nhật AddHealthProfileScreen
File: `lib/screens/add_health_profile_screen.dart`

Thay thế phần `_handleSave()`:

```dart
Future<void> _handleSave() async {
  final l10n = AppLocalizations.of(context)!;
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  
  try {
    final healthRepo = HealthMetricsRepository();
    
    // Lấy profile hiện tại hoặc tạo mới
    var profile = await healthRepo.getUserHealthProfile(userId);
    
    if (profile == null) {
      // Tạo profile mới
      profile = await healthRepo.createHealthProfile(
        userId,
        bmi: double.tryParse(_bmiController.text),
        bloodPressureSystolic: int.tryParse(_bloodPressureController.text.split('/')[0]),
        bloodPressureDiastolic: int.tryParse(_bloodPressureController.text.split('/').last),
        heartRate: int.tryParse(_heartRateController.text),
        glucoseLevel: double.tryParse(_glucoseController.text),
        cholesterolLevel: double.tryParse(_cholesterolController.text),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
    } else {
      // Update profile
      profile = await healthRepo.updateHealthProfile(
        userId,
        bmi: double.tryParse(_bmiController.text),
        bloodPressureSystolic: int.tryParse(_bloodPressureController.text.split('/')[0]),
        bloodPressureDiastolic: int.tryParse(_bloodPressureController.text.split('/').last),
        heartRate: int.tryParse(_heartRateController.text),
        glucoseLevel: double.tryParse(_glucoseController.text),
        cholesterolLevel: double.tryParse(_cholesterolController.text),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
    }
    
    // Thêm vào lịch sử
    await healthRepo.addHealthMetric(
      userId: userId,
      metricType: 'bmi',
      valueNumeric: double.parse(_bmiController.text),
      unit: 'kg/m²',
      source: 'manual',
    );
    
    showCustomToast(
      context,
      message: l10n.savedSuccessfully,
      subtitle: l10n.healthMetricsUpdated,
      isSuccess: true,
      duration: const Duration(seconds: 2),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HealthScreen()),
        );
      }
    });
  } catch (e) {
    showCustomToast(
      context,
      message: 'Lỗi',
      subtitle: e.toString(),
      isSuccess: false,
    );
  }
}
```

### 2.2 Import cần thiết
Thêm vào đầu file `add_health_profile_screen.dart`:

```dart
import '../repositories/health_metrics_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
```

---

## Bước 3: Test (5 phút)

### 3.1 Test Empty State
1. Xóa tất cả records từ `user_health_profiles` table
2. Chạy app → Vào Health Screen
3. Nên thấy màn hình trống với nút "Nhập thông tin"

### 3.2 Test Manual Entry
1. Click "Nhập thông tin"
2. Nhập: BMI=21.5, BP=120/80, HR=72
3. Click Save
4. Nên quay lại Health Screen và thấy dữ liệu

### 3.3 Test Persistence
1. Đóng và mở lại app
2. Health Screen vẫn hiển thị dữ liệu
3. ✅ Data được lưu trong Supabase

---

## Bước 4: Mi Fitness Integration (Future)

### Khi sẵn sàng:

1. **Register Xiaomi Developer App**
   - https://dev.mi.com
   - Lấy Client ID & Secret

2. **Implement OAuth**
   ```dart
   final service = MiFitnessIntegrationService();
   final authCode = await service.initiateXiaomiAuth();
   ```

3. **Sync Data**
   ```dart
   await service.syncDailyHealthData(
     userId: userId,
     accessToken: accessToken,
     date: DateTime.now(),
   );
   ```

---

## 📊 Database Schema Summary

### user_health_profiles
```
id (UUID)
user_id (UUID)
bmi (DECIMAL)
blood_pressure_systolic (SMALLINT)
blood_pressure_diastolic (SMALLINT)
heart_rate (SMALLINT)
glucose_level (DECIMAL)
cholesterol_level (DECIMAL)
notes (TEXT)
last_updated_at (TIMESTAMP)
```

### health_metric_history
```
id (UUID)
user_id (UUID)
metric_type (VARCHAR) - 'bmi', 'blood_pressure', 'heart_rate', 'glucose', 'cholesterol'
value_numeric (DECIMAL)
value_secondary (SMALLINT) - Cho blood_pressure diastolic
unit (VARCHAR)
source (VARCHAR) - 'manual', 'mi_fitness', 'redmi_watch'
notes (TEXT)
measured_at (TIMESTAMP)
```

---

## 🔐 RLS Policies (Tự động)

✅ Tất cả tables đã có Row-Level Security:
- Users chỉ see data của mình
- Không thể access data của người khác
- Check tại database level

---

## ⚠️ Common Issues & Solutions

### Issue: "Undefined name 'HealthMetricsRepository'"
**Solution:** Add import:
```dart
import '../repositories/health_metrics_repository.dart';
```

### Issue: "user_health_profiles table not found"
**Solution:** Chạy SQL migration script trước

### Issue: "RLS policy violation"
**Solution:** 
- Check user ID correct
- Ensure auth.uid() matches user_id
- Check RLS policies enabled

### Issue: Data không lưu
**Solution:**
- Check connection string
- Check Supabase credentials
- Check network connectivity

---

## 📱 File Structure

```
lib/
├── models/
│   └── health_metric.dart          ← NEW
├── repositories/
│   └── health_metrics_repository.dart  ← NEW
├── screens/
│   ├── health_screen.dart          ← UPDATED
│   └── add_health_profile_screen.dart  ← TO UPDATE
└── services/
    └── mi_fitness_integration_service.dart  ← NEW
```

---

## ✅ Checklist

- [ ] Chạy SQL migration
- [ ] Import HealthMetricsRepository trong AddHealthProfileScreen
- [ ] Update _handleSave() method
- [ ] Test empty state
- [ ] Test manual entry
- [ ] Test persistence (close/reopen app)
- [ ] Đọc HEALTH_METRICS_IMPLEMENTATION.md để understand architecture

---

## 🎯 Next Priority

1. ✅ Database schema - DONE
2. ✅ Models & Repository - DONE
3. ✅ Health Screen UI - DONE
4. ⏳ **Update AddHealthProfileScreen** - IN PROGRESS
5. ⏳ Implement Mi Fitness OAuth - TODO
6. ⏳ Mi Fitness API integration - TODO

---

## 📞 Need Help?

Refer to files:
- `HEALTH_METRICS_IMPLEMENTATION.md` - Full documentation
- `MIGRATION_ADD_HEALTH_METRICS.sql` - Database schema
- `lib/repositories/health_metrics_repository.dart` - API reference

**Last Updated:** 2025-11-21
