package model

import (
	"gopkg.in/src-d/go-kallax.v1"
)

type Extractor struct {
	kallax.Model `table:"extractors" pk:"guid"`

	Guid  kallax.ULID
	Label string
	Match string
}

func newExtractor(label, match string) (*Extractor, error) {
	return &Extractor{
		Guid:  kallax.NewULID(),
		Label: label,
		Match: match,
	}, nil
}
