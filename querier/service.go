package main

import (
	"context"
	"errors"
)

var (
	ErrReqMissingQuery  = errors.New("missing user id in request")
	ErrReqMissingUserID = errors.New("missing query in request")
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
	Rows    [][]interface{} `json:"columns"`
}

func (s *Service) Handle(ctx context.Context, req *QueryRequest) (*QueryResponse, error) {
	if err := validateServiceRequest(req); err != nil {
		return nil, err
	}

	return nil, nil
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
