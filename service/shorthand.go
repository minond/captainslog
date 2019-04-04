package service

import (
	"context"
	"database/sql"

	"gopkg.in/src-d/go-kallax.v1"

	"github.com/minond/captainslog/model"
)

type ShorthandService struct {
	bookStore      *model.BookStore
	shorthandStore *model.ShorthandStore
}

func NewShorthandService(db *sql.DB) *ShorthandService {
	return &ShorthandService{
		bookStore:      model.NewBookStore(db),
		shorthandStore: model.NewShorthandStore(db),
	}
}

type ShorthandCreateRequest struct {
	BookGUID  string  `json:"bookGuid"`
	Expansion string  `json:"expansion"`
	Match     *string `json:"match"`
	Text      *string `json:"text"`
}

func (s ShorthandService) Create(ctx context.Context, req *ShorthandCreateRequest) (*model.Shorthand, error) {
	book, err := s.bookStore.FindOne(model.NewBookQuery().
		Where(kallax.Eq(model.Schema.Book.GUID, req.BookGUID)))
	if err != nil {
		return nil, err
	}

	shorthand, err := model.NewShorthand(req.Expansion, req.Match, req.Text, book)
	if err != nil {
		return nil, err
	}

	err = s.shorthandStore.Insert(shorthand)
	return shorthand, err
}
