-- ============================================================================
-- MIGRATION: ADD HEALTH METRICS TRACKING
-- ============================================================================
-- File này chứa các bảng để lưu trữ chỉ số sức khỏe của người dùng
-- Paste vào Supabase SQL Editor > Run
-- ============================================================================

-- ============================================================================
-- 1. USER_HEALTH_PROFILES TABLE - Thông tin sức khỏe hiện tại
-- ============================================================================
-- Lưu thông tin sức khỏe tổng quát của người dùng

CREATE TABLE IF NOT EXISTS user_health_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  
  -- Measurements - Lưu giá trị mới nhất
  bmi DECIMAL(5, 2),
  blood_pressure_systolic SMALLINT, -- Huyết áp tâm thu (e.g., 120)
  blood_pressure_diastolic SMALLINT, -- Huyết áp tâm trương (e.g., 80)
  heart_rate SMALLINT, -- Nhịp tim (BPM)
  glucose_level DECIMAL(6, 2), -- mg/dL
  cholesterol_level DECIMAL(6, 2), -- mg/dL
  
  -- Metadata
  notes TEXT,
  last_updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE(user_id)
);

-- Index
CREATE INDEX IF NOT EXISTS idx_user_health_profiles_user_id ON user_health_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_health_profiles_last_updated_at ON user_health_profiles(last_updated_at DESC);

COMMENT ON TABLE user_health_profiles IS 'Thông tin sức khỏe hiện tại của người dùng (Lưu giá trị mới nhất)';

-- RLS Policy
ALTER TABLE user_health_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own health profiles" ON user_health_profiles;
CREATE POLICY "Users can view own health profiles"
ON user_health_profiles
FOR SELECT
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create own health profiles" ON user_health_profiles;
CREATE POLICY "Users can create own health profiles"
ON user_health_profiles
FOR INSERT
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own health profiles" ON user_health_profiles;
CREATE POLICY "Users can update own health profiles"
ON user_health_profiles
FOR UPDATE
USING (auth.uid() = user_id);

-- ============================================================================
-- 2. HEALTH_METRIC_HISTORY TABLE - Lịch sử chi tiết các chỉ số sức khỏe
-- ============================================================================
-- Lưu lịch sử từng lần đo (để theo dõi xu hướng, vẽ biểu đồ)

CREATE TABLE IF NOT EXISTS health_metric_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  
  -- Measurement Type (để có thể store các loại measurement khác nhau)
  metric_type VARCHAR(50) NOT NULL, -- 'bmi', 'blood_pressure', 'heart_rate', 'glucose', 'cholesterol'
  
  -- Values
  value_numeric DECIMAL(10, 2), -- Giá trị chính (e.g., 21.5 cho BMI, 72 cho heart_rate)
  value_secondary SMALLINT, -- Giá trị phụ (e.g., diastolic pressure nếu blood_pressure)
  unit VARCHAR(20), -- Unit (e.g., 'kg/m²', 'mmHg', 'BPM', 'mg/dL')
  
  -- Source & Metadata
  source VARCHAR(50), -- 'manual', 'mi_fitness', 'redmi_watch', 'garmin', etc.
  notes TEXT,
  
  -- Timestamps
  measured_at TIMESTAMP WITH TIME ZONE NOT NULL, -- Thời gian đo (có thể là ngày hôm trước)
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  
  -- Index
  CONSTRAINT check_metric_type CHECK (metric_type IN ('bmi', 'blood_pressure', 'heart_rate', 'glucose', 'cholesterol', 'weight'))
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_health_metric_history_user_id ON health_metric_history(user_id);
CREATE INDEX IF NOT EXISTS idx_health_metric_history_metric_type ON health_metric_history(metric_type);
CREATE INDEX IF NOT EXISTS idx_health_metric_history_measured_at ON health_metric_history(measured_at DESC);
CREATE INDEX IF NOT EXISTS idx_health_metric_history_source ON health_metric_history(source);
CREATE INDEX IF NOT EXISTS idx_health_metric_history_user_metric_date ON health_metric_history(user_id, metric_type, measured_at DESC);

