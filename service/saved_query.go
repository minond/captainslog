package service

import (
	"context"
	"database/sql"
	"net/url"

	"github.com/minond/captainslog/model"
)

type SavedQueryService struct {
	savedQueryStore *model.SavedQueryStore
}

func NewSavedQueryService(db *sql.DB) *SavedQueryService {
	return &SavedQueryService{
		savedQueryStore: model.NewSavedQueryStore(db),
	}
}

type SavedQueryCreateRequest struct {
}

func (s SavedQueryService) Create(ctx context.Context, req *SavedQueryCreateRequest) (*model.SavedQuery, error) {
	return nil, nil
}

type SavedQueryRetrieveResponse struct {
}

func (s SavedQueryService) Retrieve(ctx context.Context, req url.Values) (*SavedQueryRetrieveResponse, error) {
	return nil, nil
}
