# Architecture Diagrams - Health Metrics System

## 1. Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     USER INTERACTION                        │
└──────────────────────┬──────────────────────────────────────┘
                       │
        ┌──────────────┴──────────────┐
        │                             │
   ┌────▼────────┐          ┌────────▼──────┐
   │   Manual    │          │  Sync from    │
   │    Input    │          │  Redmi Watch  │
   │  (HealthUI) │          │  (Mi Fitness) │
   └────┬────────┘          └────────┬──────┘
        │                             │
   ┌────▼────────────────────────────▼──────┐
   │  HealthMetricsRepository                │
   │  ├── createHealthProfile()              │
   │  ├── updateHealthProfile()              │
   │  ├── addHealthMetric()                  │
   │  ├── getWeeklyMetrics()                 │
   │  └── getMonthlyMetrics()                │
   └────┬─────────────────────────────────────┘
        │
   ┌────▼──────────────────────────────────┐
   │      Supabase PostgreSQL              │
   │  ┌──────────────────────────────────┐ │
   │  │ user_health_profiles             │ │
   │  │ ├── id                           │ │
   │  │ ├── user_id                      │ │
   │  │ ├── bmi, bp, hr, glucose, etc   │ │
   │  │ └── last_updated_at              │ │
   │  └──────────────────────────────────┘ │
   │  ┌──────────────────────────────────┐ │
   │  │ health_metric_history            │ │
   │  │ ├── id                           │ │
   │  │ ├── user_id                      │ │
   │  │ ├── metric_type                  │ │
   │  │ ├── value_numeric                │ │
   │  │ ├── measured_at (TIMESTAMP)      │ │
   │  │ └── source (manual/mi_fitness)   │ │
   │  └──────────────────────────────────┘ │
   └────┬──────────────────────────────────┘
        │
        └─────────────────┐
                          │
                      ┌───▼────────┐
                      │ HealthUI   │
                      │ (Display)  │
                      └────────────┘
```

---

## 2. Manual Entry Flow

```
User Types Data
      │
      ▼
┌──────────────────────────────┐
│ AddHealthProfileScreen       │
│ ├── BMI Input                │
│ ├── Blood Pressure Input     │
│ ├── Heart Rate Input         │
│ └── Save Button              │
└──────────┬───────────────────┘
           │
           ▼
    ┌──────────────┐
    │ _handleSave()│
    └──────┬───────┘
           │
     ┌─────▼──────────┐
     │ Parse Input    │
     │ Validate Data  │
     └─────┬──────────┘
           │
    ┌──────▼──────────────┐
    │ Create/Update       │
    │ user_health_profiles│
    └──────┬──────────────┘
           │
    ┌──────▼──────────────┐
    │ Add to              │
    │ health_metric_      │
    │ history (timestamp) │
    └──────┬──────────────┘
           │
    ┌──────▼──────────┐
    │ Show Toast      │
    │ "Saved!"        │
    └──────┬──────────┘
           │
    ┌──────▼──────────┐
    │ Navigate to     │
    │ HealthScreen    │
    └─────────────────┘
           │
           ▼
    ┌──────────────────┐
    │ _loadData()      │
    │ Fetch from DB    │
    │ Update UI        │
    └──────────────────┘
```

---

## 3. HealthScreen Display Logic

```
HealthScreen
      │
      ├─ initState() ──► _loadData()
      │                  └─► Fetch user_health_profiles
      │                  └─► Fetch health_metric_history
      │
      ▼
 ┌─ _isLoading? ─────► Show Loading Spinner
 │
 ├─ hasData? ────────┐
 │                   │
 │              ┌────▼──────────────┐
 │              │ _buildEmptyState()│
 │              │ ├── Icon          │
 │              │ ├── Message       │
 │              │ ├── Add Button    │
 │              │ └── Sync Button   │
 │              └───────────────────┘
 │
 └─ has Data? ──────┐
                    │
                ┌───▼──────────────────┐
                │ _buildContent()      │
                │ ├── _buildHeader()   │
                │ ├── _buildBMICard()  │
                │ ├── _buildVitalsRow()│
                │ ├── _buildChart()    │
                │ └── Refresh Button   │
                └──────────────────────┘
