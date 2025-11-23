-- ============================================================================
-- MIGRATION: ADD REMINDER SETTINGS & NOTIFICATION TRACKING
-- ============================================================================
-- Cập nhật hệ thống notification để support:
-- 1. User-defined reminder time (trước bao nhiêu phút nhắc)
-- 2. Notification tracking (đã gửi, missed, repeat)
-- 3. Notification state management
-- ============================================================================

-- ============================================================================
-- 1. ALTER TABLE: medicine_schedule_times - Thêm reminder settings
-- ============================================================================

-- Thêm cột: Trước bao nhiêu phút sẽ nhắc (default 15 phút)
ALTER TABLE medicine_schedule_times 
ADD COLUMN IF NOT EXISTS reminder_minutes_before INTEGER DEFAULT 15;

-- Thêm cột: Đã enable nhắc nhở cho giờ này không
ALTER TABLE medicine_schedule_times 
ADD COLUMN IF NOT EXISTS reminder_enabled BOOLEAN DEFAULT true;

-- Comment
COMMENT ON COLUMN medicine_schedule_times.reminder_minutes_before IS 'Nhắc nhở trước X phút (5, 10, 15, 30, 60)';
COMMENT ON COLUMN medicine_schedule_times.reminder_enabled IS 'Có bật nhắc nhở cho giờ uống này không';

-- ============================================================================
-- 2. CREATE TABLE: notification_tracking - Track thông báo
-- ============================================================================
-- Lưu lịch sử thông báo được gửi, số lần nhắc nhở lặp lại

