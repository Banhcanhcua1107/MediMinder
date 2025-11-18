# 📱 MediMinder - Hướng Dẫn Chi Tiết

## 🎯 Tóm tắt công việc đã hoàn thành

Tôi đã tạo **hoàn chỉnh** hệ thống quản lý thuốc gồm:

✅ **3 file Dart:**
- `lib/models/user_medicine.dart` - Các class dữ liệu (UserMedicine, MedicineSchedule, MedicineScheduleTime, MedicineIntake)
- `lib/repositories/medicine_repository.dart` - Lớp CRUD kết nối Supabase
- `lib/screens/medicine_list_screen.dart` - Trang danh sách thuốc (CẬP NHẬT)
- `lib/screens/add_med_screen.dart` - Trang thêm/sửa thuốc (CẬP NHẬT)

✅ **1 file SQL:**
- `new_medicine_schema.sql` - Database schema (4 bảng, RLS, triggers, functions)

✅ **6 file hướng dẫn:**
- `QUICK_START.md` - Setup nhanh
- `MEDICINE_SETUP.md` - Setup chi tiết
- `SQL_SCHEMA_DETAILS.md` - Chi tiết SQL
- `README_MEDICINE.md` - Tính năng
- `COMPLETION_SUMMARY.md` - Tổng hợp
- `FILES_INDEX.md` - Chỉ mục tất cả file

---

## 🚀 CÓ 3 BƯỚC ĐỂ CHẠY

### **BƯỚC 1: Chạy SQL (2 phút)**

```
1. Vào https://supabase.com
2. Login vào project của bạn
3. Click "SQL Editor" (trái)
4. Click nút "+" → "New query"
5. Mở file: new_medicine_schema.sql (trong workspace)
6. Copy toàn bộ nội dung
7. Paste vào SQL Editor
8. Click "RUN" (phía dưới phải)
9. Chờ xanh ✅ = thành công
```

**Kết quả:** 4 bảng mới được tạo trong database

---

### **BƯỚC 2: Rebuild app (2 phút)**

```powershell
# Mở terminal PowerShell trong VS Code
# Chạy lệnh này:

cd d:\LapTrinhUngDungDT\MediMinder_DA\mediminder
flutter clean
flutter pub get
flutter run
```

**Chờ:**
- `flutter clean` xóa file cũ
- `flutter pub get` tải dependencies
- `flutter run` chạy app

---

### **BƯỚC 3: Test chức năng (5 phút)**

Khi app chạy:

1. **Trang danh sách thuốc:**
   - Nếu chưa có thuốc → hiện "Bạn chưa có thuốc nào. Nhấn nút + để thêm."
   - Nút **+** ở cuối trang

2. **Nhấn nút + → Trang thêm thuốc:**
   - Nhập: Tên thuốc, mg, số viên, dạng thuốc, ghi chú
   - Chọn: Ngày bắt đầu, ngày kết thúc
   - Chọn: Tần suất (Hàng ngày / Cách ngày)
   - Thêm: Nhiều giờ uống (nhấn "Thêm giờ uống")
   - Nhấn "Thêm thuốc" → Lưu

3. **Quay lại trang danh sách:**
   - Thuốc vừa thêm **sẽ hiện ở đây**
   - Hiển thị: Tên, liều lượng, giờ uống sắp tới, số phút còn lại
   - **Sắp xếp theo giờ uống** (gần nhất trước)

4. **Nhấn vào thuốc → Trang sửa thuốc:**
   - Tất cả thông tin sẽ **tự động điền** lại
   - Bạn có thể sửa
   - Nhấn "Cập nhật thuốc"

---

## 🔍 CÁC FILE CẦN KIỂM TRA

### **File Dart (4 file)**

| File | Vị trí | Trạng thái | Ghi chú |
|------|--------|-----------|---------|
| user_medicine.dart | `lib/models/` | ✅ Mới tạo | Chứa 4 class |
| medicine_repository.dart | `lib/repositories/` | ✅ Mới tạo | Chứa CRUD |
| medicine_list_screen.dart | `lib/screens/` | ✅ Cập nhật | Fetch từ DB |
| add_med_screen.dart | `lib/screens/` | ✅ Cập nhật | Thêm/Sửa |

### **File SQL (1 file)**

| File | Vị trí | Trạng thái | Ghi chú |
|------|--------|-----------|---------|
| new_medicine_schema.sql | Root | ✅ Mới tạo | Cần chạy 1 lần |

### **File Hướng Dẫn (6 file)**

