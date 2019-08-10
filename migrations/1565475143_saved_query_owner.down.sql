BEGIN;

ALTER TABLE saved_queries DROP COLUMN user_guid;

COMMIT;
