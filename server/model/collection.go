package model

import (
	"time"

	"gopkg.in/src-d/go-kallax.v1"
)

type Collection struct {
	kallax.Model `table:"collections" pk:"guid"`

	GUID      kallax.ULID
	BookGUID  kallax.ULID
	CreatedAt time.Time
}

func newCollection(book *Book) (*Collection, error) {
	collection := &Collection{
		GUID:      kallax.NewULID(),
		CreatedAt: time.Now(),
	}

	if book != nil {
		collection.BookGUID = book.GUID
	}

	return collection, nil
}