```

---

## 4. Weekly Chart Generation

```
_weeklyMetrics[] (from DB)
      │
      ▼
┌──────────────────────────┐
│ Group by date            │
│ metricsGroupedByDate = {  │
│   "2025-11-15": [m1,m2], │
│   "2025-11-16": [m3],    │
│   ...                    │
│ }                        │
└──────────┬───────────────┘
           │
           ▼
┌────────────────────────────┐
│ For each date:             │
│ 1. Calculate avg value     │
│ 2. Normalize (0-100)       │
│ 3. Calc bar height         │
│ 4. Create bar widget       │
└────────────┬───────────────┘
             │
             ▼
┌──────────────────────┐
│ ListView (horizontal)│
│ ├── Bar (15th)       │
│ ├── Bar (16th)       │
│ ├── Bar (17th)       │
│ └── ...              │
└──────────────────────┘
             │
             ▼
        Display on UI
```

---

## 5. Database Schema

```
┌─────────────────────────────────────────┐
│        user_health_profiles             │
├─────────────────────────────────────────┤
│ PK: id (UUID)                           │
│ FK: user_id (UUID) → users              │
│ ──────────────────────────────────────  │
│ bmi (DECIMAL)                           │
│ blood_pressure_systolic (SMALLINT)      │
│ blood_pressure_diastolic (SMALLINT)     │
│ heart_rate (SMALLINT)                   │
│ glucose_level (DECIMAL)                 │
│ cholesterol_level (DECIMAL)             │
│ notes (TEXT)                            │
│ ──────────────────────────────────────  │
│ last_updated_at (TIMESTAMP)             │
│ created_at (TIMESTAMP)                  │
│ updated_at (TIMESTAMP)                  │
│ ──────────────────────────────────────  │
│ UNIQUE(user_id)                         │
│ RLS: Enabled ✓                          │
└─────────────────────────────────────────┘
          │
          │ 1:N
          │
┌─────────────────────────────────────────┐
│    health_metric_history                │
├─────────────────────────────────────────┤
│ PK: id (UUID)                           │
│ FK: user_id (UUID) → users              │
│ ──────────────────────────────────────  │
│ metric_type (VARCHAR)                   │
│   - 'bmi'                               │
│   - 'blood_pressure'                    │
│   - 'heart_rate'                        │
│   - 'glucose'                           │
│   - 'cholesterol'                       │
│ ──────────────────────────────────────  │
│ value_numeric (DECIMAL)                 │
│ value_secondary (SMALLINT)              │
│ unit (VARCHAR)                          │
│ source (VARCHAR)                        │
│   - 'manual'                            │
│   - 'mi_fitness'                        │
│   - 'redmi_watch'                       │
│ notes (TEXT)                            │
│ ──────────────────────────────────────  │
│ measured_at (TIMESTAMP) ⭐              │
│ created_at (TIMESTAMP)                  │
│ updated_at (TIMESTAMP)                  │
│ ──────────────────────────────────────  │
│ Indexes:                                │
│ - user_id                               │
│ - metric_type                           │
│ - measured_at DESC                      │
│ - (user_id, metric_type, measured_at)   │
│ RLS: Enabled ✓                          │
└─────────────────────────────────────────┘
```

---

## 6. Mi Fitness Integration Flow

```
┌─────────────────┐
│   User clicks   │
│ "Sync from      │
│ Redmi Watch"    │
└────────┬────────┘
         │
    ┌────▼──────────────────┐
    │ MiFitnessIntegration  │
    │ Service               │
    └────┬───────┬──────────┘
         │       │
    ┌────▼──┐ ┌──▼────────┐
    │OAuth  │ │Mi Fitness │
    │Flow   │ │API Calls  │
    └────┬──┘ └──┬────────┘
         │       │
    ┌────▼───────▼──────────────┐
    │ Authentication             │
    │ ├── Get Auth Code          │
    │ ├── Exchange for Token     │
    │ └── Save Token (Secure)    │
    └────┬─────────────────────┘
         │
    ┌────▼─────────────────────┐
    │ Fetch Data               │
    │ ├── Daily Steps          │
    │ ├── Heart Rate           │
    │ ├── Sleep Data           │
    │ └── Other Metrics        │
    └────┬───────────────────┘
         │
    ┌────▼───────────────────┐
    │ Convert to              │
    │ HealthMetric Format     │
    └────┬───────────────────┘
         │
    ┌────▼────────────────────┐
    │ Save to Database        │
    │ ├── health_metric_      │
    │ │   history             │
    │ └── Update profile      │
    │     (if needed)         │
    └────┬────────────────────┘
         │
    ┌────▼──────────────────┐
    │ Notify User           │
    │ "Sync Complete!"      │
    └────┬──────────────────┘
         │
    ┌────▼──────────────────┐
    │ Refresh HealthScreen  │
    │ Display New Data      │
    └──────────────────────┘
