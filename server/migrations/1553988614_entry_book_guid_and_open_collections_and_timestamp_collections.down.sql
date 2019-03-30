BEGIN;

ALTER TABLE collections DROP COLUMN open;

ALTER TABLE collections DROP COLUMN created_at;

ALTER TABLE entries DROP COLUMN book_guid;

COMMIT;
