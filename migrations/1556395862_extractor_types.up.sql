BEGIN;

ALTER TABLE extractors ADD COLUMN type integer NOT NULL;

COMMIT;
