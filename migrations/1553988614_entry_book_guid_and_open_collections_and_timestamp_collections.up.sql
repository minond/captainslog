BEGIN;

ALTER TABLE collections ADD COLUMN open boolean NOT NULL;

ALTER TABLE collections ADD COLUMN created_at timestamptz NOT NULL;

ALTER TABLE entries ADD COLUMN book_guid uuid NOT NULL;

COMMIT;