| File | Độ dài | Thời gian | Loại |
|------|--------|----------|------|
| QUICK_START.md | ~100 dòng | 5 min | Setup nhanh |
| MEDICINE_SETUP.md | ~200 dòng | 15 min | Setup chi tiết |
| SQL_SCHEMA_DETAILS.md | ~300 dòng | 20 min | Tham khảo SQL |
| README_MEDICINE.md | ~150 dòng | 10 min | Tính năng |
| COMPLETION_SUMMARY.md | ~250 dòng | 15 min | Tổng hợp |
| FILES_INDEX.md | ~200 dòng | 10 min | Chỉ mục |

---

## ✅ CHECKLIST SETUP

### **Chuẩn bị:**
- [ ] Clone/Download project
- [ ] Có account Supabase
- [ ] Flutter đã cài

### **Bước 1: SQL**
- [ ] Vào Supabase SQL Editor
- [ ] Copy nội dung `new_medicine_schema.sql`
- [ ] Paste vào SQL Editor
- [ ] Click RUN
- [ ] Xem xanh ✅

### **Bước 2: Build**
- [ ] Mở terminal PowerShell
- [ ] `flutter clean`
- [ ] `flutter pub get`
- [ ] `flutter run`
- [ ] Chờ app chạy

### **Bước 3: Test**
- [ ] [ ] Trang danh sách hiển thị (trống hoặc có thuốc)
- [ ] Nhấn nút + → Mở trang thêm
- [ ] Nhập thông tin → Nhấn Thêm
- [ ] Quay lại danh sách → Thuốc hiện ở đó
- [ ] Nhấn thuốc → Mở trang sửa (đã điền sẵn)
- [ ] Sửa → Nhấn Cập nhật
- [ ] Quay lại → Kiểm tra thay đổi

---

## 🐛 NẾU CÓ LỖI

### **Lỗi 1: "Không thể kết nối Supabase"**
```
→ Kiểm tra: Supabase project URL + API key trong main.dart
→ Đảm bảo: Internet connection
```

### **Lỗi 2: "Models/Repository import error"**
```
→ Chạy: flutter pub get
→ Xoá: build/ folder
→ Chạy: flutter clean && flutter pub get
```

### **Lỗi 3: "SQL table không tạo"**
```
→ Kiểm tra: RUN button có xanh không?
→ Xem: Messages tab ở dưới (có error không?)
→ Retry: Copy-paste lại toàn bộ SQL
```

### **Lỗi 4: "App crash khi click +"**
```
→ Kiểm tra: Console (terminal) có error gì?
→ Đảm bảo: add_med_screen.dart được cập nhật đúng
```

### **Lỗi 5: "Thuốc không hiện trong list"**
```
→ Kiểm tra: Đã lưu vào Supabase không?
→ Xem: SQL table user_medicines (có data không?)
→ Restart: App (click R trong terminal)
```

---

## 📝 GIẢI THÍCH TỪng FILE

### **1. user_medicine.dart**
Chứa 4 class dữ liệu:
- **UserMedicine** - Thông tin thuốc (tên, mg, số viên, ...)
  - Helper: `getNextIntakeTime()` - Giờ uống tiếp theo
  - Helper: `getTimeUntilNextIntakeText()` - "Trong 2 giờ 30 phút"
- **MedicineSchedule** - Tần suất (Hàng ngày, Cách ngày, ...)
- **MedicineScheduleTime** - Giờ cụ thể (08:00, 20:00)
- **MedicineIntake** - Lịch sử uống (lần này, ngày này, trạng thái)

### **2. medicine_repository.dart**
Lớp kết nối Supabase, có các method:
- **getTodayMedicines()** - Lấy thuốc hôm nay (đã sort theo giờ)
- **createMedicine()** - Tạo thuốc mới
- **updateMedicine()** - Sửa thuốc
- **deleteMedicine()** - Xoá thuốc
- Và nhiều method khác...

### **3. medicine_list_screen.dart**
Trang danh sách:
- Fetch từ database qua `getTodayMedicines()`
- Hiển thị từng thuốc trong card
- Sắp xếp theo giờ uống tiếp theo
- Nhấn card → Trang sửa (pass medicineId)
- Nhấn + → Trang thêm (không pass medicineId)

### **4. add_med_screen.dart**
Trang thêm/sửa:
- Nếu `medicineId` là null → Mode **Thêm**
  - Form trống, button "Thêm thuốc"
- Nếu `medicineId` có giá trị → Mode **Sửa**
  - Form điền sẵn, button "Cập nhật thuốc"
