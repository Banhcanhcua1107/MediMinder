# 📋 SQL Schema - Chi tiết tables cho Medicine Management

## 🎯 Mục đích
4 bảng này lưu trữ:
1. Danh sách thuốc của user (user_medicines)
2. Tần suất uống (medicine_schedules) 
3. Giờ uống trong ngày (medicine_schedule_times)
4. Lịch sử uống (medicine_intakes) - tracking thực tế

---

## 📊 Bảng 1: user_medicines (Danh sách thuốc)

```sql
CREATE TABLE user_medicines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  name VARCHAR(255) NOT NULL,                    -- "Paracetamol"
  dosage_strength VARCHAR(100),                 -- "500mg"
  dosage_form VARCHAR(50),                      -- "tablet", "capsule", "liquid", "injection"
  quantity_per_dose INTEGER,                    -- Số viên/lần (1, 2, 3...)
  
  start_date DATE NOT NULL,                     -- "2024-11-18"
  end_date DATE,                                -- NULL = indefinite
  
  reason_for_use VARCHAR(255),                  -- "Hạ sốt"
  notes TEXT,                                   -- "Uống sau ăn no"
  is_active BOOLEAN DEFAULT TRUE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

**Ví dụ:**
```
id: 550e8400-e29b-41d4-a716-446655440000
user_id: 123e4567-e89b-12d3-a456-426614174000
name: "Paracetamol"
dosage_strength: "500mg"
dosage_form: "tablet"
quantity_per_dose: 1
start_date: "2024-11-18"
end_date: "2024-12-18"
reason_for_use: "Hạ sốt"
notes: "Uống sau ăn no"
is_active: true
```

**Dùng cho:**
- Hiển thị danh sách thuốc
- Get thông tin cơ bản của 1 thuốc
- Filter thuốc còn active, trong khoảng ngày

---

## 📅 Bảng 2: medicine_schedules (Tần suất uống)

```sql
CREATE TABLE medicine_schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_medicine_id UUID NOT NULL REFERENCES user_medicines(id) ON DELETE CASCADE,
  
  frequency_type VARCHAR(50) NOT NULL,          -- "daily", "alternate_days", "custom"
  custom_interval_days INTEGER,                 -- NULL, hoặc số ngày (3, 7, ...)
  days_of_week VARCHAR(7),                      -- NULL, hoặc bitmap "1111100"
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

**Ví dụ:**

**Loại 1: Hàng ngày (daily)**
```
frequency_type: "daily"
custom_interval_days: NULL
days_of_week: NULL
```
→ Uống mỗi ngày

**Loại 2: Cách ngày (alternate_days)**
```
frequency_type: "alternate_days"
custom_interval_days: NULL
days_of_week: NULL
```
→ Uống ngày 1, bỏ ngày 2, ngày 3, ...

**Loại 3: Tuỳ chỉnh - Mỗi X ngày**
```
frequency_type: "custom"
custom_interval_days: 3
days_of_week: NULL
```
→ Uống cách 3 ngày

**Loại 4: Tuỳ chỉnh - Các thứ trong tuần**
```
frequency_type: "custom"
custom_interval_days: NULL
days_of_week: "1111100"
```
→ Thứ 2-6 (1=có, 0=không)
→ Bitmap: [Thứ 2, Thứ 3, Thứ 4, Thứ 5, Thứ 6, Thứ 7, CN]
→ "1111100" = T2, T3, T4, T5, T6 (không T7, CN)

**Dùng cho:**
- Xác định hôm nay có nên uống không
- Get tần suất để hiển thị

---

## ⏰ Bảng 3: medicine_schedule_times (Giờ uống trong ngày)

```sql
CREATE TABLE medicine_schedule_times (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  medicine_schedule_id UUID NOT NULL REFERENCES medicine_schedules(id) ON DELETE CASCADE,
  
  time_of_day TIME NOT NULL,                    -- "08:00", "14:00", "20:00"
  order_index INTEGER DEFAULT 0,                -- 0, 1, 2... (để sort)
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

**Ví dụ:**
```
id: 660e8400-e29b-41d4-a716-446655440111
medicine_schedule_id: 550e8400-e29b-41d4-a716-446655440000
time_of_day: "08:00:00"
order_index: 0

id: 660e8400-e29b-41d4-a716-446655440222
medicine_schedule_id: 550e8400-e29b-41d4-a716-446655440000
time_of_day: "20:00:00"
order_index: 1
```

→ Cùng 1 medicine, 2 giờ uống: 08:00 và 20:00

**Dùng cho:**
- Hiển thị: "Uống lúc 08:00, 20:00"
- Get giờ uống tiếp theo
- Tính phút còn lại

---

## 📝 Bảng 4: medicine_intakes (Lịch sử uống - Tracking)

```sql
CREATE TABLE medicine_intakes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_medicine_id UUID REFERENCES user_medicines(id) ON DELETE SET NULL,
  medicine_schedule_time_id UUID REFERENCES medicine_schedule_times(id) ON DELETE SET NULL,
  
  medicine_name VARCHAR(255) NOT NULL,           -- Snapshot tên
  dosage_strength VARCHAR(100),
  quantity_per_dose INTEGER,
  
  scheduled_date DATE NOT NULL,                  -- "2024-11-18"
  scheduled_time TIME NOT NULL,                  -- "08:00"
  taken_at TIMESTAMP WITH TIME ZONE,             -- NULL nếu chưa uống, hoặc "2024-11-18 08:05:23"
  status VARCHAR(20) NOT NULL DEFAULT 'pending', -- "pending", "taken", "skipped", "missed"
  
  notes TEXT,                                    -- "Quên uống", "Bị dị ứng"...
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

**Ví dụ:**

