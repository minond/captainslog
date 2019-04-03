BEGIN;

CREATE TABLE book_extractors (
	guid uuid NOT NULL PRIMARY KEY,
	book_guid uuid NOT NULL,
	extractor_guid uuid NOT NULL
);


ALTER TABLE extractors DROP COLUMN book_guid;

COMMIT;
