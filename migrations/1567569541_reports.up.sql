BEGIN;

CREATE TABLE reports (
	guid uuid NOT NULL PRIMARY KEY,
	label text NOT NULL,
	variables jsonb NOT NULL,
	outputs jsonb NOT NULL,
	user_guid uuid REFERENCES users(guid)
);


COMMIT;
