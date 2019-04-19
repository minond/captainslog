package service

import (
	"context"
	"database/sql"
	"net/url"

	"gopkg.in/src-d/go-kallax.v1"

	"github.com/minond/captainslog/model"
)

type BookService struct {
	bookStore *model.BookStore
	userStore *model.UserStore
}

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
	if err != nil {
		return nil, err
	}
	err = s.bookStore.Insert(book)
	return book, err
}

type BookRetrieveResponse struct {
	Books []*model.Book `json:"books"`
}

func (s BookService) Retrieve(ctx context.Context, req url.Values) (*BookRetrieveResponse, error) {
	userGUID, err := getUserGUID(ctx)
	if err != nil {
		return nil, err
	}

	books, err := s.bookStore.FindAll(model.NewBookQuery().
		Where(kallax.Eq(model.Schema.Book.UserGUID, userGUID)))
	if err != nil {
		return nil, err
	}

	return &BookRetrieveResponse{Books: books}, nil
}
