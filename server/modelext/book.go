package modelext

import (
	kallax "gopkg.in/src-d/go-kallax.v1"

	model "github.com/minond/captainslog/server/model"
)

func NewBook(name string, grouping int32, user *model.User) (*model.Book, error) {
	book := &model.Book{
		Guid:     kallax.NewULID(),
		Name:     name,
		Grouping: grouping,
	}

	if user != nil {
		book.UserGuid = user.Guid
	}

	return book, nil
}
