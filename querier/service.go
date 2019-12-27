package main

import (
	"context"
	"errors"

	"github.com/minond/captainslog/querier/query"
)

var (
	ErrReqMissingQuery  = errors.New("missing user id in request")
	ErrReqMissingUserID = errors.New("missing query in request")
	ErrQuerySyntax      = errors.New("query syntax error")
	ErrQueryProcessing  = errors.New("unable to process query")
)

type Service struct {
	repo Repository
}

func NewService(repo Repository) *Service {
	return &Service{
		repo: repo,
	}
}

type QueryRequest struct {
	UserID int64  `json:"user_id"`
	Query  string `json:"query"`
}

type QueryResponse struct {
	Columns []string        `json:"columns"`
	Results [][]interface{} `json:"results"`
}

func (s *Service) Handle(ctx context.Context, req *QueryRequest) (*QueryResponse, error) {
	if err := validateServiceRequest(req); err != nil {
		return nil, err
	}

	unsafe, err := query.Parse(req.Query)
	if err != nil {
		return nil, ErrQuerySyntax
	}

	sanitized, err := Convert(unsafe, req.UserID)
	if err != nil {
		return nil, ErrQueryProcessing
	}

	columns, results, err := s.repo.Execute(ctx, sanitized.String())
	if err != nil {
		return nil, err
	}

	response := &QueryResponse{
		Columns: columns,
		Results: results,
	}

	return response, nil
}

func validateServiceRequest(req *QueryRequest) error {
	if req.UserID == 0 {
		return ErrReqMissingUserID
	}

	if req.Query == "" {
		return ErrReqMissingQuery
	}

	return nil
}
