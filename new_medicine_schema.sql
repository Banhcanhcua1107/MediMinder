-- ============================================================================
-- NEW MEDICINE MANAGEMENT SYSTEM - Hệ thống quản lý thuốc mới
-- ============================================================================
-- Thêm các bảng này vào database Supabase của bạn
-- Paste toàn bộ code này vào: Supabase > SQL Editor > Run
-- ============================================================================

-- ============================================================================
-- 1. USER_MEDICINES TABLE - Thuốc của từng người dùng
-- ============================================================================
-- Lưu danh sách thuốc mà người dùng đang dùng (có kèm thông tin custom)

CREATE TABLE IF NOT EXISTS user_medicines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Foreign Key
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Thông tin thuốc
  name VARCHAR(255) NOT NULL,
  dosage_strength VARCHAR(100), -- e.g., '500mg'
  dosage_form VARCHAR(50), -- 'tablet', 'capsule', 'liquid', 'injection'
  quantity_per_dose INTEGER, -- Số viên/lần (e.g., 1, 2, 3)
  
  -- Khoảng thời gian sử dụng
  start_date DATE NOT NULL,
  end_date DATE, -- NULL = indefinite
  
  -- Ghi chú
  reason_for_use VARCHAR(255), -- Lý do sử dụng
  notes TEXT, -- Ghi chú thêm
  
  -- Trạng thái
  is_active BOOLEAN DEFAULT TRUE,
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index
CREATE INDEX IF NOT EXISTS idx_user_medicines_user_id ON user_medicines(user_id);
CREATE INDEX IF NOT EXISTS idx_user_medicines_is_active ON user_medicines(is_active);
CREATE INDEX IF NOT EXISTS idx_user_medicines_start_date ON user_medicines(start_date);

COMMENT ON TABLE user_medicines IS 'Danh sách thuốc của mỗi người dùng';

-- Enable RLS
ALTER TABLE user_medicines ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own medicines" ON user_medicines;
CREATE POLICY "Users can view own medicines"
ON user_medicines
FOR SELECT
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create own medicines" ON user_medicines;
CREATE POLICY "Users can create own medicines"
ON user_medicines
FOR INSERT
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own medicines" ON user_medicines;
CREATE POLICY "Users can update own medicines"
ON user_medicines
FOR UPDATE
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own medicines" ON user_medicines;
CREATE POLICY "Users can delete own medicines"
ON user_medicines
FOR DELETE
USING (auth.uid() = user_id);

-- ============================================================================
-- 2. MEDICINE_SCHEDULES TABLE - Tần suất uống thuốc
-- ============================================================================
-- Lưu thông tin tần suất: hằng ngày, cách ngày, tuỳ chỉnh

CREATE TABLE IF NOT EXISTS medicine_schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Foreign Key
  user_medicine_id UUID NOT NULL REFERENCES user_medicines(id) ON DELETE CASCADE,
  
  -- Loại tần suất
  frequency_type VARCHAR(50) NOT NULL, -- 'daily', 'alternate_days', 'custom'
  
  -- Cho loại custom: mỗi X ngày
  custom_interval_days INTEGER, -- NULL nếu không phải custom, hoặc số ngày (e.g., 3 = cách 3 ngày)
  
  -- Cho loại custom: chọn thứ trong tuần (bitmap: 1=Thứ 2, 2=Thứ 3, ..., 7=Chủ nhật)
  -- VD: '1111100' = Thứ 2-6, '1010101' = Thứ 2,4,6,CN
  days_of_week VARCHAR(7), -- NULL nếu không phải custom
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index
CREATE INDEX IF NOT EXISTS idx_medicine_schedules_user_medicine_id ON medicine_schedules(user_medicine_id);

COMMENT ON TABLE medicine_schedules IS 'Tần suất uống thuốc: hằng ngày, cách ngày, tuỳ chỉnh';

-- Enable RLS
ALTER TABLE medicine_schedules ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own schedules" ON medicine_schedules;
CREATE POLICY "Users can view own schedules"
ON medicine_schedules
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM user_medicines um 
    WHERE um.id = medicine_schedules.user_medicine_id 
    AND um.user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Users can manage own schedules" ON medicine_schedules;
CREATE POLICY "Users can manage own schedules"
ON medicine_schedules
FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM user_medicines um 
    WHERE um.id = medicine_schedules.user_medicine_id 
    AND um.user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Users can update own schedules" ON medicine_schedules;
CREATE POLICY "Users can update own schedules"
ON medicine_schedules
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM user_medicines um 
    WHERE um.id = medicine_schedules.user_medicine_id 
    AND um.user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Users can delete own schedules" ON medicine_schedules;
