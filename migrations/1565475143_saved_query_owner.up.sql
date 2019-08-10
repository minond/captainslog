BEGIN;

ALTER TABLE saved_queries ADD COLUMN user_guid uuid REFERENCES users(guid);

COMMIT;
