package service

import (
	"context"
	"database/sql"
	"time"

	"gopkg.in/src-d/go-kallax.v1"

	"github.com/minond/captainslog/server/model"
	"github.com/minond/captainslog/server/processing"
)

type EntryCreateRequest struct {
	GUID      string    `json:"guid"`
	Text      string    `json:"text"`
	Timestamp time.Time `json:"timestamp"`
	BookGUID  string    `json:"book_guid"`
}

type EntryServiceContract interface {
	Create(context.Context, *EntryCreateRequest) (*model.Entry, error)
}

type EntryService struct {
	bookStore       *model.BookStore
	collectionStore *model.CollectionStore
	entryStore      *model.EntryStore
}

var _ EntryServiceContract = EntryService{}

func NewEntryService(db *sql.DB) *EntryService {
	return &EntryService{
		bookStore:       model.NewBookStore(db),
		collectionStore: model.NewCollectionStore(db),
		entryStore:      model.NewEntryStore(db),
	}
}

func (s EntryService) Create(ctx context.Context, req *EntryCreateRequest) (*model.Entry, error) {
	userGUID, err := getUserGUID(ctx)
	if err != nil {
		return nil, err
	}

	book, err := s.bookStore.FindOne(model.NewBookQuery().
		Where(kallax.Eq(model.Schema.Book.GUID, req.BookGUID)).
		Where(kallax.Eq(model.Schema.Book.UserGUID, userGUID)))
	if err != nil {
		return nil, err
	}

	// FIXME
	collection, err := book.ActiveCollection(s.collectionStore)
	if err != nil {
		return nil, err
	}

	// FIXME
	extractors := []*model.Extractor{
		&model.Extractor{Label: "exercise", Match: `^(.+),`},
		&model.Extractor{Label: "sets", Match: `,\s{0,}(\d+)\s{0,}x`},
		&model.Extractor{Label: "reps", Match: `x\s{0,}(\d+)\s{0,}@`},
		&model.Extractor{Label: "weight", Match: `@\s{0,}(\d+)$`},
		&model.Extractor{Label: "time", Match: `(\d+\s{0,}(sec|seconds|min|minutes|hour|hours))`},
	}

	data, err := processing.Extract(req.Text, extractors)
	if err != nil {
		return nil, err
	}

	entry, err := model.NewEntry(req.Text, data, collection)
	if err != nil {
		return nil, err
	}

	err = s.entryStore.Insert(entry)
	return entry, err
}
