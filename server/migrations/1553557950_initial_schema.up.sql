BEGIN;

CREATE TABLE books (
	guid uuid NOT NULL PRIMARY KEY,
	user_guid uuid NOT NULL,
	name text NOT NULL,
	grouping integer NOT NULL
);


CREATE TABLE book_extractors (
	guid uuid NOT NULL PRIMARY KEY,
	book_guid uuid NOT NULL,
	extractor_guid uuid NOT NULL
);


CREATE TABLE collections (
	guid uuid NOT NULL PRIMARY KEY,
	book_guid uuid NOT NULL
);


CREATE TABLE entries (
	guid uuid NOT NULL PRIMARY KEY,
	collection_guid uuid NOT NULL,
	text text NOT NULL,
	data jsonb NOT NULL
);


CREATE TABLE extractors (
	guid uuid NOT NULL PRIMARY KEY,
	label text NOT NULL,
	match text NOT NULL
);


CREATE TABLE users (
	guid uuid NOT NULL PRIMARY KEY
);


COMMIT;
