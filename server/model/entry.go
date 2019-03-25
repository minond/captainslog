package model

import (
	"gopkg.in/src-d/go-kallax.v1"
)

type Entry struct {
	kallax.Model `table:"entries" pk:"guid"`

	Guid           kallax.ULID
	CollectionGuid kallax.ULID
	Text           string
	Data           map[string]string
}

func newEntry(text string, data map[string]string, collection *Collection) (*Entry, error) {
	entry := &Entry{
		Guid: kallax.NewULID(),
		Text: text,
		Data: data,
	}

	if collection != nil {
		entry.CollectionGuid = collection.Guid
	}

	return entry, nil
}