- Khi save → Tạo medicine + schedule + times
- Pop với return true (để list refresh)

### **5. new_medicine_schema.sql**
Database schema:
- **user_medicines** - Danh sách thuốc người dùng
- **medicine_schedules** - Tần suất (Hàng ngày, Cách ngày, ...)
- **medicine_schedule_times** - Giờ cụ thể (08:00, 20:00)
- **medicine_intakes** - Lịch sử (optional, để tracking sau)

**Đặc điểm:**
- RLS Policy (Row Level Security) - Chỉ user thấy dữ liệu riêng họ
- Trigger - Auto update `updated_at` mỗi khi thay đổi
- Function - Helper function để lấy dữ liệu đúng cách

---

## 🔗 LUỒNG DỮ LIỆU

```
User nhấn + (Trang list)
    ↓
Navigator.push → AddMedScreen(medicineId: null)
    ↓
AddMedScreen mở (Mode Thêm)
    ↓
User nhập: Tên, Mg, Viên, Ngày bắt đầu, Ngày kết thúc, Giờ uống
    ↓
User nhấn "Thêm thuốc"
    ↓
_handleSave():
  1. createMedicine() → Tạo user_medicines row
  2. createSchedule() → Tạo medicine_schedules row
  3. Vòng lặp createScheduleTime() → Tạo medicine_schedule_times rows
    ↓
Pop(true) → Quay lại list
    ↓
List refresh qua setState → _loadMedicines()
    ↓
FutureBuilder fetch getTodayMedicines()
    ↓
Thách thứ tự theo getNextIntakeTime()
    ↓
Hiển thị danh sách thuốc (mới + cũ, sorted)
```

---

## 💡 KEY FEATURES

### **Trang Danh Sách:**
✅ Hiển thị danh sách thuốc đang dùng
✅ Sắp xếp theo giờ uống tiếp theo (gần nhất trước)
✅ Hiển thị: Tên, Mg, Giờ tiếp theo, Thời gian còn lại
✅ Nhấn item → Trang sửa (auto-fill data)
✅ Nhấn + → Trang thêm
✅ Empty state: "Bạn chưa có thuốc nào..."

### **Trang Thêm/Sửa:**
✅ Input: Tên, Dạng thuốc, Liều lượng, Số viên
✅ Chọn ngày: Bắt đầu, Kết thúc
✅ Chọn tần suất: Hàng ngày / Cách ngày
✅ Thêm giờ: 08:00, 14:00, 20:00, ... (bao nhiêu lần tùy
✅ Lưu ghi chú thêm
✅ Validation: Kiểm tra tất cả field
✅ Dual mode: Thêm (create) / Sửa (update)

### **Database:**
✅ 4 bảng + RLS Policy
✅ Auto-sort `getTodayMedicines()`
✅ Helper function để lấy dữ liệu
✅ Trigger auto-update timestamp

---

## 📞 CÂU HỎI THƯỜNG GẶP

**Q: Có cần sửa file khác không?**
A: Không! Chỉ cần chạy SQL + flutter run

**Q: Dữ liệu lưu ở đâu?**
A: Lưu trong Supabase PostgreSQL (cloud)

**Q: Nếu thoát app, dữ liệu còn không?**
A: Có, vì lưu trong cloud

**Q: Có thể offline không?**
A: Không, cần internet để lấy từ Supabase

**Q: Muốn add tính năng khác?**
A: Mở MEDICINE_SETUP.md → Section "Next Steps"

---

## 🎯 NEXT STEPS (Optional)

Nếu muốn add thêm tính năng:
1. Notification → Nhắc nhở uống thuốc
2. History → Xem lịch uống quá khứ
3. Stats → Thống kê % tuân thủ
4. Backup → Export/Import data
5. Medicine catalog → Tìm kiếm thuốc

---

## ✨ TỔNG KẾT

**Bạn có:**
✅ Database schema (ready to run)
✅ Models (ready to import)
✅ Repository (ready to use)
✅ 2 Screens (updated)
✅ Documentation (complete)

**Bước tiếp theo:**
1. Run SQL
2. Flutter run
3. Test 3 chức năng chính
4. Done! 🎉

---

## 📚 Tham khảo

Muốn tìm chi tiết? Xem:
- `QUICK_START.md` - Setup nhanh
- `MEDICINE_SETUP.md` - Setup chi tiết
- `SQL_SCHEMA_DETAILS.md` - SQL reference
- `README_MEDICINE.md` - Features list
- `FILES_INDEX.md` - File index

---

**Good luck! 🚀**

Có cần giúp gì thêm không?
