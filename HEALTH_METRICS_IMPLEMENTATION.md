# Health Metrics System - Implementation Guide

## 📋 Overview

Tôi đã refactor trang **Health Screen** để hỗ trợ ba tính năng chính:

1. **Empty State** - Trang rỗng khi không có dữ liệu, cho phép người dùng nhập hoặc đồng bộ
2. **Manual Input** - Người dùng tự nhập thông tin sức khỏe qua `AddHealthProfileScreen`
3. **Mi Fitness/Redmi Watch Integration** - Skeleton service để đồng bộ dữ liệu từ thiết bị Xiaomi

---

## 🗄️ Database Schema

### New Tables Created (Run in Supabase SQL Editor)

**File:** `MIGRATION_ADD_HEALTH_METRICS.sql`

#### 1. `user_health_profiles`
Lưu thông tin sức khỏe **hiện tại** (lần đo mới nhất)

```sql
- id (UUID)
- user_id (UUID) - Foreign Key to users
- bmi (DECIMAL)
- blood_pressure_systolic (SMALLINT) - 120
- blood_pressure_diastolic (SMALLINT) - 80
- heart_rate (SMALLINT) - BPM
- glucose_level (DECIMAL) - mg/dL
- cholesterol_level (DECIMAL) - mg/dL
- notes (TEXT)
- last_updated_at (TIMESTAMP)
- created_at, updated_at (TIMESTAMP)
```

**Unique Constraint:** `user_id` (mỗi user chỉ có 1 profile)

#### 2. `health_metric_history`
Lưu **lịch sử chi tiết** của mỗi lần đo (để theo dõi xu hướng, vẽ biểu đồ)

```sql
- id (UUID)
- user_id (UUID) - Foreign Key to users
- metric_type (VARCHAR) - 'bmi', 'blood_pressure', 'heart_rate', 'glucose', 'cholesterol'
- value_numeric (DECIMAL) - Giá trị chính
- value_secondary (SMALLINT) - Giá trị phụ (diastolic pressure)
- unit (VARCHAR) - 'kg/m²', 'mmHg', 'BPM', 'mg/dL'
- source (VARCHAR) - 'manual', 'mi_fitness', 'redmi_watch', 'garmin'
- notes (TEXT)
- measured_at (TIMESTAMP) - Thời gian đo (có thể ngày hôm trước)
- created_at, updated_at (TIMESTAMP)
```

**Indexes:**
- `user_id`
- `metric_type`
- `measured_at`
- `(user_id, metric_type, measured_at)`

---

## 📱 Files Created/Modified

### 1. Models
- **File:** `lib/models/health_metric.dart`
- **Classes:**
  - `HealthMetric` - Single health measurement record
  - `HealthProfile` - User's current health state

### 2. Repository
- **File:** `lib/repositories/health_metrics_repository.dart`
- **Key Methods:**
  - `getUserHealthProfile(userId)` - Get current health state
  - `createHealthProfile(...)` - Create new health profile
  - `updateHealthProfile(...)` - Update profile
  - `addHealthMetric(...)` - Add measurement to history
  - `getWeeklyMetrics(userId)` - Get 7-day history
  - `getMonthlyMetrics(userId)` - Get 30-day history
  - `getLatestMetric(userId, metricType)` - Get most recent measurement
  - `getMetricAggregate(...)` - Get average/min/max for period

### 3. UI Screens

#### Health Screen (Refactored)
- **File:** `lib/screens/health_screen.dart`
- **Features:**
  - Empty state when no data
  - Load data from Supabase on init
  - Display current metrics (BMI, BP, HR, Glucose, Cholesterol)
  - Weekly progress chart (time-based)
  - Manual input button to add/update data
  - Refresh on pop from AddHealthProfileScreen

#### Add Health Profile Screen (To be updated)
- **File:** `lib/screens/add_health_profile_screen.dart`
- **TODO:** Update to:
  - Save to `user_health_profiles` table
  - Add health metrics to `health_metric_history`
  - Update `last_updated_at` timestamp

### 4. Integration Service (Skeleton)
- **File:** `lib/services/mi_fitness_integration_service.dart`
- **Purpose:** Handle Xiaomi/Redmi Watch API integration
- **Current Status:** TODO - needs implementation

---

## 🔄 Data Flow

### Manual Entry Flow
```
User Input (AddHealthProfileScreen)
    ↓
Save to user_health_profiles (current state)
    ↓
Add entries to health_metric_history (timestamped records)
    ↓
Navigate back to HealthScreen
    ↓
Reload data from Supabase
    ↓
Display updated information
```

### Mi Fitness Sync Flow (Future)
```
User clicks "Sync from Redmi Watch"
    ↓
OAuth Login (Xiaomi Account)
    ↓
Get Access Token
    ↓
Call Mi Fitness API
    ↓
Get measurements (heart_rate, steps, etc.)
    ↓
Convert to HealthMetric format
    ↓
Batch insert to health_metric_history
    ↓
Update user_health_profiles if needed
    ↓
Refresh UI
```

---

## 📊 Time-Based Tracking

### Weekly Progress Chart
```dart
// Group metrics by date
final metricsGroupedByDate = <String, List<HealthMetric>>{};
for (final metric in _weeklyMetrics) {
  final dateStr = metric.measuredAt.toString().split(' ')[0];
  metricsGroupedByDate.putIfAbsent(dateStr, () => []).add(metric);
}

// Calculate daily average
double avgValue = metrics
    .where((m) => m.valueNumeric != null)
    .map((m) => m.valueNumeric!)
    .reduce((a, b) => a + b) / metrics.length;
```

