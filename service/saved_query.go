package service

import (
	"context"
	"database/sql"
	"net/url"

	"github.com/minond/captainslog/model"
)

type SavedQueryService struct {
	savedQueryStore *model.SavedQueryStore
	userStore       *model.UserStore
}

func NewSavedQueryService(db *sql.DB) *SavedQueryService {
	return &SavedQueryService{
		savedQueryStore: model.NewSavedQueryStore(db),
		userStore:       model.NewUserStore(db),
	}
}

type SavedQueryCreateRequest struct {
	Label   string `json:"label"`
	Content string `json:"content"`
}

func (s SavedQueryService) Create(ctx context.Context, req *SavedQueryCreateRequest) (*model.SavedQuery, error) {
	user, err := getUser(ctx, s.userStore)
	if err != nil {
		return nil, err
	}

	savedQuery, err := model.NewSavedQuery(req.Label, req.Content, user)
	if err != nil {
		return nil, err
	}

	if err = s.savedQueryStore.Insert(savedQuery); err != nil {
		return nil, err
	}

	return savedQuery, nil
}

type SavedQueryRetrieveResponse struct {
	Queries []*model.SavedQuery `json:"queries"`
}

func (s SavedQueryService) Retrieve(ctx context.Context, req url.Values) (*SavedQueryRetrieveResponse, error) {
	return nil, nil
}
