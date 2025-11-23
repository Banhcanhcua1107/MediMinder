# Hướng Dẫn Test Xóa Thuốc - Chi Tiết Từng Bước

## 🎯 Mục Tiêu
Xác minh rằng:
1. ✅ **Vuốt qua trái để xóa** hoạt động trên **cả Home và Medicine List**
2. ✅ **Dữ liệu thực sự bị xóa** khỏi database
3. ✅ **Cascade delete** hoạt động đúng (xóa schedules và times)

---

## 📱 Test 1: Vuốt Xóa trên Home Screen

### Bước 1: Khởi động ứng dụng
```bash
cd d:\LapTrinhUngDungDT\MediMinder_DA\mediminder
flutter run
```

### Bước 2: Đi đến Home Screen
- Đăng nhập nếu cần
- Xem danh sách thuốc trên trang Home

### Bước 3: Vuốt Xóa
1. **Tìm 1 box thuốc** bất kỳ
2. **Vuốt từ phải sang trái** (swipe left)
   - Bạn sẽ thấy background đỏ với icon trash
3. **Xác nhận xóa** khi dialog hiện lên
4. **Kết quả mong đợi**:
   - ✅ Box disappear ngay lập tức
   - ✅ Toast notification: "Đã xóa [Tên thuốc]"
   - ✅ Danh sách update mà không reload

### Bước 4: Kiểm tra Debug Logs
Trong Flutter console, bạn sẽ thấy:
```
🗑️ Deleting medicine abc-123 from database...
✅ Notifications cancelled for abc-123
✅ Medicine deleted from database
✅ Medicine removed from local state
✅ Listeners notified
```

---

## 📋 Test 2: Vuốt Xóa trên Medicine List Screen

### Bước 1: Chuyển sang Medicine List
- Tab dưới cùng → "Danh sách thuốc"

### Bước 2: Vuốt Xóa
1. **Tìm 1 box thuốc**
2. **Vuốt từ phải sang trái**
3. **Xác nhận xóa**
4. **Kết quả mong đợi**:
   - ✅ Box disappear
   - ✅ Danh sách update

---

## 🗄️ Test 3: Kiểm tra Database - Dữ Liệu Thực Sự Bị Xóa

### Bước 1: Truy cập Supabase Dashboard
1. Vào https://supabase.com
2. Login → Chọn project MediMinder
3. Nhấp **SQL Editor**

### Bước 2: Kiểm tra user_medicines
Chạy query này:
```sql
SELECT id, name, user_id, is_active, created_at 
FROM user_medicines 
WHERE is_active = true
ORDER BY created_at DESC;
```

**Kết quả mong đợi**:
- ❌ **Thuốc vừa xóa KHÔNG xuất hiện** trong danh sách

### Bước 3: Kiểm tra Cascade Delete - medicine_schedules
Chạy query:
```sql
SELECT * FROM medicine_schedules 
WHERE user_medicine_id = 'PUT_DELETED_MEDICINE_ID_HERE'
ORDER BY created_at DESC;
```

**Kết quả mong đợi**:
- ❌ **Kết quả trống** (schedules bị xóa tự động)

### Bước 4: Kiểm tra Cascade Delete - medicine_schedule_times
Chạy query:
```sql
SELECT mst.* 
FROM medicine_schedule_times mst
LEFT JOIN medicine_schedules ms ON ms.id = mst.medicine_schedule_id
WHERE ms.id IS NULL
LIMIT 10;
```

**Kết quả mong đợi**:
- ❌ **Kết quả trống** hoặc rất ít records
- (Không có orphaned schedule times)

---

## 🔍 Test 4: Kiểm tra Soft Delete Không Được Dùng

### Mục tiêu
Đảm bảo **không dùng soft delete** (set `is_active = false`)  
Mà dùng **hard delete** (xóa thực sự)

### Bước 1: Xóa 1 thuốc
- Như bước Test 1

### Bước 2: Kiểm tra cột `is_active`
```sql
SELECT id, name, is_active, updated_at
FROM user_medicines 
WHERE name = 'TÊN_THUỐC_VỨA_XÓA'
LIMIT 1;
```

