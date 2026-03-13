-- Add notification_settings JSONB column to managers table
ALTER TABLE managers ADD COLUMN IF NOT EXISTS notification_settings JSONB
  NOT NULL DEFAULT '{
    "match_notifications": true,
    "message_notifications": true,
    "verification_notifications": true,
    "system_notifications": true
  }'::jsonb;
