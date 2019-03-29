package service

import (
	"context"
	"database/sql"

	"gopkg.in/src-d/go-kallax.v1"

	"github.com/minond/captainslog/server/model"
	"github.com/minond/captainslog/server/modelext"
	"github.com/minond/captainslog/server/processing"
	"github.com/minond/captainslog/server/proto"
)

type EntryServiceContract interface {
	Create(context.Context, *proto.EntryCreateRequest) (*proto.Entry, error)
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

func (s EntryService) Create(ctx context.Context, req *proto.EntryCreateRequest) (*proto.Entry, error) {
	userGuid, err := getUserGuid(ctx)
	if err != nil {
		return nil, err
	}

	book, err := s.bookStore.FindOne(model.NewBookQuery().
		Where(kallax.Eq(model.Schema.Book.Guid, req.BookGuid)).
		Where(kallax.Eq(model.Schema.Book.UserGuid, userGuid)))
	if err != nil {
		return nil, err
	}

	// FIXME
	collection, err := modelext.NewCollection(book)
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

	entry, err := modelext.NewEntry(req.Text, data, collection)
	if err != nil {
		return nil, err
	}

	err = s.entryStore.Insert(entry)
	return modelext.Entry.ToProto(entry), err
}
