package service

import (
	"context"
	"database/sql"

	"github.com/minond/captainslog/model"
	"github.com/minond/captainslog/query"
)

type QueryService struct {
	entryStore *model.EntryStore
}

func NewQueryService(db *sql.DB) *QueryService {
	return &QueryService{
		entryStore: model.NewEntryStore(db),
	}
}

type QueryRequest struct {
	Query string `json:"query"`
}

type QueryResponse struct {
	Cols []string        `json:"cols"`
	Data [][]interface{} `json:"data"`
}

func (s QueryService) Query(ctx context.Context, req *QueryRequest) (*QueryResponse, error) {
	userGUID, err := getUserGUID(ctx)
	if err != nil {
		return nil, err
	}

	cols, data, err := query.Exec(s.entryStore, req.Query, userGUID)
	if err != nil {
		return nil, err
	}

	return &QueryResponse{cols, data}, nil
}
