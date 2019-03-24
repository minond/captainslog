package db

import (
	"gopkg.in/src-d/go-kallax.v1"
)

type Book struct {
	kallax.Model `pk:"guid"`

	Guid     kallax.ULID
	UserGuid kallax.ULID
	Name     string
	Grouping int32
}

func newBook(name string, grouping int32, user *User) (*Book, error) {
	book := &Book{
		Guid:     kallax.NewULID(),
		Name:     name,
		Grouping: grouping,
	}

	if user != nil {
		book.UserGuid = user.Guid
	}

	return book, nil
}
