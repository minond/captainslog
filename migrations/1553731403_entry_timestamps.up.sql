BEGIN;

ALTER TABLE entries ADD COLUMN created_at timestamp NOT NULL;

ALTER TABLE entries ADD COLUMN updated_at timestamp NOT NULL;

COMMIT;
