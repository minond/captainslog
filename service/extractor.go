package service

import (
	"context"
	"database/sql"

	"gopkg.in/src-d/go-kallax.v1"

	"github.com/minond/captainslog/model"
)

type ExtractorService struct {
	bookStore      *model.BookStore
	extractorStore *model.ExtractorStore
}

func NewExtractorService(db *sql.DB) *ExtractorService {
	return &ExtractorService{
		bookStore:      model.NewBookStore(db),
		extractorStore: model.NewExtractorStore(db),
	}
}

type ExtractorCreateRequest struct {
	BookGUID string `json:"bookGuid"`
	Label    string `json:"label"`
	Match    string `json:"match"`
}

func (s ExtractorService) Create(ctx context.Context, req *ExtractorCreateRequest) (*model.Extractor, error) {
	book, err := s.bookStore.FindOne(model.NewBookQuery().
		Where(kallax.Eq(model.Schema.Book.GUID, req.BookGUID)))
	if err != nil {
		return nil, err
	}

	extractor, err := model.NewExtractor(req.Label, req.Match, book)
	if err != nil {
		return nil, err
	}
	err = s.extractorStore.Insert(extractor)
	return extractor, err
}
