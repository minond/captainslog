package modelext

import (
	"time"

	"gopkg.in/src-d/go-kallax.v1"

	model "github.com/minond/captainslog/server/model"
)

func NewCollection(book *model.Book) (*model.Collection, error) {
	collection := &model.Collection{
		Guid:      kallax.NewULID(),
		CreatedAt: time.Now(),
	}

	if book != nil {
		collection.BookGuid = book.Guid
	}

	return collection, nil
}
