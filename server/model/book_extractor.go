package model

import (
	"gopkg.in/src-d/go-kallax.v1"
)

type BookExtractor struct {
	kallax.Model `table:"book_extractors" pk:"guid"`

	Guid          kallax.ULID
	BookGuid      kallax.ULID
	ExtractorGuid kallax.ULID
}
