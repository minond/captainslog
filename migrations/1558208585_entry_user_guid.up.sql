BEGIN;

ALTER TABLE entries ADD COLUMN user_guid uuid REFERENCES users(guid) NOT NULL;

COMMIT;
