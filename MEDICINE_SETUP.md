# 🏥 MediMinder - Hướng dẫn thiết lập 2 trang Danh sách & Thêm Thuốc

## 📋 Tóm tắt thay đổi

Đã cập nhật hoàn toàn 2 trang **Danh sách thuốc** và **Thêm thuốc** để tích hợp với Supabase, với các tính năng:

✅ **Danh sách thuốc** (`medicine_list_screen.dart`):
- Fetch dữ liệu thực từ Supabase
- Sort thuốc theo giờ uống tiếp theo
- Hiển thị thời gian còn lại đến giờ uống kế tiếp
- Click để edit, nút + để thêm mới
- Loading state và error handling

✅ **Thêm/Chỉnh sửa thuốc** (`add_med_screen.dart`):
- Tạo thuốc mới hoặc edit thuốc hiện tại
- Chọn ngày bắt đầu, ngày kết thúc
- Tần suất: Hằng ngày / Cách ngày / Tuỳ chỉnh
- Thêm nhiều giờ uống (multiple times)
- Validate & save to Supabase

---

## 🗄️ SQL Schema (Phải thêm vào Supabase)

### Bước 1: Tạo bảng mới
Copy-paste nội dung file `new_medicine_schema.sql` vào **Supabase > SQL Editor** và run:

```sql
-- File: new_medicine_schema.sql
-- Chứa: user_medicines, medicine_schedules, medicine_schedule_times, medicine_intakes
```

**Các bảng được tạo:**

1. **user_medicines** - Thuốc của mỗi user
   - `id`: UUID
   - `user_id`: Liên kết đến user
   - `name`: Tên thuốc
   - `dosage_strength`: e.g., "500mg"
   - `dosage_form`: "tablet", "capsule", "liquid", "injection"
   - `quantity_per_dose`: Số viên/lần
   - `start_date`, `end_date`: Khoảng thời gian
   - `notes`: Ghi chú
   - `is_active`: TRUE/FALSE

2. **medicine_schedules** - Tần suất uống
   - `id`: UUID
   - `user_medicine_id`: Liên kết medicine
   - `frequency_type`: "daily", "alternate_days", "custom"
   - `custom_interval_days`: Cách X ngày (nếu custom)
   - `days_of_week`: Bitmap thứ (nếu custom)

3. **medicine_schedule_times** - Giờ uống trong ngày
   - `id`: UUID
   - `medicine_schedule_id`: Liên kết schedule
   - `time_of_day`: HH:MM (e.g., "08:00")
   - `order_index`: Thứ tự

4. **medicine_intakes** - Lịch sử uống (tuỳ chọn - để tracking)
   - `id`: UUID
   - `user_id`: User
   - `user_medicine_id`: Medicine
   - `medicine_name`, `dosage_strength`, `quantity_per_dose`: Thông tin
   - `scheduled_date`, `scheduled_time`: Dự định
   - `taken_at`: Thực tế (NULL nếu chưa uống)
   - `status`: "pending", "taken", "skipped", "missed"

---

## 📁 Dart Files (Đã tạo/Update)

### 1. Models: `lib/models/user_medicine.dart` ✅
Chứa 4 models:
- `UserMedicine` - Thông tin thuốc + helper methods
- `MedicineSchedule` - Tần suất uống
- `MedicineScheduleTime` - Giờ uống
- `MedicineIntake` - Lịch sử uống

**Helper methods:**
```dart
medicine.isValidToday()              // Kiểm tra có hợp lệ hôm nay?
medicine.getNextIntakeTime()         // Giờ uống tiếp theo (TimeOfDay)
medicine.getMinutesUntilNextIntake() // Số phút còn lại
medicine.getTimeUntilNextIntakeText() // Text "Trong X giờ"
```

### 2. Repository: `lib/repositories/medicine_repository.dart` ✅
CRUD operations:
```dart
// Get
getMedicines(userId)           // Tất cả thuốc
getTodayMedicines(userId)      // Thuốc hôm nay (sorted by time)
getMedicineIntakes(userId)     // Lịch sử uống

// Create
createMedicine(...)            // Tạo thuốc
createSchedule(...)            // Tạo schedule
createScheduleTime(...)        // Tạo giờ uống

// Update
updateMedicine(...)            // Cập nhật thuốc
updateSchedule(...)            // Cập nhật schedule
updateMedicineIntakeStatus(...) // Mark as taken/skipped

// Delete
deleteMedicine(...)            // Soft delete
deleteScheduleTime(...)        // Xóa giờ uống
```

### 3. Screens: `lib/screens/medicine_list_screen.dart` ✅
- Fetch từ repository
- Sort by next intake time
- Display: tên, liều lượng, giờ tiếp theo, thời gian còn lại
- Tap item → Edit
- Nút + → Add new
- Refresh sau khi thêm/sửa

