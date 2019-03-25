package model

import (
	"gopkg.in/src-d/go-kallax.v1"
)

type Collection struct {
	kallax.Model `table:"collections" pk:"guid"`

	Guid     kallax.ULID
	BookGuid kallax.ULID
}

func newCollection(book *Book) (*Collection, error) {
	collection := &Collection{
		Guid: kallax.NewULID(),
	}

	if book != nil {
		collection.BookGuid = book.Guid
	}

	return collection, nil
}
