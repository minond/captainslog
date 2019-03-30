package model

import (
	"time"

	"gopkg.in/src-d/go-kallax.v1"
)

type Entry struct {
	kallax.Model `table:"entries" pk:"guid"`

	GUID           kallax.ULID
	BookGUID       kallax.ULID
	CollectionGUID kallax.ULID
	Text           string
	Data           map[string]string
	CreatedAt      time.Time
	UpdatedAt      time.Time
}

func newEntry(text string, data map[string]string, collection *Collection) (*Entry, error) {
	now := time.Now()
	entry := &Entry{
		GUID:      kallax.NewULID(),
		Text:      text,
		Data:      data,
		CreatedAt: now,
		UpdatedAt: now,
	}

	if collection != nil {
		entry.BookGUID = collection.BookGUID
		entry.CollectionGUID = collection.GUID
	}

	return entry, nil
}
