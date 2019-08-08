package service

import (
	"context"
	"database/sql"
	"log"

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

type QueryExecuteRequest struct {
	Query string `json:"query"`
}

type QueryResults struct {
	Cols []string        `json:"cols"`
	Data [][]interface{} `json:"data"`
}

func (s QueryService) Query(ctx context.Context, req *QueryExecuteRequest) (*QueryResults, error) {
	userGUID, err := getUserGUID(ctx)
	if err != nil {
		return nil, err
	}

	sql, cols, data, err := query.Exec(s.entryStore, req.Query, userGUID)
	log.Printf("sql: %s", sql)
	if err != nil {
		log.Printf("err: %s", err)
		return nil, err
	}

	return &QueryResults{cols, data}, nil
}
