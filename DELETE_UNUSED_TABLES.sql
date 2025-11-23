-- ==========================================
-- Script XOÁ 2 TABLE KHÔNG DÙNG
-- ==========================================
-- Xoá: reminders, medicine_logs
-- Lý do: Duplicate với notification_tracking & medicine_intakes
-- ==========================================

-- ⚠️ CẢNH BÁO: Chạy trong Supabase SQL Editor
-- Backup database trước khi chạy!

-- Step 1: Xoá view phụ thuộc (nếu có)
-- missed_reminders view phụ thuộc medicine_logs
DROP VIEW IF EXISTS public.missed_reminders CASCADE;
-- ✅ Dropped view: missed_reminders

-- today_reminders view phụ thuộc reminders
DROP VIEW IF EXISTS public.today_reminders CASCADE;
-- ✅ Dropped view: today_reminders

-- Step 2: Xoá trigger
DROP TRIGGER IF EXISTS reminders_update_updated_at ON public.reminders CASCADE;
DROP TRIGGER IF EXISTS medicine_logs_update_updated_at ON public.medicine_logs CASCADE;
-- ✅ Dropped triggers

-- Step 3: Xoá table (theo thứ tự dependency)
-- medicine_logs phụ thuộc reminders qua reminder_id
DROP TABLE IF EXISTS public.medicine_logs CASCADE;
-- ✅ Dropped table: medicine_logs

-- reminders là independent
DROP TABLE IF EXISTS public.reminders CASCADE;
-- ✅ Dropped table: reminders

-- Step 4: Verify - Check các table còn lại
-- SELECT table_name FROM information_schema.tables 
-- WHERE table_schema='public' AND table_type='BASE TABLE'
-- ORDER BY table_name;

-- ==========================================
-- DONE! 2 table đã xoá
-- ==========================================
-- Remaining tables:
-- - users
-- - medicines
-- - user_medicines
-- - medicine_schedules
-- - medicine_schedule_times
-- - medicine_intakes ✅ (thay thế medicine_logs)
-- - notification_tracking ✅ (thay thế reminders)
-- - health_metric_history
-- - user_health_profiles
-- ==========================================
