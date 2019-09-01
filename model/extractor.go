package model

import (
	"gopkg.in/src-d/go-kallax.v1"
)

// DataType represents the data type of extracted data.
type DataType int32

const (
	StringData DataType = iota
	NumberData

	// BooleanData identifies the existence of extracted data. When the
	// extractor does not match, no data is saved. When the extractor matches,
	// the data will be labeled as "true".
	BooleanData
)

type Extractor struct {
	kallax.Model `table:"extractors" pk:"guid"`

	GUID  kallax.ULID `json:"guid"`
	Label string

	// Match is a regular expression string which is used to extract data from
	// a log. If match is an empty string (?) the extractor may be treated as a
	// system extract if the label + type combination are recognized.
	//
	// See processing package for more details.
	Match string
	Type  DataType

	Book *Book `fk:"book_guid,inverse"`
}

func newExtractor(label, match string, typ DataType, book *Book) (*Extractor, error) {
	extractor := &Extractor{
		Book:  book,
		GUID:  kallax.NewULID(),
		Label: label,
		Match: match,
		Type:  typ,
	}

	return extractor, nil
}