**Dự định uống nhưng chưa uống:**
```
scheduled_date: "2024-11-18"
scheduled_time: "08:00"
status: "pending"
taken_at: NULL
```

**Đã uống:**
```
scheduled_date: "2024-11-18"
scheduled_time: "08:00"
status: "taken"
taken_at: "2024-11-18 08:05:23"
```

**Quên uống:**
```
scheduled_date: "2024-11-18"
scheduled_time: "08:00"
status: "missed"
taken_at: NULL
```

**Bỏ qua (chủ động):**
```
scheduled_date: "2024-11-18"
scheduled_time: "08:00"
status: "skipped"
taken_at: NULL
notes: "Bị dị ứng"
```

**Dùng cho:**
- Hiển thị: "Đã uống" / "Chưa uống" / "Quên"
- Tracking lịch sử (hôm nay, tuần, tháng)
- Thống kê tỉ lệ uống đúng giờ

---

## 🔗 Mối quan hệ (Relationships)

```
User
  ↓ (1:N)
user_medicines (1 user → nhiều thuốc)
  ↓ (1:1)
medicine_schedules (1 medicine → 1 schedule)
  ↓ (1:N)
medicine_schedule_times (1 schedule → nhiều giờ)

medicine_intakes (tracking riêng)
  ↓
Liên kết tới: user, user_medicine, medicine_schedule_time
```

---

## 📈 Query Examples

### 1. Lấy danh sách thuốc hôm nay (sorted by time)
```sql
SELECT 
  um.id, um.name, um.dosage_strength, um.quantity_per_dose,
  mst.time_of_day, mst.order_index
FROM user_medicines um
JOIN medicine_schedules ms ON ms.user_medicine_id = um.id
JOIN medicine_schedule_times mst ON mst.medicine_schedule_id = ms.id
WHERE um.user_id = 'user-uuid'
  AND um.is_active = true
  AND um.start_date <= CURRENT_DATE
  AND (um.end_date IS NULL OR um.end_date >= CURRENT_DATE)
ORDER BY mst.order_index ASC;
```

### 2. Tính giờ uống tiếp theo
```dart
// Trong Dart:
final nextTime = medicine.getNextIntakeTime(); // TimeOfDay
final minutes = medicine.getMinutesUntilNextIntake(); // int
```

### 3. Tracking: Tạo intake record cho ngày hôm sau
```sql
-- Chạy hàng đêm để prepare intakes cho ngày tiếp theo
INSERT INTO medicine_intakes (
  user_id, user_medicine_id, medicine_schedule_time_id,
  medicine_name, dosage_strength, quantity_per_dose,
  scheduled_date, scheduled_time, status
)
SELECT 
  um.user_id, um.id, mst.id,
  um.name, um.dosage_strength, um.quantity_per_dose,
  CURRENT_DATE + 1, mst.time_of_day, 'pending'
FROM user_medicines um
JOIN medicine_schedules ms ON ms.user_medicine_id = um.id
JOIN medicine_schedule_times mst ON mst.medicine_schedule_id = ms.id
WHERE um.is_active = true
  AND um.start_date <= CURRENT_DATE + 1
  AND (um.end_date IS NULL OR um.end_date >= CURRENT_DATE + 1);
```

### 4. Get lịch sử uống hôm nay
```sql
SELECT medicine_name, scheduled_time, status, taken_at
FROM medicine_intakes
WHERE user_id = 'user-uuid'
  AND scheduled_date = CURRENT_DATE
ORDER BY scheduled_time ASC;
```

---

## ✅ Index (Performance)

Các index được tạo:
- `idx_user_medicines_user_id` - Search by user
- `idx_medicine_schedule_times_schedule_id` - Get times for schedule
- `idx_medicine_intakes_user_id` - Get intakes for user
- `idx_medicine_intakes_scheduled_date` - Filter by date

---

## 🔐 RLS (Row Level Security)

```sql
-- Users chỉ truy cập dữ liệu của chính họ
DROP POLICY IF EXISTS "Users can view own medicines" ON user_medicines;
CREATE POLICY "Users can view own medicines"
ON user_medicines
FOR SELECT
USING (auth.uid() = user_id);

-- Tương tự cho insert, update, delete...
```

---

## 📝 Cách sử dụng trong Dart

### Create:
```dart
final medicine = await repo.createMedicine(
  userId: user.id,
  name: 'Paracetamol',
  dosageStrength: '500mg',
  dosageForm: 'tablet',
  quantityPerDose: 1,
  startDate: DateTime.now(),
  endDate: DateTime.now().add(Duration(days: 30)),
);

final schedule = await repo.createSchedule(
  medicine.id,
  frequencyType: 'daily',
);

await repo.createScheduleTime(
  schedule.id,
  timeOfDay: TimeOfDay(hour: 8, minute: 0),
  orderIndex: 0,
);
```

### Read:
```dart
final medicines = await repo.getTodayMedicines(userId);
// Auto sorted by next intake time
```

### Update:
```dart
await repo.updateMedicine(
  medicineId,
  name: 'Paracetamol',
  dosageStrength: '500mg',
);
```

### Track intake:
```dart
await repo.updateMedicineIntakeStatus(
  intakeId,
  status: 'taken', // "pending" → "taken"
);
```

---

## 🎯 Summary

| Table | Purpose | Rows per medicine |
|-------|---------|------------------|
| user_medicines | Thông tin thuốc | 1 |
| medicine_schedules | Tần suất | 1 |
| medicine_schedule_times | Giờ uống | N (thường 2-3) |
| medicine_intakes | Lịch sử | 1 per ngày per giờ |

---

**📌 Tất cả schema đã có sẵn trong `new_medicine_schema.sql` - chỉ cần run 1 lần!**
