BEGIN;

CREATE TABLE shorthands (
	guid uuid NOT NULL PRIMARY KEY,
	book_guid uuid NOT NULL,
	expansion text NOT NULL,
	match text,
	text text
);


COMMIT;
