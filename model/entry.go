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
	Data      map[string]interface{} `json:"data,omitempty"`
	CreatedAt time.Time              `json:"createdAt" sqltype:"timestamp"`
	UpdatedAt time.Time              `json:"updatedAt" sqltype:"timestamp"`

	Book       *Book       `json:"-" fk:"book_guid,inverse"`
	Collection *Collection `json:"-" fk:"collection_guid,inverse"`
	User       *User       `json:"-" fk:"user_guid,inverse"`
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

	if collection != nil && collection.Book != nil {
		entry.Book = collection.Book
		entry.User = collection.Book.User
	}

	return entry, nil
}
