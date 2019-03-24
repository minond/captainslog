package model

import (
	"gopkg.in/src-d/go-kallax.v1"
)

type BookExtractor struct {
	kallax.Model `pk:"guid"`

	Guid          kallax.ULID
	BookGuid      kallax.ULID
	ExtractorGuid kallax.ULID
}

func newBookExtractor(book *Book, extractor *Extractor) (*BookExtractor, error) {
	return &BookExtractor{
		Guid:          kallax.NewULID(),
		BookGuid:      book.Guid,
		ExtractorGuid: extractor.Guid,
	}, nil
}
