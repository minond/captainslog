package main

import (
	"context"
	"errors"
)

var (
	ErrReqMissingText          = errors.New("missing text in request")
	ErrReqMissingBookID        = errors.New("missing book id in request")
	ErrUnableToFetchExtractors = errors.New("unable to fetch extractors")
	ErrUnableToFetchShorthands = errors.New("unable to fetch shorthands")
)

type Service struct {
	repo Repository
}

func NewService(repo Repository) *Service {
	return &Service{
		repo: repo,
	}
}

type ProcessingRequest struct {
	BookID int64  `json:"book_id"`
	Text   string `json:"text"`
}

type ProcessingResponse struct {
	Text string                 `json:"text,omitempty"`
	Data map[string]interface{} `json:"data,omitempty"`
}

func (s *Service) Handle(ctx context.Context, req *ProcessingRequest) (*ProcessingResponse, error) {
	if req.Text == "" {
		return nil, ErrReqMissingText
	}

	if req.BookID == 0 {
		return nil, ErrReqMissingBookID
	}

	extractors, err := s.repo.FindExtractors(ctx, req.BookID)
	if err != nil {
		return nil, ErrUnableToFetchExtractors
	}

	shorthands, err := s.repo.FindShorthands(ctx, req.BookID)
	if err != nil {
		return nil, ErrUnableToFetchShorthands
	}

	text, data, err := Process(req.Text, shorthands, extractors)
	if err != nil {
		return nil, err
	}

	return &ProcessingResponse{Text: text, Data: data}, nil
}