COMMENT ON TABLE health_metric_history IS 'Lịch sử các chỉ số sức khỏe của người dùng (chi tiết từng lần đo)';

-- RLS Policy
ALTER TABLE health_metric_history ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own health history" ON health_metric_history;
CREATE POLICY "Users can view own health history"
ON health_metric_history
FOR SELECT
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create own health history" ON health_metric_history;
CREATE POLICY "Users can create own health history"
ON health_metric_history
FOR INSERT
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own health history" ON health_metric_history;
CREATE POLICY "Users can update own health history"
ON health_metric_history
FOR UPDATE
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own health history" ON health_metric_history;
CREATE POLICY "Users can delete own health history"
ON health_metric_history
FOR DELETE
USING (auth.uid() = user_id);

-- ============================================================================
-- 3. TRIGGERS - Auto update updated_at
-- ============================================================================

DROP TRIGGER IF EXISTS user_health_profiles_update_updated_at ON user_health_profiles;
CREATE TRIGGER user_health_profiles_update_updated_at
BEFORE UPDATE ON user_health_profiles
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS health_metric_history_update_updated_at ON health_metric_history;
CREATE TRIGGER health_metric_history_update_updated_at
BEFORE UPDATE ON health_metric_history
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 4. USEFUL VIEWS
-- ============================================================================

-- View: Latest metrics for each type (hôm nay)
CREATE OR REPLACE VIEW today_health_metrics AS
SELECT 
  user_id,
  metric_type,
  value_numeric,
  value_secondary,
  unit,
  source,
  measured_at
FROM health_metric_history
WHERE measured_at::date = CURRENT_DATE
ORDER BY measured_at DESC;

-- View: Weekly progress (7 ngày gần nhất)
CREATE OR REPLACE VIEW weekly_health_metrics AS
SELECT 
  user_id,
  metric_type,
  value_numeric,
  value_secondary,
  measured_at::date as measurement_date,
  source
FROM health_metric_history
WHERE measured_at >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY measured_at DESC;

-- View: Monthly progress (30 ngày gần nhất)
CREATE OR REPLACE VIEW monthly_health_metrics AS
SELECT 
  user_id,
  metric_type,
  value_numeric,
  value_secondary,
  measured_at::date as measurement_date,
  source
FROM health_metric_history
WHERE measured_at >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY measured_at DESC;

-- ============================================================================
-- 5. UTILITY FUNCTIONS
-- ============================================================================

-- Function: Get latest metric value for a user
CREATE OR REPLACE FUNCTION get_latest_health_metric(
  p_user_id UUID,
  p_metric_type VARCHAR
)
RETURNS TABLE (
  value_numeric DECIMAL,
  value_secondary SMALLINT,
  unit VARCHAR,
  measured_at TIMESTAMP WITH TIME ZONE,
  source VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    h.value_numeric,
    h.value_secondary,
    h.unit,
    h.measured_at,
    h.source
  FROM health_metric_history h
  WHERE h.user_id = p_user_id
    AND h.metric_type = p_metric_type
  ORDER BY h.measured_at DESC
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Function: Get weekly average for a metric
CREATE OR REPLACE FUNCTION get_weekly_metric_average(
  p_user_id UUID,
  p_metric_type VARCHAR
)
RETURNS TABLE (
  avg_value DECIMAL,
  min_value DECIMAL,
  max_value DECIMAL,
  count_records BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    ROUND(AVG(h.value_numeric)::numeric, 2),
    MIN(h.value_numeric),
    MAX(h.value_numeric),
    COUNT(*)
  FROM health_metric_history h
  WHERE h.user_id = p_user_id
    AND h.metric_type = p_metric_type
    AND h.measured_at >= CURRENT_DATE - INTERVAL '7 days';
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
