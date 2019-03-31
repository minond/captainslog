package model

import (
	"gopkg.in/src-d/go-kallax.v1"
)

type Extractor struct {
	kallax.Model `table:"extractors" pk:"guid"`

	GUID     kallax.ULID
	BookGUID kallax.ULID
	Label    string
	Match    string
}

func newExtractor(label, match string, book *Book) (*Extractor, error) {
	extractor := &Extractor{
		GUID:  kallax.NewULID(),
		Label: label,
		Match: match,
	}

	if book != nil {
		extractor.BookGUID = book.GUID
	}

	return extractor, nil
}