**Kết quả mong đợi**:
- ❌ **Không có kết quả** (vì đã xóa thực sự)
- ✅ **KHÔNG phải** `is_active = false`

---

## 📊 Test 5: Kiểm tra Xóa Notifications

### Mục tiêu
Xác minh notifications liên quan cũng bị cancel

### Bước 1: Trước khi xóa
- Ghi chú `medicine_id` của thuốc chuẩn bị xóa

### Bước 2: Kiểm tra logs
Khi xóa, Flutter console sẽ hiển thị:
```
✅ Notifications cancelled for abc-123
```

### Bước 3: Kiểm tra trực tiếp (nếu cần)
Trên thiết bị Android:
```
Settings → Apps & notifications → Notifications
→ MediMinder → See all
```

**Kết quả mong đợi**:
- ❌ Không có notification nào từ thuốc đã xóa

---

## ⚠️ Troubleshooting

### Vấn đề: Vuốt không xóa
**Giải pháp**:
1. Kiểm tra `Dismissible` widget có wrap đúng không
   ```dart
   return Dismissible(
     key: Key(medicine.id),  // ← Important
     direction: DismissDirection.endToStart,
     // ...
   );
   ```
2. Kiểm tra `context` có available không
3. Run `flutter clean` → `flutter pub get` → `flutter run`

### Vấn đề: Xóa không sync với database
**Giải pháp**:
1. Kiểm tra RLS policy trong Supabase:
   ```sql
   SELECT * FROM pg_policies 
   WHERE tablename = 'user_medicines';
   ```
2. Ensure user_id match:
   ```dart
   final session = Supabase.instance.client.auth.currentSession;
   debugPrint('User ID: ${session?.user.id}');
   ```

### Vấn đề: Toast không hiển thị
**Giải pháp**:
1. Kiểm tra `showCustomToast` import đúng
2. Kiểm tra `mounted` check:
   ```dart
   if (mounted) {
     showCustomToast(...);
   }
   ```

---

## 📋 Checklist Test Hoàn Chỉnh

Đánh dấu ✅ khi qua từng test:

- [ ] **Test 1A**: Vuốt xóa Home - Box disappear
- [ ] **Test 1B**: Toast notification hiển thị
- [ ] **Test 1C**: Debug logs chính xác
- [ ] **Test 2A**: Vuốt xóa Medicine List - Box disappear
- [ ] **Test 2B**: Danh sách update
- [ ] **Test 3A**: user_medicines - Không có thuốc đã xóa
- [ ] **Test 3B**: medicine_schedules - Cascade delete thành công
- [ ] **Test 3C**: medicine_schedule_times - Không orphaned records
- [ ] **Test 4A**: Không dùng soft delete
- [ ] **Test 4B**: Hard delete - Xóa vĩnh viễn
- [ ] **Test 5A**: Notifications cancelled logs
- [ ] **Toàn Bộ**: Tất cả tests PASS ✅

---

## 🎉 Test Thành Công = Hoàn Thành!

Khi tất cả tests pass:
1. ✅ Xóa hoạt động trên **Home và Medicine List**
2. ✅ Dữ liệu **thực sự bị xóa** từ database
3. ✅ **Cascade delete** tự động xóa schedules
4. ✅ Không còn **orphaned records**
5. ✅ UI update **ngay lập tức**

---

## 💾 Cách Lưu Test Results

Tạo file `TEST_RESULTS.md`:
```markdown
# Test Results - Delete Medicine Feature

## Date: [NGÀY]
## Tester: [NGƯỜI TEST]

### Test 1: Home Screen Swipe Delete
- Status: ✅ PASS
- Notes: Box disappeared in [X] seconds

### Test 2: Medicine List Screen Swipe Delete
- Status: ✅ PASS
- Notes: Worked as expected

### Test 3: Database Verification
- Status: ✅ PASS
- Deleted medicines: [N]
- Verified via SQL: user_medicines, medicine_schedules, medicine_schedule_times

### Overall Result: ✅ PASS - Feature Ready for Production
```

---

**Bắt đầu test ngay!** 🚀
