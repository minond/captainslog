package service

import (
	"context"
	"database/sql"
	"net/url"

	"gopkg.in/src-d/go-kallax.v1"

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

type SavedQueriesRetrieveResponse struct {
	Queries []*model.SavedQuery `json:"queries"`
}

func (s SavedQueryService) Retrieve(ctx context.Context, req url.Values) (*SavedQueriesRetrieveResponse, error) {
	userGUID, err := getUserGUID(ctx)
	if err != nil {
		return nil, err
	}

	query := model.NewSavedQueryQuery().
		Where(kallax.Eq(model.Schema.SavedQuery.UserFK, userGUID))

	queries, err := s.savedQueryStore.FindAll(query)
	if err != nil {
		return nil, err
	}

	return &SavedQueriesRetrieveResponse{Queries: queries}, nil
}

func (s SavedQueryService) Update(ctx context.Context, req *model.SavedQuery) (*model.SavedQuery, error) {
	userGUID, err := getUserGUID(ctx)
	if err != nil {
		return nil, err
	}

	query := model.NewSavedQueryQuery().
		Where(kallax.Eq(model.Schema.SavedQuery.UserFK, userGUID)).
		FindByGUID(req.GUID)

	savedQuery, err := s.savedQueryStore.FindOne(query)
	if err != nil {
		return nil, err
	}

	savedQuery.Label = req.Label
	savedQuery.Content = req.Content

	_, err = s.savedQueryStore.Update(savedQuery,
		model.Schema.SavedQuery.Label,
		model.Schema.SavedQuery.Content)
	return req, err
}
