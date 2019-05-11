package model

import (
	"time"

	"gopkg.in/src-d/go-kallax.v1"
)

type Entry struct {
	kallax.Model `table:"entries" pk:"guid"`

	GUID           kallax.ULID            `json:"guid"`
	BookGUID       kallax.ULID            `json:"-"`
	CollectionGUID kallax.ULID            `json:"-"`
	Original       string                 `json:"-"`
	Text           string                 `json:"text"`
	Data           map[string]interface{} `json:"data"`
	CreatedAt      time.Time              `json:"createdAt" sqltype:"timestamp"`
	UpdatedAt      time.Time              `json:"updatedAt" sqltype:"timestamp"`
}

func newEntry(original, text string, data map[string]interface{}, collection *Collection) (*Entry, error) {
	now := time.Now()
	entry := &Entry{
		GUID:      kallax.NewULID(),
		Original:  original,
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
