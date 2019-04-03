BEGIN;

ALTER TABLE entries DROP COLUMN created_at;

ALTER TABLE entries DROP COLUMN updated_at;

COMMIT;
