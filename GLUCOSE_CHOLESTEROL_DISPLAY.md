# Glucose & Cholesterol Display - Health Screen Update

## Hiển thị trên trang Health Screen

### 1. **Layout Hiển thị**

Khi người dùng có đầy đủ 4 chỉ số (BP, HR, Glucose, Cholesterol):

```
┌─────────────────────────────────────────┐
│          MY HEALTH INFORMATION          │
├─────────────────────────────────────────┤
│  BMI: 28.5                              │
│  Status: Overweight                     │
├─────────────────────────────────────────┤
│  [BP: 140/90]  [Heart Rate: 75]        │
│  [Glucose: 110] [Cholesterol: 220]     │
├─────────────────────────────────────────┤
│     HEALTH ASSESSMENT CARD              │
│  ├─ BMI: Overweight (Caution) ⚠️       │
│  ├─ Blood Pressure: Stage 1 (Caution)  │
│  ├─ Heart Rate: Normal (Good) ✓        │
│  ├─ Glucose: Prediabetic (Caution) ⚠️  │
│  └─ Cholesterol: Borderline (Caution) │
└─────────────────────────────────────────┘
```

### 2. **Responsive Grid Layout**

Các chỉ số được sắp xếp dựa trên số lượng có sẵn:

#### **2 Chỉ số**: 1 hàng (2 cột)
```
[BP]  [HR]
```

#### **3 Chỉ số**: 2 hàng (2+1)
```
[BP]  [HR]
[Glucose]
```

#### **4 Chỉ số**: 2x2 Grid
```
[BP]       [HR]
[Glucose]  [Cholesterol]
```

### 3. **Glucose Assessment - Tiêu chuẩn (mg/dL)**

| Chỉ số | Trạng thái | Status | Màu | Icon |
|--------|-----------|--------|------|------|
| < 70 | Hạ đường huyết (Low blood sugar) | Warning 🔴 | Đỏ | ✕ |
| 70-100 | Bình thường (Normal) | Good 🟢 | Xanh | ✓ |
| 100-126 | Tiền tiểu đường (Prediabetic) | Caution 🟡 | Cam | ⚠️ |
| 126-200 | Tiểu đường (Diabetic) | Warning 🔴 | Đỏ | ✕ |
| > 200 | Cao rất nhiều (Very high) | Warning 🔴 | Đỏ | ✕ |

**Khuyến nghị**: Theo dõi đường huyết thường xuyên và tư vấn bác sĩ nếu cao

### 4. **Cholesterol Assessment - Tiêu chuẩn (mg/dL)**

| Chỉ số | Trạng thái | Status | Màu | Icon |
|--------|-----------|--------|------|------|
| < 200 | Mức lý tưởng (Desirable) | Good 🟢 | Xanh | ✓ |
| 200-240 | Cao hơi (Borderline high) | Caution 🟡 | Cam | ⚠️ |
| > 240 | Cao (High) | Warning 🔴 | Đỏ | ✕ |

**Khuyến nghị**: Duy trì chế độ ăn uống ít chất béo bão hòa và tập thể dục thường xuyên

## Ví dụ Thực tế

### **Case 1: Người khỏe mạnh**
```
MyHealth Screen:
- BMI: 23.5 → Bình thường (Good)
- BP: 118/78 → Bình thường (Good)
- HR: 72 → Bình thường (Good)
- Glucose: 92 → Bình thường (Good)
- Cholesterol: 180 → Mức lý tưởng (Good)

Health Assessment:
✓ Tất cả chỉ số đều tốt
✓ Tiếp tục duy trì lối sống hiện tại
```

### **Case 2: Cần chú ý**
```
MyHealth Screen:
- BMI: 27.2 → Thừa cân (Caution)
- BP: 135/85 → Cao hơn bình thường (Caution)
- HR: 98 → Bình thường (Good)
- Glucose: 115 → Tiền tiểu đường (Caution)
- Cholesterol: 225 → Cao hơi (Caution)

Health Assessment:
⚠️ Glucose: Tiền tiểu đường → Theo dõi đường huyết thường xuyên
⚠️ Cholesterol: Cao hơi → Giảm chất béo bão hòa trong ăn uống
⚠️ Blood Pressure: Cao hơn bình thường → Giảm muối, tập thể dục
```

### **Case 3: Cảnh báo**
```
MyHealth Screen:
- BMI: 32.1 → Béo phì (Warning)
- BP: 145/92 → Giai đoạn 1 (Warning)
- HR: 85 → Bình thường (Good)
- Glucose: 165 → Tiểu đường (Warning)
- Cholesterol: 260 → Cao (Warning)

Health Assessment:
🔴 Multiple Warning Indicators
🔴 Glucose: Tiểu đường → Tư vấn bác sĩ ngay
🔴 Cholesterol: Cao → Xét nghiệm lipid đầy đủ
🔴 Blood Pressure: Giai đoạn 1 → Dùng thuốc huyết áp nếu cần
```

## Features Đã Thêm

✅ Support đầy đủ Glucose Level (Đường huyết)
✅ Support đầy đủ Cholesterol Level  
✅ Responsive Grid Layout (1-4 chỉ số)
✅ Color-coded Status Icons
✅ Personalized Health Recommendations
✅ Multi-language Support (English + Vietnamese)
✅ Assessment Service with Medical Standards

## API Response Example

```json
{
  "health_profile": {
    "id": "uuid",
    "bmi": 28.5,
    "blood_pressure_systolic": 140,
    "blood_pressure_diastolic": 90,
    "heart_rate": 75,
    "glucose_level": 115.5,
    "cholesterol_level": 225.0,
    "last_updated_at": "2024-11-22T10:30:00Z"
  }
}
```

## File Changes

1. ✅ `health_assessment_service.dart` - Thêm assessGlucose() & assessCholesterol()
2. ✅ `health_screen.dart` - Cập nhật _buildVitalsRow() + _buildAssessmentCard()
3. ✅ `app_en.arb` - Thêm 14 strings tiếng Anh
4. ✅ `app_vi.arb` - Thêm 14 strings tiếng Việt
5. ✅ `app_localizations_en.dart` - Auto-generated getters
6. ✅ `app_localizations_vi.dart` - Auto-generated getters