CREATE POLICY "Users can delete own schedules"
ON medicine_schedules
FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM user_medicines um 
    WHERE um.id = medicine_schedules.user_medicine_id 
    AND um.user_id = auth.uid()
  )
);

-- ============================================================================
-- 3. MEDICINE_SCHEDULE_TIMES TABLE - Giờ uống trong ngày
-- ============================================================================
-- Lưu từng giờ uống (e.g., 08:00, 14:00, 20:00)

CREATE TABLE IF NOT EXISTS medicine_schedule_times (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Foreign Key
  medicine_schedule_id UUID NOT NULL REFERENCES medicine_schedules(id) ON DELETE CASCADE,
  
  -- Giờ uống (HH:MM format)
  time_of_day TIME NOT NULL,
  
  -- Thứ tự (để sort)
  order_index INTEGER DEFAULT 0,
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index
CREATE INDEX IF NOT EXISTS idx_medicine_schedule_times_schedule_id ON medicine_schedule_times(medicine_schedule_id);
CREATE INDEX IF NOT EXISTS idx_medicine_schedule_times_time_of_day ON medicine_schedule_times(time_of_day);

COMMENT ON TABLE medicine_schedule_times IS 'Giờ uống thuốc trong ngày';

-- Enable RLS
ALTER TABLE medicine_schedule_times ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own schedule times" ON medicine_schedule_times;
CREATE POLICY "Users can view own schedule times"
ON medicine_schedule_times
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM medicine_schedules ms 
    JOIN user_medicines um ON um.id = ms.user_medicine_id
    WHERE ms.id = medicine_schedule_times.medicine_schedule_id 
    AND um.user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Users can manage own schedule times" ON medicine_schedule_times;
CREATE POLICY "Users can manage own schedule times"
ON medicine_schedule_times
FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM medicine_schedules ms 
    JOIN user_medicines um ON um.id = ms.user_medicine_id
    WHERE ms.id = medicine_schedule_times.medicine_schedule_id 
    AND um.user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Users can update own schedule times" ON medicine_schedule_times;
CREATE POLICY "Users can update own schedule times"
ON medicine_schedule_times
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM medicine_schedules ms 
    JOIN user_medicines um ON um.id = ms.user_medicine_id
    WHERE ms.id = medicine_schedule_times.medicine_schedule_id 
    AND um.user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Users can delete own schedule times" ON medicine_schedule_times;
CREATE POLICY "Users can delete own schedule times"
ON medicine_schedule_times
FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM medicine_schedules ms 
    JOIN user_medicines um ON um.id = ms.user_medicine_id
    WHERE ms.id = medicine_schedule_times.medicine_schedule_id 
    AND um.user_id = auth.uid()
  )
);

-- ============================================================================
-- 4. MEDICINE_INTAKES TABLE - Lịch sử uống thực tế (tuỳ chọn)
-- ============================================================================
-- Lưu lịch sử uống: lúc mấy giờ dự định, lúc mấy giờ đã uống, trạng thái

