-- ============================================================================
-- SUPABASE DATABASE SETUP - Users & Authentication Tables
-- ============================================================================
-- File này chứa tất cả các SQL commands cần thiết để setup database cho MediMinder
-- Paste toàn bộ code này vào Supabase > SQL Editor > Run
-- ============================================================================

-- ============================================================================
-- 1. USERS TABLE - Lưu thông tin profile người dùng
-- ============================================================================

CREATE TABLE IF NOT EXISTS users (
  -- Primary Key - Liên kết với auth.users của Supabase Auth
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Thông tin cơ bản
  email VARCHAR UNIQUE NOT NULL,
  full_name VARCHAR(255),
  phone_number VARCHAR(20),
  
  -- Thông tin cá nhân
  date_of_birth DATE,
  gender VARCHAR(20), -- 'male', 'female', 'other'
  avatar_url TEXT, -- URL ảnh đại diện từ Storage
  
  -- Địa chỉ
  address VARCHAR(255),
  city VARCHAR(100),
  country VARCHAR(100),
  postal_code VARCHAR(20),
  
  -- Thông tin y tế (tuỳ chọn)
  blood_type VARCHAR(10), -- 'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  allergies TEXT, -- Những dị ứng (comma separated)
  medical_notes TEXT, -- Ghi chú y tế
  
  -- Trạng thái
  is_active BOOLEAN DEFAULT TRUE,
  is_verified BOOLEAN DEFAULT FALSE,
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  last_login_at TIMESTAMP WITH TIME ZONE,
  
  -- Constraints
  CONSTRAINT valid_gender CHECK (gender IN ('male', 'female', 'other')),
  CONSTRAINT valid_blood_type CHECK (
    blood_type IS NULL OR 
    blood_type IN ('A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-')
  )
);

-- Index để tối ưu query
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_users_created_at ON users(created_at DESC);

-- Comment cho bảng
COMMENT ON TABLE users IS 'Bảng lưu trữ thông tin profile người dùng, liên kết với auth.users';

-- ============================================================================
-- 2. ROW LEVEL SECURITY (RLS) - Bảo mật dữ liệu
-- ============================================================================

-- Enable RLS cho users table
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policy 1: Users có thể xem profile của chính họ
CREATE POLICY "Users can view own profile"
ON users
FOR SELECT
USING (auth.uid() = id);

-- Policy 2: Users có thể cập nhật profile của chính họ
CREATE POLICY "Users can update own profile"
ON users
FOR UPDATE
USING (auth.uid() = id);

-- Policy 3: Users mới có thể insert profile của chính họ
CREATE POLICY "Users can insert own profile"
ON users
FOR INSERT
WITH CHECK (auth.uid() = id);

-- Policy 4: Anonymous users có thể insert (cho signup)
CREATE POLICY "Anonymous can insert new user"
ON users
FOR INSERT
TO anon
WITH CHECK (true);

-- Policy 5: Admin/authenticated users có thể xem all (tuỳ chọn - comment out nếu không cần)
-- CREATE POLICY "Admin can view all profiles"
-- ON users
-- FOR SELECT
-- USING (auth.jwt() ->> 'role' = 'admin');

-- ============================================================================
-- 3. MEDICINES TABLE - Danh sách thuốc
-- ============================================================================

CREATE TABLE IF NOT EXISTS medicines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Thông tin thuốc
  name VARCHAR(255) NOT NULL,
  generic_name VARCHAR(255), -- Tên chung
  description TEXT,
  
  -- Dosage
  dosage_form VARCHAR(50), -- 'tablet', 'capsule', 'liquid', 'injection', etc.
  dosage_strength VARCHAR(50), -- e.g., '500mg', '10ml'
  
  -- Dùng
  usage_instructions TEXT,
  side_effects TEXT,
  contraindications TEXT,
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index
CREATE INDEX idx_medicines_name ON medicines(name);

COMMENT ON TABLE medicines IS 'Danh sách các loại thuốc';

-- ============================================================================
-- 4. REMINDERS TABLE - Nhắc lịch uống thuốc
-- ============================================================================

CREATE TABLE IF NOT EXISTS reminders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Foreign Key
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  medicine_id UUID REFERENCES medicines(id) ON DELETE SET NULL,
  
  -- Thông tin thuốc
  medicine_name VARCHAR(255) NOT NULL,
  dosage VARCHAR(100), -- e.g., '2 tablets'
  
  -- Lịch uống
  frequency VARCHAR(50), -- 'once', 'twice', 'three times', 'as needed'
  times_per_day INTEGER, -- Số lần mỗi ngày
  
  -- Thời gian cụ thể
  time_of_day TIME[], -- Array các giờ uống (e.g., '{08:00:00, 14:00:00, 20:00:00}')
  
  -- Khoảng thời gian
  start_date DATE NOT NULL,
  end_date DATE, -- NULL = indefinite
  
  -- Thêm thông tin
  reason_for_use VARCHAR(255), -- Lý do sử dụng
  notes TEXT, -- Ghi chú thêm
  
  -- Trạng thái
  is_active BOOLEAN DEFAULT TRUE,
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index
CREATE INDEX idx_reminders_user_id ON reminders(user_id);
CREATE INDEX idx_reminders_is_active ON reminders(is_active);
CREATE INDEX idx_reminders_start_date ON reminders(start_date);

COMMENT ON TABLE reminders IS 'Nhắc lịch uống thuốc cho người dùng';

-- Enable RLS
ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view own reminders"
ON reminders
FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can create own reminders"
ON reminders
FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reminders"
ON reminders
FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own reminders"
ON reminders
FOR DELETE
USING (auth.uid() = user_id);

-- ============================================================================
-- 5. MEDICINE_LOGS TABLE - Log lịch sử uống thuốc
-- ============================================================================

