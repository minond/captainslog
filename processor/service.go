package main

import (
	"context"
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
)

type ProcessingRequest struct {
	BookID int64  `json:"book_id"`
	Text   string `json:"text"`
}

type ProcessingResponse struct {
	Message string                 `json:"message"`
	Text    string                 `json:"text"`
	Data    map[string]interface{} `json:"data"`
}

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{
		repo: repo,
	}
}

func (s *Service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	log.Println("handling request")

	req, err := s.read(w, r)
	if err != nil {
		return
	}

	if !s.valid(w, req) {
		return
	}

	text, data, err := s.process(w, req)
	if err != nil {
		return
	}

	respond(w, http.StatusOK, ok(text, data))
}

func (s Service) read(w http.ResponseWriter, r *http.Request) (*ProcessingRequest, error) {
	contents, err := ioutil.ReadAll(r.Body)
	if err != nil {
		log.Printf("error: unable to read request body: %v", err)
		w.WriteHeader(http.StatusBadRequest)
		return nil, err
	}
	defer r.Body.Close()

	var req *ProcessingRequest
	if err := json.Unmarshal(contents, &req); err != nil {
		log.Printf("error: unable to parse request body: %v", err)
		respond(w, http.StatusBadRequest, message("unable to parse request body"))
		return nil, err
	}

	return req, nil
}

func (s Service) valid(w http.ResponseWriter, req *ProcessingRequest) bool {
	if req.Text == "" {
		log.Println("error: missing text in request")
		respond(w, http.StatusBadRequest, message("missing text in request"))
		return false
	}

	if req.BookID == 0 {
		log.Println("error: missing book id in request")
		respond(w, http.StatusBadRequest, message("missing book id in request"))
		return false
	}

	return true
}

func (s Service) process(w http.ResponseWriter, req *ProcessingRequest) (string, map[string]interface{}, error) {
	ctx := context.Background()
	extractors, err := s.repo.FindExtractors(ctx, req.BookID)
	if err != nil {
		log.Printf("error: unable to find extractors: %v", err)
		respond(w, http.StatusInternalServerError, message("unable to find extractors"))
		return "", nil, err
	}

	shorthands, err := s.repo.FindShorthands(ctx, req.BookID)
	if err != nil {
		log.Printf("error: unable to find shorthands: %v", err)
		respond(w, http.StatusInternalServerError, message("unable to find shorthands"))
		return "", nil, err
	}

	text, data, err := Process(req.Text, shorthands, extractors)
	if err != nil {
		log.Printf("error: unable process text: %v", err)
		respond(w, http.StatusInternalServerError, message("unable to process text"))
		return "", nil, err
	}

	return text, data, nil
}

func message(msg string) ProcessingResponse {
	return ProcessingResponse{Message: msg}
}

func ok(text string, data map[string]interface{}) ProcessingResponse {
	return ProcessingResponse{
		Text: text,
		Data: data,
	}
}

func respond(w http.ResponseWriter, statusCode int, res interface{}) error {
	resBody, err := json.Marshal(res)
	if err != nil {
		log.Printf("error: unable marshal response: %v", err)
		w.WriteHeader(http.StatusInternalServerError)
		return err
	}

	w.WriteHeader(statusCode)
	w.Write(resBody)
	return nil
}
