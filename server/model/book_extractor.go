package model

import (
	"gopkg.in/src-d/go-kallax.v1"
)

type BookExtractor struct {
	kallax.Model `table:"book_extractors" pk:"guid"`

	GUID          kallax.ULID
	BookGUID      kallax.ULID
	ExtractorGUID kallax.ULID
}

func newBookExtractor(book *Book, extractor *Extractor) (*BookExtractor, error) {
	return &BookExtractor{
		GUID:          kallax.NewULID(),
		BookGUID:      book.GUID,
		ExtractorGUID: extractor.GUID,
	}, nil
}
