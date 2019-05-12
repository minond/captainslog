BEGIN;

ALTER TABLE shorthands ADD COLUMN priority bigint NOT NULL;

COMMIT;
