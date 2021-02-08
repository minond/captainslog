package main

import (
	"context"
	"errors"

	"github.com/minond/captainslog/querier/repository"
	"github.com/minond/captainslog/querier/sqlparse"
	"github.com/minond/captainslog/querier/sqlrewrite"
	internal "github.com/minond/captainslog/shared/service"
)

var (
	ErrReqMissingUserID = errors.New("missing user id in request")
	ErrReqMissingQuery  = errors.New("missing query in request")
	ErrQuerySyntax      = errors.New("query syntax error")
	ErrQueryProcessing  = errors.New("unable to process query")
)

type QueryExecutionError struct {
	Query string
	Err   error
}

func (e *QueryExecutionError) Error() string {
	return e.Query + ": " + e.Err.Error()
}

func (e *QueryExecutionError) Unwrap() error {
	return e.Err
}

type Service struct {
	repo repository.Repository
}

func NewService(repo repository.Repository) *Service {
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

func (s *Service) Handle(ctx context.Context, req *internal.Request) (interface{}, error) {
	queryRequest := &QueryRequest{}
	if err := req.Unmarshal(queryRequest); err != nil {
		return nil, err
	}
	return s.Query(ctx, queryRequest)
}

func (s *Service) Query(ctx context.Context, req *QueryRequest) (*QueryResponse, error) {
	if err := validateServiceRequest(req); err != nil {
		return nil, err
	}

	unsafe, err := sqlparse.Parse(req.Query)
	if err != nil {
		return nil, ErrQuerySyntax
	}

	sanitized, err := sqlrewrite.RewriteEntryQuery(unsafe, req.UserID)
	if err != nil {
		return nil, ErrQueryProcessing
	}

	columns, results, err := s.repo.Execute(ctx, sanitized.String())
	if err != nil {
		return nil, &QueryExecutionError{
			Query: req.Query,
			Err:   err,
		}
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