```

---

## 7. Class Dependencies

```
┌─────────────────────────────────┐
│      HealthScreen               │
│  (Main Display)                 │
└─────────────┬───────────────────┘
              │
         ┌────▼────────────────────────────┐
         │ HealthMetricsRepository         │
         │ (Data Access Layer)             │
         │ ├── get/create/update Profile   │
         │ ├── add/get Metrics             │
         │ └── query by time period        │
         └─────┬─────────┬──────────────────┘
               │         │
      ┌────────▼──┐  ┌───▼────────────┐
      │HealthProfile (Model)         │
      │ - bmi                         │
      │ - bloodPressure              │
      │ - heartRate                  │
      │ - glucoseLevel               │
      │ - cholesterolLevel           │
      │ - hasData: bool              │
      └────────────┘  │ └───────────────┘
                      │
              ┌───────▼──────────┐
              │ HealthMetric     │
              │ (Model)          │
              │ - metricType     │
              │ - valueNumeric   │
              │ - measured_at    │
              │ - source         │
              └──────────────────┘
                      │
              ┌───────▼───────────────────┐
              │   Supabase Client         │
              │ (PostgreSQL Database)     │
              └───────────────────────────┘
```

---

## 8. State Management Flow

```
HealthScreen
    │
    ├─ _healthProfile: HealthProfile?
    │   └─ Controls display of current data
    │
    ├─ _weeklyMetrics: List<HealthMetric>
    │   └─ Used for weekly chart
    │
    ├─ _isLoading: bool
    │   └─ Shows/hides loading spinner
    │
    └─ _loadData()
       ├─ Sets _isLoading = true
       ├─ Fetches user_health_profiles
       ├─ Fetches health_metric_history (7 days)
       ├─ Updates _healthProfile & _weeklyMetrics
       └─ Sets _isLoading = false
          └─ Triggers rebuild → UI updates
```

---

## 9. Testing Flow

```
Unit Tests
├── Models
│   ├── HealthMetric.fromJson()
│   └── HealthProfile.hasData
│
├── Repository
│   ├── getUserHealthProfile()
│   ├── addHealthMetric()
│   ├── getWeeklyMetrics()
│   └── getMetricAggregate()
│
└── UI
    ├── Empty state display
    ├── Chart calculation
    ├── Navigation
    └── Data persistence

Integration Tests
├── End-to-end manual entry
├── Database operations
├── UI refresh after save
└── Time-based filtering

E2E Tests
├── Full user flow
├── Mi Fitness sync
├── App restart persistence
└── Multiple users
```

---

**Legend:**
- `PK` = Primary Key
- `FK` = Foreign Key
- `RLS` = Row-Level Security
- `│` = Relations/Flow
- `▼` = Direction of flow
- `├──` = Component
- `⭐` = Important field
- `✓` = Enabled/Complete
- `⏳` = In Progress
- `⚠️` = Warning/Todo

---

**Last Updated:** 2025-11-21