### Available Data Points
- **Today:** `getTodayMetrics(userId)`
- **This Week:** `getWeeklyMetrics(userId)`
- **This Month:** `getMonthlyMetrics(userId)`
- **Custom Range:** `getMetricHistory(userId, type, fromDate, toDate)`
- **Latest:** `getLatestMetric(userId, metricType)`

---

## 🔗 How to Integrate Mi Fitness/Redmi Watch

### Step 1: Register Xiaomi App
1. Go to https://dev.mi.com
2. Create developer account
3. Create new app project
4. Get **Client ID** and **Client Secret**
5. Set redirect URI: `https://yourapp.com/callback`

### Step 2: Implement OAuth Flow
```dart
// In your settings screen or health screen
final service = MiFitnessIntegrationService();

// 1. Initiate OAuth
final authCode = await service.initiateXiaomiAuth();

// 2. Exchange code for token
final accessToken = await service.exchangeCodeForToken(authCode);

// 3. Save token securely
await service.saveAccessToken(
  userId: currentUserId,
  accessToken: accessToken,
  refreshToken: refreshToken,
  expiresIn: expiresIn,
);
```

### Step 3: Sync Data
```dart
// Sync today's data
await service.syncDailyHealthData(
  userId: userId,
  accessToken: accessToken,
  date: DateTime.now(),
);

// Or sync historical data
await service.syncHistoricalData(
  userId: userId,
  accessToken: accessToken,
  daysBack: 30, // Last 30 days
);
```

### Step 4: Schedule Auto-Sync (Optional)
```dart
// Run daily at 2 AM
// Requires: workmanager package
scheduleAutoSync();
```

---

## 📦 Dependencies Needed

Add to `pubspec.yaml`:

```yaml
dependencies:
  # For OAuth
  flutter_web_auth: ^0.5.0
  
  # For secure storage
  flutter_secure_storage: ^9.0.0
  
  # For background tasks
  workmanager: ^0.5.0
  
  # For HTTP requests (if not using Supabase client)
  http: ^1.1.0
  
  # Already have these
  supabase_flutter: ^latest
  provider: ^latest
```

---

## 🧪 Testing the System

### 1. Test Empty State
- Delete all health data from database
- Open HealthScreen
- Should show empty state with action buttons

### 2. Test Manual Input
1. Click "Nhập thông tin thủ công"
2. Fill form in AddHealthProfileScreen
3. Click Save
4. Should return to HealthScreen with data

### 3. Test Data Persistence
1. Add data
2. Close and reopen app
3. Data should still be there (from Supabase)

### 4. Test Weekly Chart
1. Add multiple measurements on different dates
2. Weekly chart should show bars
3. Height = normalized value from 0-100

---

## 🔐 Security Considerations

### 1. RLS Policies
All health tables have Row-Level Security:
- Users can only view/edit their own data
- Policies verified on database level

### 2. Token Management
```sql
-- Store in flutter_secure_storage, NOT shared_preferences
FlutterSecureStorage().write(
  key: 'mi_fitness_access_token_$userId',
  value: accessToken,
);
```

### 3. Backend Recommendation
For production:
- Use backend server for OAuth token exchange
- Never expose Client Secret to frontend
- Backend validates and stores tokens

---

## 📝 Example: Adding New Metric Type

To support additional metrics (e.g., weight, oxygen):

```dart
// 1. Update metric_type constraint in SQL
CONSTRAINT check_metric_type CHECK (
  metric_type IN (
    'bmi', 'blood_pressure', 'heart_rate', 
    'glucose', 'cholesterol', 'weight', 'oxygen'
  )
);

// 2. Update model if needed
// (HealthMetric is generic enough)

// 3. Add to UI
if (_healthProfile!.weight != null) {
  _buildVitalCard(
    title: 'Cân nặng',
    value: '${_healthProfile!.weight}',
    unit: 'kg',
  );
}
```

---

## 🚀 Next Steps

### Immediate (Week 1-2)
- [ ] Update `AddHealthProfileScreen` to save to database
- [ ] Test manual data entry flow
- [ ] Add notification when new data added

### Short-term (Week 3-4)
- [ ] Register Xiaomi developer app
- [ ] Implement OAuth flow UI
- [ ] Test token exchange

### Medium-term (Week 5-6)
- [ ] Implement Mi Fitness API calls
- [ ] Batch sync data
- [ ] Add auto-sync scheduling

### Long-term
- [ ] Support other devices (Garmin, Apple Watch)
- [ ] Advanced analytics & trends
- [ ] Export reports (PDF/CSV)
- [ ] Share with doctors

---

## 📚 References

### Xiaomi Documentation
- https://dev.mi.com (Developer site)
- https://api-mifit.huami.com/docs (API docs)
- Mi Fitness OAuth2 integration

### Flutter Packages
- [flutter_web_auth](https://pub.dev/packages/flutter_web_auth)
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)
- [workmanager](https://pub.dev/packages/workmanager)

### Database
- [Supabase Row-Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Supabase Real-time](https://supabase.com/docs/guides/realtime)

---

## 💡 Tips

1. **For Testing:** Create test user with sample data
2. **Rate Limiting:** Xiaomi API has limits - cache data locally
3. **Battery:** Redmi Watch syncs periodically - don't force sync too often
4. **Accuracy:** Health data varies - show trends, not absolute values
5. **Privacy:** Always ask permission before syncing

---

**Created:** 2025-11-21  
**Last Updated:** 2025-11-21  
**Status:** In Progress (Mi Fitness integration pending)
