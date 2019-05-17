package model

import (
	"time"

	"gopkg.in/src-d/go-kallax.v1"
)

type Entry struct {
	kallax.Model `table:"entries" pk:"guid"`

	GUID      kallax.ULID            `json:"guid"`
	Original  string                 `json:"-"`
	Text      string                 `json:"text"`
	Data      map[string]interface{} `json:"data"`
	CreatedAt time.Time              `json:"createdAt" sqltype:"timestamp"`
	UpdatedAt time.Time              `json:"updatedAt" sqltype:"timestamp"`

	Book       *Book       `fk:"book_guid,inverse"`
	Collection *Collection `fk:"collection_guid,inverse"`
}

func newEntry(original, text string, data map[string]interface{}, collection *Collection) (*Entry, error) {
	now := time.Now()
	entry := &Entry{
		Collection: collection,
		CreatedAt:  now,
		Data:       data,
		GUID:       kallax.NewULID(),
		Original:   original,
		Text:       text,
		UpdatedAt:  now,
	}

	if collection != nil {
		entry.Book = collection.Book
	}

	return entry, nil
}
