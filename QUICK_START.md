# 🚀 Quick Start - Setup 2 trang Thuốc trong 5 phút

## ✅ Checklist

- [x] Models tạo (`user_medicine.dart`)
- [x] Repository tạo (`medicine_repository.dart`)
- [x] medicine_list_screen.dart cập nhật
- [x] add_med_screen.dart cập nhật
- [x] SQL schema tạo (`new_medicine_schema.sql`)

---

## 🔧 Cài đặt (5 bước)

### **Bước 1: Chạy SQL** (1 phút)
```
1. Mở: https://supabase.com → Dashboard → SQL Editor
2. Copy toàn bộ nội dung từ file: new_medicine_schema.sql
3. Paste vào SQL Editor
4. Click nút RUN
5. Chờ hoàn thành (xanh lá)
```

✅ **Đã tạo 4 bảng:**
- user_medicines
- medicine_schedules
- medicine_schedule_times
- medicine_intakes

---

### **Bước 2: Kiểm tra imports** (1 phút)
Các file đã có sẵn:
```
lib/
  ├─ models/
  │  └─ user_medicine.dart ✅ (NEW)
  ├─ repositories/
  │  └─ medicine_repository.dart ✅ (NEW)
  └─ screens/
     ├─ medicine_list_screen.dart ✅ (UPDATED)
     └─ add_med_screen.dart ✅ (UPDATED)
```

Verify imports:
```dart
// medicine_list_screen.dart
import '../models/user_medicine.dart';
import '../repositories/medicine_repository.dart';

// add_med_screen.dart
import '../models/user_medicine.dart';
import '../repositories/medicine_repository.dart';
```

---

### **Bước 3: Build & Test** (3 phút)
```bash
cd D:\LapTrinhUngDungDT\MediMinder_DA\mediminder

# Clean & get deps
flutter clean
flutter pub get

# Run
flutter run
```

---

### **Bước 4: Test Features**

**Thêm thuốc mới:**
1. Tap nút `+` trên medicine_list_screen
2. Điền:
   - Tên: "Paracetamol"
   - Loại: "Viên nén"
   - Liều lượng: "500mg"
   - Số viên/lần: "1"
   - Ngày bắt đầu: Today
   - Ngày kết thúc: +30 days
   - Tần suất: "Hàng ngày"
   - Thời gian: "08:00", "20:00"
3. Tap "Lưu"

**Xem danh sách:**
- Quay về medicine_list_screen
- Xem thuốc sorted by next time
- Hiển thị "Trong X giờ"

**Edit thuốc:**
- Tap vào medicine card
- Sửa thông tin
- Tap "Cập nhật"

---

## 📚 File Reference

### **Models** (`lib/models/user_medicine.dart`)
```dart
class UserMedicine {
  String id, userId, name, dosageStrength, dosageForm;
  int quantityPerDose;
  DateTime startDate, updatedAt;
  DateTime? endDate;
  String? reasonForUse, notes;
  bool isActive;
  
  // Helper methods:
  isValidToday()           // Hợp lệ hôm nay?
  getNextIntakeTime()      // TimeOfDay sắp tới
  getMinutesUntilNextIntake() // int phút
  getTimeUntilNextIntakeText() // "Trong 2 giờ"
}

class MedicineSchedule {
  String frequencyType;    // "daily", "alternate_days", "custom"
  int? customIntervalDays;
  String? daysOfWeek;      // Bitmap "1111100"
  
  getFrequencyText()       // "Hàng ngày"
}

class MedicineScheduleTime {
  TimeOfDay timeOfDay;     // 08:00
  int orderIndex;          // 0, 1, 2...
  
  getTimeText()            // "08:00"
}

class MedicineIntake {
  DateTime scheduledDate, scheduledTime;
  DateTime? takenAt;
  String status;           // "pending", "taken", "skipped", "missed"
  
  getStatusText()          // "Đã uống"
  getStatusColor()         // Color based on status
}
```

### **Repository** (`lib/repositories/medicine_repository.dart`)
```dart
class MedicineRepository {
  // GET
  getUserMedicines(userId)
  getTodayMedicines(userId)       // Sorted by next time ⭐
  getMedicineIntakes(userId)
  
  // CREATE
  createMedicine(...)
  createSchedule(...)
  createScheduleTime(...)
  createMedicineIntake(...)
  
  // UPDATE
  updateMedicine(...)
  updateSchedule(...)
  updateMedicineIntakeStatus(...)
  
  // DELETE
  deleteMedicine(...)             // Soft delete (is_active=false)
  deleteScheduleTime(...)
}
```

### **Screens**

**medicine_list_screen.dart:**
- `_medicineRepository` - Instance của repo
- `_loadMedicines()` - Fetch from Supabase
- `_buildMedicineCard(medicine)` - Render card
- Tap card → Edit
- Tap + → Add new

**add_med_screen.dart:**
- `medicineId` - null=create, else=edit
- `_loadMedicineData()` - Load if edit mode
- `_selectStartDate()`, `_selectEndDate()` - Date pickers
- `_selectTime(index)` - Time picker
- `_addReminder()`, `_deleteReminder(index)` - Manage times
- `_handleSave()` - Save to Supabase

---

## 🗄️ SQL Tables

### user_medicines
```
id, user_id, name, dosage_strength, dosage_form, quantity_per_dose
start_date, end_date, reason_for_use, notes, is_active
```

### medicine_schedules
```
id, user_medicine_id, frequency_type
custom_interval_days, days_of_week
```

### medicine_schedule_times
```
id, medicine_schedule_id, time_of_day, order_index
```

### medicine_intakes (Optional - tracking)
```
id, user_id, user_medicine_id, medicine_schedule_time_id
medicine_name, dosage_strength, quantity_per_dose
scheduled_date, scheduled_time, taken_at, status, notes
```

---

## 🔐 Security

- ✅ RLS Policies trên tất cả bảng
- ✅ Users chỉ access data của chính họ
- ✅ Tự động check auth.uid()

---

## ⚠️ Troubleshooting

| Issue | Fix |
|-------|-----|
| "User not authenticated" | Đăng nhập via Auth |
| SQL error | Kiểm tra SQL syntax, run lại |
| Empty list | Check RLS policies, user_id match |
| No data saves | Verify user_medicines table có record |
| Time not sorted | `getTodayMedicines` auto sort, nếu không check `order_index` |

---

## 🎯 Tiếp theo (Optional)

1. **Notifications**: Local push for medicine time
2. **History**: View all intakes (today/week/month)
3. **Analytics**: Chart adherence rate
4. **Medicine DB**: Catalog of common medicines
5. **Custom Frequency**: UI for days_of_week picker

---

## 📞 File Summary

| File | Purpose | Status |
|------|---------|--------|
| `new_medicine_schema.sql` | SQL tables | ✅ Ready |
| `user_medicine.dart` | Models | ✅ Done |
| `medicine_repository.dart` | CRUD | ✅ Done |
| `medicine_list_screen.dart` | List UI | ✅ Updated |
| `add_med_screen.dart` | Add/Edit UI | ✅ Updated |
| `MEDICINE_SETUP.md` | Detailed guide | ✅ Guide |
| `SQL_SCHEMA_DETAILS.md` | SQL reference | ✅ Reference |
| `QUICK_START.md` | This file | ✅ Quick start |

---

🎉 **Ready to go! Start with Bước 1 (Run SQL) above.**
