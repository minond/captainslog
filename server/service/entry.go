package service

import (
	"context"
	"database/sql"

	"github.com/minond/captainslog/server/model"
	"github.com/minond/captainslog/server/processing"
	"github.com/minond/captainslog/server/proto"
)

type EntryServiceContract interface {
	Create(context.Context, *proto.EntryCreateRequest) (*proto.Entry, error)
}

type EntryService struct {
	entryStore *model.EntryStore
}

var _ EntryServiceContract = EntryService{}

func NewEntryService(db *sql.DB) *EntryService {
	return &EntryService{
		entryStore: model.NewEntryStore(db),
	}
}

func (s EntryService) Create(ctx context.Context, req *proto.EntryCreateRequest) (*proto.Entry, error) {
	// FIXME
	user, err := model.NewUser()
	if err != nil {
		return nil, err
	}

	// FIXME
	book, err := model.NewBook("Workouts", int32(proto.Grouping_DAY), user)
	if err != nil {
		return nil, err
	}

	// FIXME
	collection, err := model.NewCollection(book)
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
	return entry.ToProto(), err
}
