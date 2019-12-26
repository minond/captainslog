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
	ErrUnableProcessText       = errors.New("unable to process text")
)

type Service struct {
	repo      Repository
	processor Processor
}

func NewService(repo Repository, processor Processor) *Service {
	return &Service{
		repo:      repo,
		processor: processor,
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
	if err := s.validate(req); err != nil {
		return nil, err
	}

	extractors, err := s.repo.FindExtractors(ctx, req.BookID)
	if err != nil {
		return nil, ErrUnableToFetchExtractors
	}

	shorthands, err := s.repo.FindShorthands(ctx, req.BookID)
	if err != nil {
		return nil, ErrUnableToFetchShorthands
	}

	text, data, err := s.processor.Process(req.Text, shorthands, extractors)
	if err != nil {
		return nil, ErrUnableProcessText
	}

	return &ProcessingResponse{Text: text, Data: data}, nil
}

func (s *Service) validate(req *ProcessingRequest) error {
	if req.Text == "" {
		return ErrReqMissingText
	}

	if req.BookID == 0 {
		return ErrReqMissingBookID
	}

	return nil
}