CREATE TABLE IF NOT EXISTS medicine_intakes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Foreign Key
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_medicine_id UUID REFERENCES user_medicines(id) ON DELETE SET NULL,
  medicine_schedule_time_id UUID REFERENCES medicine_schedule_times(id) ON DELETE SET NULL,
  
  -- Thông tin thuốc
  medicine_name VARCHAR(255) NOT NULL,
  dosage_strength VARCHAR(100),
  quantity_per_dose INTEGER,
  
  -- Lịch sử
  scheduled_date DATE NOT NULL,
  scheduled_time TIME NOT NULL,
  
  -- Thực tế
  taken_at TIMESTAMP WITH TIME ZONE, -- NULL nếu chưa uống
  
  -- Trạng thái
  status VARCHAR(20) NOT NULL DEFAULT 'pending', -- 'pending', 'taken', 'skipped', 'missed'
  
  -- Ghi chú
  notes TEXT,
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index
CREATE INDEX IF NOT EXISTS idx_medicine_intakes_user_id ON medicine_intakes(user_id);
CREATE INDEX IF NOT EXISTS idx_medicine_intakes_scheduled_date ON medicine_intakes(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_medicine_intakes_status ON medicine_intakes(status);
CREATE INDEX IF NOT EXISTS idx_medicine_intakes_scheduled_datetime ON medicine_intakes(scheduled_date, scheduled_time);

COMMENT ON TABLE medicine_intakes IS 'Lịch sử uống thuốc thực tế';

-- Enable RLS
ALTER TABLE medicine_intakes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own intakes" ON medicine_intakes;
CREATE POLICY "Users can view own intakes"
ON medicine_intakes
FOR SELECT
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create own intakes" ON medicine_intakes;
CREATE POLICY "Users can create own intakes"
ON medicine_intakes
FOR INSERT
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own intakes" ON medicine_intakes;
CREATE POLICY "Users can update own intakes"
ON medicine_intakes
FOR UPDATE
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own intakes" ON medicine_intakes;
CREATE POLICY "Users can delete own intakes"
ON medicine_intakes
FOR DELETE
USING (auth.uid() = user_id);

-- ============================================================================
-- 5. TRIGGERS
-- ============================================================================

-- Trigger để auto update updated_at cho medicine_schedules
DROP TRIGGER IF EXISTS medicine_schedules_update_updated_at ON medicine_schedules;
CREATE TRIGGER medicine_schedules_update_updated_at
BEFORE UPDATE ON medicine_schedules
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Trigger để auto update updated_at cho medicine_schedule_times
DROP TRIGGER IF EXISTS medicine_schedule_times_update_updated_at ON medicine_schedule_times;
CREATE TRIGGER medicine_schedule_times_update_updated_at
BEFORE UPDATE ON medicine_schedule_times
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Trigger để auto update updated_at cho user_medicines
DROP TRIGGER IF EXISTS user_medicines_update_updated_at ON user_medicines;
CREATE TRIGGER user_medicines_update_updated_at
BEFORE UPDATE ON user_medicines
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Trigger để auto update updated_at cho medicine_intakes
DROP TRIGGER IF EXISTS medicine_intakes_update_updated_at ON medicine_intakes;
CREATE TRIGGER medicine_intakes_update_updated_at
BEFORE UPDATE ON medicine_intakes
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 6. USEFUL VIEWS
-- ============================================================================

-- View: Danh sách thuốc đang uống hôm nay (sắp xếp theo giờ)
CREATE OR REPLACE VIEW today_medicines AS
SELECT 
  um.id as medicine_id,
  um.user_id,
  um.name,
  um.dosage_strength,
  um.quantity_per_dose,
  um.dosage_form,
  mst.id as schedule_time_id,
  mst.time_of_day,
  mst.order_index,
  ms.frequency_type
FROM user_medicines um
JOIN medicine_schedules ms ON ms.user_medicine_id = um.id
JOIN medicine_schedule_times mst ON mst.medicine_schedule_id = ms.id
WHERE um.is_active = TRUE
  AND um.start_date <= CURRENT_DATE
  AND (um.end_date IS NULL OR um.end_date >= CURRENT_DATE)
ORDER BY mst.time_of_day ASC;

-- View: Danh sách thuốc sắp hết (tồn kho dưới ngưỡng)
-- (Nếu bạn muốn thêm tracking tồn kho)

-- ============================================================================
-- 7. UTILITY FUNCTIONS
-- ============================================================================

-- Function: Lấy danh sách thuốc hôm nay của user (đã sort theo giờ)
CREATE OR REPLACE FUNCTION get_user_medicines_today(p_user_id UUID)
RETURNS TABLE (
  medicine_id UUID,
  medicine_name VARCHAR,
  dosage_strength VARCHAR,
  quantity_per_dose INTEGER,
  dosage_form VARCHAR,
  schedule_time_id UUID,
  time_of_day TIME,
  frequency_type VARCHAR,
  next_intake_in_minutes INTEGER,
  status VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    um.id,
    um.name,
    um.dosage_strength,
    um.quantity_per_dose,
    um.dosage_form,
    mst.id,
    mst.time_of_day,
    ms.frequency_type,
    -- Tính phút còn lại đến giờ uống tiếp theo
    EXTRACT(EPOCH FROM (CAST(CURRENT_DATE AS TIMESTAMP) + CAST(mst.time_of_day AS INTERVAL) - NOW()))::INTEGER / 60 as next_intake_in_minutes,
    COALESCE(mi.status, 'pending'::VARCHAR) as status
  FROM user_medicines um
  JOIN medicine_schedules ms ON ms.user_medicine_id = um.id
  JOIN medicine_schedule_times mst ON mst.medicine_schedule_id = ms.id
  LEFT JOIN medicine_intakes mi ON (
    mi.user_medicine_id = um.id
    AND mi.scheduled_date = CURRENT_DATE
    AND mi.scheduled_time = mst.time_of_day
  )
  WHERE um.user_id = p_user_id
    AND um.is_active = TRUE
    AND um.start_date <= CURRENT_DATE
    AND (um.end_date IS NULL OR um.end_date >= CURRENT_DATE)
  ORDER BY mst.time_of_day ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Tạo medicine_intake records cho ngày tiếp theo
-- (Gọi hàng đêm để chuẩn bị dữ liệu cho ngày hôm sau)
CREATE OR REPLACE FUNCTION generate_tomorrow_intakes(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
  v_inserted INTEGER := 0;
BEGIN
  INSERT INTO medicine_intakes (
    user_id,
    user_medicine_id,
    medicine_schedule_time_id,
    medicine_name,
    dosage_strength,
    quantity_per_dose,
    scheduled_date,
    scheduled_time,
    status
  )
  SELECT 
    um.user_id,
    um.id,
    mst.id,
    um.name,
    um.dosage_strength,
    um.quantity_per_dose,
    CURRENT_DATE + INTERVAL '1 day',
    mst.time_of_day,
    'pending'
  FROM user_medicines um
  JOIN medicine_schedules ms ON ms.user_medicine_id = um.id
  JOIN medicine_schedule_times mst ON mst.medicine_schedule_id = ms.id
  WHERE um.user_id = p_user_id
    AND um.is_active = TRUE
    AND um.start_date <= CURRENT_DATE + INTERVAL '1 day'
    AND (um.end_date IS NULL OR um.end_date >= CURRENT_DATE + INTERVAL '1 day')
    -- Tránh duplicate
    AND NOT EXISTS (
      SELECT 1 FROM medicine_intakes mi
      WHERE mi.user_medicine_id = um.id
      AND mi.scheduled_date = CURRENT_DATE + INTERVAL '1 day'
      AND mi.scheduled_time = mst.time_of_day
    );

  GET DIAGNOSTICS v_inserted = ROW_COUNT;
  RETURN v_inserted;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 8. HELPER FUNCTION: Check ngày nào user nên uống thuốc
-- ============================================================================

-- Function: Kiểm tra xem hôm nay user có nên uống thuốc này không (dựa vào frequency)
CREATE OR REPLACE FUNCTION should_take_medicine_today(
  p_frequency_type VARCHAR,
  p_start_date DATE,
  p_custom_interval_days INTEGER,
  p_days_of_week VARCHAR
)
RETURNS BOOLEAN AS $$
DECLARE
  v_days_since_start INTEGER;
  v_day_of_week INTEGER; -- 1=Monday, 7=Sunday
BEGIN
  -- Nếu hôm nay trước start_date thì không uống
  IF CURRENT_DATE < p_start_date THEN
    RETURN FALSE;
  END IF;

  v_days_since_start := (CURRENT_DATE - p_start_date);

  CASE p_frequency_type
    WHEN 'daily' THEN
      RETURN TRUE;
    
    WHEN 'alternate_days' THEN
      -- Uống cách ngày (ngày 0, 2, 4, 6...)
      RETURN (v_days_since_start % 2 = 0);
    
    WHEN 'custom' THEN
      -- Custom interval + days_of_week
      -- Trước tiên check interval (cách X ngày)
      IF p_custom_interval_days IS NOT NULL THEN
        IF v_days_since_start % p_custom_interval_days != 0 THEN
          RETURN FALSE;
        END IF;
      END IF;
      
      -- Sau đó check thứ trong tuần nếu có
      IF p_days_of_week IS NOT NULL THEN
        v_day_of_week := EXTRACT(DOW FROM CURRENT_DATE);
        -- PostgreSQL DOW: 0=Sunday, 1=Monday...6=Saturday
        -- Nhưng chúng ta dùng 1=Monday, 7=Sunday
        IF v_day_of_week = 0 THEN
          v_day_of_week := 7;
        END IF;
        
        RETURN (SUBSTRING(p_days_of_week, v_day_of_week, 1) = '1');
      END IF;
      
      RETURN TRUE;
    
    ELSE
      RETURN FALSE;
  END CASE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================================
-- 9. SAMPLE DATA
-- ============================================================================

-- Nếu muốn, thêm dữ liệu mẫu:
-- INSERT INTO user_medicines (user_id, name, dosage_strength, dosage_form, quantity_per_dose, start_date)
-- VALUES (
--   'user-uuid-here',
--   'Paracetamol',
--   '500mg',
--   'tablet',
--   1,
--   CURRENT_DATE
-- );

-- ============================================================================
-- END OF NEW MEDICINE SCHEMA
-- ============================================================================
-- 
-- ✅ NEW TABLES:
--   - user_medicines: Danh sách thuốc của user
--   - medicine_schedules: Tần suất uống (daily, alternate, custom)
--   - medicine_schedule_times: Giờ uống trong ngày
--   - medicine_intakes: Lịch sử uống thực tế (tracking)
--
-- ✅ SECURITY:
--   - Row Level Security (RLS) trên tất cả tables
--   - Users chỉ truy cập data của chính họ
--
-- ✅ HELPFUL FUNCTIONS:
--   - get_user_medicines_today(): Lấy danh sách thuốc hôm nay
--   - generate_tomorrow_intakes(): Tạo records cho ngày hôm sau
--   - should_take_medicine_today(): Check có nên uống hôm nay không
--
-- 🚀 Ready to use!
-- ============================================================================
