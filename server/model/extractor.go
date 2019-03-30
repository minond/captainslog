package model

import (
	"gopkg.in/src-d/go-kallax.v1"
)

type Extractor struct {
	kallax.Model `table:"extractors" pk:"guid"`

	GUID  kallax.ULID
	Label string
	Match string
}

func newExtractor(label, match string) (*Extractor, error) {
	return &Extractor{
		GUID:  kallax.NewULID(),
		Label: label,
		Match: match,
	}, nil
}
