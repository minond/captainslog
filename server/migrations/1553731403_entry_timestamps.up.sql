BEGIN;

ALTER TABLE entries ADD COLUMN created_at timestamptz NOT NULL;

ALTER TABLE entries ADD COLUMN updated_at timestamptz NOT NULL;

COMMIT;
