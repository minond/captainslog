package service

import (
	"context"
	"database/sql"
	"net/url"
	"time"

	"gopkg.in/src-d/go-kallax.v1"

	"github.com/minond/captainslog/model"
)

type BookService struct {
	bookStore       *model.BookStore
	collectionStore *model.CollectionStore
	userStore       *model.UserStore
}

func NewBookService(db *sql.DB) *BookService {
	return &BookService{
		bookStore:       model.NewBookStore(db),
		collectionStore: model.NewCollectionStore(db),
		userStore:       model.NewUserStore(db),
	}
}

type BookCreateRequest struct {
	Name               string    `json:"name"`
	Grouping           int32     `json:"grouping"`
	CreateCollectionAt time.Time `json:"createCollectionAt"`
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

	if err = s.bookStore.Insert(book); err != nil {
		return nil, err
	}

	at := clientTime(req.CreateCollectionAt)
	if _, err = book.Collection(s.collectionStore, at, true); err != nil {
		return book, err
	}

	return book, nil
}

type BookRetrieveResponse struct {
	Books []*model.Book `json:"books"`
}

func (s BookService) Retrieve(ctx context.Context, req url.Values) (*BookRetrieveResponse, error) {
	userGUID, err := getUserGUID(ctx)
	if err != nil {
		return nil, err
	}

	query := model.NewBookQuery().
		Where(kallax.Eq(model.Schema.Book.UserFK, userGUID))

	// Retrieve a single book
	if guid, ok := req["guid"]; ok {
		query.Where(kallax.Eq(model.Schema.Book.GUID, guid))
	}

	books, err := s.bookStore.FindAll(query)
	if err != nil {
		return nil, err
	}

	return &BookRetrieveResponse{Books: books}, nil
}