### 4. Screens: `lib/screens/add_med_screen.dart` ✅
- Create mode: Tạo mới (medicineId = null)
- Edit mode: Chỉnh sửa (medicineId != null)
- Fields:
  - Tên thuốc
  - Loại thuốc (dropdown)
  - Liều lượng (e.g., 500mg)
  - Số viên/lần
  - Ngày bắt đầu (date picker)
  - Ngày kết thúc (date picker)
  - Tần suất (Hàng ngày / Cách ngày / Tuỳ chỉnh)
  - Giờ uống (multiple times, add/remove)
  - Ghi chú
- Validation & Save to Supabase

---

## 🔄 Luồng dữ liệu

### Tạo thuốc mới:
1. User nhấn nút + trên medicine_list_screen
2. Navigate tới AddMedScreen(medicineId: null)
3. User điền thông tin, nhấn "Lưu"
4. CreateMedicine → CreateSchedule → CreateScheduleTimes
5. Pop back, refresh list
6. New medicine appears sorted by next time

### Edit thuốc:
1. User tap vào medicine card
2. Navigate tới AddMedScreen(medicineId: "xxx")
3. Load existing data vào form
4. User edit, nhấn "Cập nhật"
5. UpdateMedicine → Delete old times → Create new times
6. Pop back, refresh list

### Danh sách hôm nay:
1. medicine_list_screen gọi `getTodayMedicines(userId)`
2. Repository fetch medicines với điều kiện:
   - is_active = true
   - start_date ≤ hôm nay
   - end_date IS NULL hoặc end_date ≥ hôm nay
3. Sort by next intake time
4. Display with helper text (e.g., "Trong 2 giờ", "Sắp tới")

---

## ⚙️ Cách sử dụng

### 1. Setup Supabase Database
```bash
# Mở Supabase > SQL Editor
# Copy nội dung từ: new_medicine_schema.sql
# Paste vào SQL Editor
# Click "RUN"
```

### 2. Import Files
Files đã được tạo:
- ✅ `lib/models/user_medicine.dart`
- ✅ `lib/repositories/medicine_repository.dart`
- ✅ `lib/screens/medicine_list_screen.dart` (updated)
- ✅ `lib/screens/add_med_screen.dart` (updated)

### 3. Test
```bash
# Chạy app
flutter run

# Đăng nhập
# Nhấn nút + để thêm thuốc
# Điền thông tin, lưu
# Xem danh sách thuốc được sort by time
```

---

## 📊 Data Format Examples

### Create Medicine:
```json
{
  "user_id": "uuid",
  "name": "Paracetamol",
  "dosage_strength": "500mg",
  "dosage_form": "tablet",
  "quantity_per_dose": 1,
  "start_date": "2024-11-18",
  "end_date": "2024-12-18",
  "reason_for_use": null,
  "notes": "Uống sau ăn"
}
```

### Schedule Times:
```json
[
  {"time_of_day": "08:00", "order_index": 0},
  {"time_of_day": "20:00", "order_index": 1}
]
```

### Medicine Intake (tracking):
```json
{
  "user_id": "uuid",
  "user_medicine_id": "uuid",
  "medicine_name": "Paracetamol",
  "scheduled_date": "2024-11-18",
  "scheduled_time": "08:00",
  "status": "pending"
}
```

---

## 🔐 Security (RLS Policies)

Tất cả bảng có Row Level Security:
- Users chỉ truy cập data của chính họ
- INSERT/UPDATE/DELETE chỉ cho user_id = auth.uid()

---

## 🚀 Next Steps (Tuỳ chọn)

1. **Tracking Intakes**: Hiển thị check-in theo từng lần uống
2. **Notifications**: Local push notifications cho giờ uống
3. **History**: Xem lịch sử uống hôm nay/tuần
4. **Medicine Catalog**: Database các loại thuốc phổ biến
5. **Reminders**: Nhắc trước giờ uống (15 phút, 30 phút, ...)

---

## 📝 Notes

- Time format: 24h (HH:MM)
- Date format: YYYY-MM-DD
- Frequency types: `daily`, `alternate_days`, `custom`
- Status: `pending`, `taken`, `skipped`, `missed`

---

## ❓ Troubleshooting

**Lỗi: "User not authenticated"**
- Kiểm tra user đã đăng nhập via Supabase Auth

**Lỗi: "Medicine not found"**
- Kiểm tra medicineId có tồn tại trong database

**Không load dữ liệu**
- Kiểm tra RLS policies
- Kiểm tra user_medicines có data không

---

## 📞 Support

File này hướng dẫn setup 2 trang Medicine List & Add Medicine.
Nếu có issue, kiểm tra:
1. SQL schema đã được run?
2. Supabase Auth setup đúng?
3. Repository imports đúng?
