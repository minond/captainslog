package model

import (
	"gopkg.in/src-d/go-kallax.v1"
)

type Group struct {
	kallax.Model `pk:"guid"`

	Guid     kallax.ULID
	BookGuid kallax.ULID
}

func newGroup(book *Book) (*Group, error) {
	group := &Group{
		Guid: kallax.NewULID(),
	}

	if book != nil {
		group.BookGuid = book.Guid
	}

	return group, nil
}
