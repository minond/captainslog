BEGIN;

CREATE TABLE saved_queries (
	guid uuid NOT NULL PRIMARY KEY,
	label text NOT NULL,
	content text NOT NULL
);


COMMIT;
