BEGIN;

DROP TABLE book_extractors;

ALTER TABLE extractors ADD COLUMN book_guid uuid NOT NULL;

COMMIT;