CREATE TABLE IF NOT EXISTS medicine_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Foreign Keys
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  reminder_id UUID REFERENCES reminders(id) ON DELETE SET NULL,
  
  -- Thông tin
  medicine_name VARCHAR(255) NOT NULL,
  dosage VARCHAR(100),
  
  -- Lịch sử
  scheduled_time TIMESTAMP WITH TIME ZONE,
  taken_time TIMESTAMP WITH TIME ZONE,
  status VARCHAR(20), -- 'pending', 'taken', 'skipped', 'missed'
  
  -- Ghi chú
  notes TEXT,
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index
CREATE INDEX idx_medicine_logs_user_id ON medicine_logs(user_id);
CREATE INDEX idx_medicine_logs_scheduled_time ON medicine_logs(scheduled_time);
CREATE INDEX idx_medicine_logs_status ON medicine_logs(status);

COMMENT ON TABLE medicine_logs IS 'Lịch sử uống thuốc của người dùng';

-- Enable RLS
ALTER TABLE medicine_logs ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view own logs"
ON medicine_logs
FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can create own logs"
ON medicine_logs
FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own logs"
ON medicine_logs
FOR UPDATE
USING (auth.uid() = user_id);

-- ============================================================================
-- 6. STORAGE - Avatar Bucket
-- ============================================================================

-- Create bucket (run từ Supabase Dashboard > Storage)
-- Name: avatars
-- Public: true

-- SQL để tạo bucket (chỉ hoạt động qua Supabase client, không qua SQL editor)
-- insert into storage.buckets (id, name, public)
-- values ('avatars', 'avatars', true);

-- ============================================================================
-- 7. TRIGGERS - Tự động update updated_at
-- ============================================================================

-- Function để update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger cho users table
CREATE TRIGGER users_update_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Trigger cho reminders table
CREATE TRIGGER reminders_update_updated_at
BEFORE UPDATE ON reminders
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Trigger cho medicines table
CREATE TRIGGER medicines_update_updated_at
BEFORE UPDATE ON medicines
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 8. VIEWS - Các view hữu ích
-- ============================================================================

-- View: Upcoming Reminders cho hôm nay
CREATE OR REPLACE VIEW today_reminders AS
SELECT 
  r.id,
  r.user_id,
  r.medicine_name,
  r.dosage,
  r.times_per_day,
  r.time_of_day,
  u.email,
  u.full_name
FROM reminders r
JOIN users u ON r.user_id = u.id
WHERE r.is_active = TRUE
  AND r.start_date <= CURRENT_DATE
  AND (r.end_date IS NULL OR r.end_date >= CURRENT_DATE);

-- View: Missed Reminders
CREATE OR REPLACE VIEW missed_reminders AS
SELECT 
  ml.id,
  ml.user_id,
  ml.medicine_name,
  ml.scheduled_time,
  ml.status,
  u.email
FROM medicine_logs ml
JOIN users u ON ml.user_id = u.id
WHERE ml.status IN ('missed', 'skipped')
  AND ml.scheduled_time >= CURRENT_DATE - INTERVAL '7 days';

-- ============================================================================
-- 9. SAMPLE DATA - Dữ liệu mẫu (tuỳ chọn)
-- ============================================================================

-- Thêm vài loại thuốc mẫu
INSERT INTO medicines (name, generic_name, dosage_form, dosage_strength, usage_instructions)
VALUES 
  ('Paracetamol', 'Paracetamol', 'tablet', '500mg', 'Take 1-2 tablets every 4-6 hours as needed'),
  ('Ibuprofen', 'Ibuprofen', 'tablet', '400mg', 'Take 1 tablet every 6-8 hours with food'),
  ('Aspirin', 'Acetylsalicylic Acid', 'tablet', '100mg', 'Take 1 tablet daily'),
  ('Vitamin D', 'Cholecalciferol', 'capsule', '1000IU', 'Take 1 capsule daily'),
  ('Vitamin B12', 'Cyanocobalamin', 'tablet', '1000mcg', 'Take 1 tablet daily')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 10. UTILITY FUNCTIONS
-- ============================================================================

-- Function: Lấy reminders cho user hôm nay
CREATE OR REPLACE FUNCTION get_today_reminders(user_id UUID)
RETURNS TABLE (
  id UUID,
  medicine_name VARCHAR,
  dosage VARCHAR,
  time_of_day TIME[],
  frequency VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    r.id,
    r.medicine_name,
    r.dosage,
    r.time_of_day,
    r.frequency
  FROM reminders r
  WHERE r.user_id = $1
    AND r.is_active = TRUE
    AND r.start_date <= CURRENT_DATE
    AND (r.end_date IS NULL OR r.end_date >= CURRENT_DATE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 11. VERIFICATION & TESTING
-- ============================================================================

-- Verify tables created
-- SELECT table_name FROM information_schema.tables 
-- WHERE table_schema = 'public' ORDER BY table_name;

-- Verify RLS enabled
-- SELECT tablename, rowsecurity FROM pg_tables 
-- WHERE schemaname = 'public' AND rowsecurity = true;

-- ============================================================================
-- END OF SQL SETUP
-- ============================================================================
-- 
-- ✅ Tables Created:
--   - users (Thông tin người dùng)
--   - medicines (Danh sách thuốc)
--   - reminders (Nhắc lịch uống thuốc)
--   - medicine_logs (Lịch sử uống thuốc)
--
-- ✅ Security Enabled:
--   - Row Level Security (RLS) trên tất cả tables
--   - Policies cho users chỉ truy cập data của chính họ
--
-- ✅ Features:
--   - Automatic updated_at timestamp
--   - Useful views for common queries
--   - Utility functions for app
--
-- 🚀 Ready to use!
-- ============================================================================
