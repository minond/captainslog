package model

import (
	"gopkg.in/src-d/go-kallax.v1"
)

type Book struct {
	kallax.Model `table:"books" pk:"guid"`

	GUID     kallax.ULID
	UserGUID kallax.ULID
	Name     string
	Grouping int32
}

func newBook(name string, grouping int32, user *User) (*Book, error) {
	book := &Book{
		GUID:     kallax.NewULID(),
		Name:     name,
		Grouping: grouping,
	}

	if user != nil {
		book.UserGUID = user.GUID
	}

	return book, nil
}