CREATE TABLE IF NOT EXISTS notification_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Foreign Keys
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_medicine_id UUID NOT NULL REFERENCES user_medicines(id) ON DELETE CASCADE,
  medicine_schedule_time_id UUID NOT NULL REFERENCES medicine_schedule_times(id) ON DELETE CASCADE,
  medicine_intake_id UUID REFERENCES medicine_intakes(id) ON DELETE SET NULL,
  
  -- Thời gian
  scheduled_date DATE NOT NULL,
  scheduled_time TIME NOT NULL,
  reminder_scheduled_at TIMESTAMP WITH TIME ZONE NOT NULL,
  
  -- Trạng thái thông báo
  notification_status VARCHAR(50) NOT NULL DEFAULT 'pending', -- 'pending', 'sent', 'failed'
  notification_sent_at TIMESTAMP WITH TIME ZONE,
  
  -- Tracking lặp lại
  repeat_count INTEGER DEFAULT 0, -- Số lần đã nhắc nhở lặp
  last_reminder_at TIMESTAMP WITH TIME ZONE, -- Lần nhắc gần nhất
  next_reminder_at TIMESTAMP WITH TIME ZONE, -- Lần nhắc tiếp theo (+ 10 phút)
  
  -- Intake tracking
  intake_status VARCHAR(50) NOT NULL DEFAULT 'pending', -- 'pending', 'taken', 'skipped', 'missed'
  taken_at TIMESTAMP WITH TIME ZONE, -- Khi user bấm "Đã uống"
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index
CREATE INDEX IF NOT EXISTS idx_notification_tracking_user_id ON notification_tracking(user_id);
CREATE INDEX IF NOT EXISTS idx_notification_tracking_scheduled_date ON notification_tracking(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_notification_tracking_notification_status ON notification_tracking(notification_status);
CREATE INDEX IF NOT EXISTS idx_notification_tracking_intake_status ON notification_tracking(intake_status);
CREATE INDEX IF NOT EXISTS idx_notification_tracking_reminder_datetime ON notification_tracking(scheduled_date, scheduled_time);

COMMENT ON TABLE notification_tracking IS 'Track thông báo nhắc nhở: gửi, lặp lại, trạng thái uống';

-- Enable RLS
ALTER TABLE notification_tracking ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own notification tracking" ON notification_tracking;
CREATE POLICY "Users can view own notification tracking"
ON notification_tracking
FOR SELECT
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create own notification tracking" ON notification_tracking;
CREATE POLICY "Users can create own notification tracking"
ON notification_tracking
FOR INSERT
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own notification tracking" ON notification_tracking;
CREATE POLICY "Users can update own notification tracking"
ON notification_tracking
FOR UPDATE
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own notification tracking" ON notification_tracking;
CREATE POLICY "Users can delete own notification tracking"
ON notification_tracking
FOR DELETE
USING (auth.uid() = user_id);

-- ============================================================================
-- 3. CREATE TRIGGER: auto update updated_at cho notification_tracking
-- ============================================================================

DROP TRIGGER IF EXISTS notification_tracking_update_updated_at ON notification_tracking;
CREATE TRIGGER notification_tracking_update_updated_at
BEFORE UPDATE ON notification_tracking
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 4. CREATE FUNCTION: check_and_schedule_reminders
-- ============================================================================
-- Function để check medicine reminder times trong ngày và schedule notifications

CREATE OR REPLACE FUNCTION check_and_schedule_reminders(
  p_user_id UUID,
  p_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
  medicine_id UUID,
  medicine_name VARCHAR,
  schedule_time TIME,
  reminder_time TIMESTAMP WITH TIME ZONE,
  reminder_minutes_before INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    um.id,
    um.name,
    mst.time_of_day,
    (p_date || ' ' || mst.time_of_day)::TIMESTAMP - (mst.reminder_minutes_before || ' minutes')::INTERVAL,
    mst.reminder_minutes_before
  FROM user_medicines um
  JOIN medicine_schedules ms ON ms.user_medicine_id = um.id
  JOIN medicine_schedule_times mst ON mst.medicine_schedule_id = ms.id
  WHERE um.user_id = p_user_id
    AND um.is_active = true
    AND mst.reminder_enabled = true
    AND um.start_date <= p_date
    AND (um.end_date IS NULL OR um.end_date >= p_date)
  ORDER BY mst.time_of_day;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 5. CREATE FUNCTION: get_pending_reminders
-- ============================================================================
-- Function để lấy reminders cần gửi trong khoảng thời gian

CREATE OR REPLACE FUNCTION get_pending_reminders(
  p_window_minutes INTEGER DEFAULT 60
)
RETURNS TABLE (
  user_id UUID,
  medicine_id UUID,
  medicine_name VARCHAR,
  schedule_time_id UUID,
  scheduled_datetime TIMESTAMP WITH TIME ZONE,
  reminder_scheduled_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    um.user_id,
    um.id,
    um.name,
    mst.id,
    (CURRENT_DATE || ' ' || mst.time_of_day)::TIMESTAMP WITH TIME ZONE,
    ((CURRENT_DATE || ' ' || mst.time_of_day)::TIMESTAMP WITH TIME ZONE) - (mst.reminder_minutes_before || ' minutes')::INTERVAL
  FROM user_medicines um
  JOIN medicine_schedules ms ON ms.user_medicine_id = um.id
  JOIN medicine_schedule_times mst ON mst.medicine_schedule_id = ms.id
  WHERE um.is_active = true
    AND mst.reminder_enabled = true
    AND um.start_date <= CURRENT_DATE
    AND (um.end_date IS NULL OR um.end_date >= CURRENT_DATE)
    AND ((CURRENT_DATE || ' ' || mst.time_of_day)::TIMESTAMP WITH TIME ZONE) - (mst.reminder_minutes_before || ' minutes')::INTERVAL
        BETWEEN CURRENT_TIMESTAMP AND CURRENT_TIMESTAMP + (p_window_minutes || ' minutes')::INTERVAL
  ORDER BY mst.time_of_day;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 6. CREATE VIEW: pending_notifications
-- ============================================================================
-- View: Thông báo chưa gửi, cần gửi ngay bây giờ

CREATE OR REPLACE VIEW pending_notifications AS
SELECT 
  nt.id as notification_id,
  nt.user_id,
  nt.user_medicine_id,
  nt.medicine_schedule_time_id,
  um.name as medicine_name,
  um.dosage_strength,
  um.quantity_per_dose,
  nt.scheduled_date,
  nt.scheduled_time,
  nt.reminder_scheduled_at,
  nt.repeat_count,
  nt.last_reminder_at,
  nt.next_reminder_at,
  CASE 
    WHEN nt.intake_status = 'taken' THEN 'Đã uống'
    WHEN nt.intake_status = 'skipped' THEN 'Bỏ qua'
    WHEN nt.intake_status = 'missed' THEN 'Bỏ lỡ'
    ELSE 'Chưa uống'
  END as intake_status_text
FROM notification_tracking nt
JOIN user_medicines um ON um.id = nt.user_medicine_id
WHERE nt.scheduled_date = CURRENT_DATE
  AND nt.notification_status = 'sent'
  AND nt.intake_status = 'pending'
  AND nt.next_reminder_at IS NOT NULL
ORDER BY nt.scheduled_time, um.name;

-- ============================================================================
-- 7. CREATE VIEW: today_reminders
-- ============================================================================
-- View: Tất cả reminder cho hôm nay

CREATE OR REPLACE VIEW today_reminders AS
SELECT 
  um.id as medicine_id,
  um.user_id,
  um.name,
  um.dosage_strength,
  um.quantity_per_dose,
  mst.id as schedule_time_id,
  mst.time_of_day,
  mst.reminder_minutes_before,
  (CURRENT_DATE || ' ' || mst.time_of_day)::TIMESTAMP WITH TIME ZONE as scheduled_datetime,
  ((CURRENT_DATE || ' ' || mst.time_of_day)::TIMESTAMP WITH TIME ZONE) - (mst.reminder_minutes_before || ' minutes')::INTERVAL as reminder_datetime,
  CASE 
    WHEN ((CURRENT_DATE || ' ' || mst.time_of_day)::TIMESTAMP WITH TIME ZONE) - (mst.reminder_minutes_before || ' minutes')::INTERVAL < CURRENT_TIMESTAMP THEN 'Quá hạn'
    WHEN ((CURRENT_DATE || ' ' || mst.time_of_day)::TIMESTAMP WITH TIME ZONE) - (mst.reminder_minutes_before || ' minutes')::INTERVAL < CURRENT_TIMESTAMP + INTERVAL '5 minutes' THEN 'Sắp gửi'
    ELSE 'Sắp tới'
  END as status
FROM user_medicines um
JOIN medicine_schedules ms ON ms.user_medicine_id = um.id
JOIN medicine_schedule_times mst ON mst.medicine_schedule_id = ms.id
WHERE um.is_active = true
  AND mst.reminder_enabled = true
  AND um.start_date <= CURRENT_DATE
  AND (um.end_date IS NULL OR um.end_date >= CURRENT_DATE)
ORDER BY mst.time_of_day, um.name;

-- ============================================================================
-- 8. EXAMPLE DATA
-- ============================================================================
-- Cập nhật reminder_minutes_before từ notification settings của user
-- (Nếu user đã set trong notification_settings_screen)
-- Hiện tại set default 15 phút

UPDATE medicine_schedule_times 
SET reminder_minutes_before = 15, reminder_enabled = true
WHERE reminder_minutes_before IS NULL;

-- ============================================================================
-- DONE!
-- ============================================================================
-- Migration hoàn thành. Bây giờ:
-- 1. Backend có thể track thông báo
-- 2. Có thể lấy pending reminders
-- 3. Có thể set reminder time riêng cho mỗi schedule time
-- 4. Có thể handle repeat notifications
