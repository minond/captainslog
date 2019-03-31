package service

import (
	"context"
	"database/sql"

	"github.com/minond/captainslog/server/model"
)

type BookServiceContract interface {
	Create(context.Context, *BookCreateRequest) (*model.Book, error)
}

type BookService struct {
	bookStore *model.BookStore
	userStore *model.UserStore
}

var _ BookServiceContract = BookService{}

func NewBookService(db *sql.DB) *BookService {
	return &BookService{
		bookStore: model.NewBookStore(db),
		userStore: model.NewUserStore(db),
	}
}

type BookCreateRequest struct {
	Name     string `json:"name"`
	Grouping int32  `json:"grouping"`
}

func (s BookService) Create(ctx context.Context, req *BookCreateRequest) (*model.Book, error) {
	user, err := getUser(ctx, s.userStore)
	if err != nil {
		return nil, err
	}

	book, err := model.NewBook(req.Name, req.Grouping, user)
	err = s.bookStore.Insert(book)
	return book, err
}
