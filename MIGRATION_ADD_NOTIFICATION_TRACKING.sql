-- Thêm cột tracking cho notification status
ALTER TABLE public.medicine_schedule_times
ADD COLUMN IF NOT EXISTS last_notification_sent_date date null,
ADD COLUMN IF NOT EXISTS notification_sent_count integer null default 0;

-- Comment để giải thích
COMMENT ON COLUMN public.medicine_schedule_times.last_notification_sent_date IS 'Ngày cuối cùng đã gửi thông báo cho lần uống này';
COMMENT ON COLUMN public.medicine_schedule_times.notification_sent_count IS 'Số lần đã gửi thông báo (để debug)';

-- Index để query nhanh
CREATE INDEX IF NOT EXISTS idx_medicine_schedule_times_last_notification_sent_date 
ON public.medicine_schedule_times USING btree (last_notification_sent_date) TABLESPACE pg_default;
