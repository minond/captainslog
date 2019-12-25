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

	contents, err := ioutil.ReadAll(r.Body)
	if err != nil {
		log.Printf("error: unable to read request body: %v", err)
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	var req ProcessingRequest
	if err := json.Unmarshal(contents, &req); err != nil {
		log.Printf("error: unable to parse request body: %v", err)
		respond(w, http.StatusBadRequest, message("unable to parse request body"))
		return
	}

	if req.Text == "" {
		log.Println("error: missing text in request")
		respond(w, http.StatusBadRequest, message("missing text in request"))
		return
	}

	if req.BookID == 0 {
		log.Println("error: missing book id in request")
		respond(w, http.StatusBadRequest, message("missing book id in request"))
		return
	}

	ctx := context.Background()

	extractors, err := s.repo.FindExtractors(ctx, req.BookID)
	if err != nil {
		log.Printf("error: unable to find extractors: %v", err)
		respond(w, http.StatusInternalServerError, message("unable to find extractors"))
		return
	}

	shorthands, err := s.repo.FindShorthands(ctx, req.BookID)
	if err != nil {
		log.Printf("error: unable to find shorthands: %v", err)
		respond(w, http.StatusInternalServerError, message("unable to find shorthands"))
		return
	}

	text, data, err := Process(req.Text, shorthands, extractors)
	if err != nil {
		log.Printf("error: unable process text: %v", err)
		respond(w, http.StatusInternalServerError, message("unable to process text"))
		return
	}

	respond(w, http.StatusOK, ProcessingResponse{
		Text: text,
		Data: data,
	})
}

func message(msg string) ProcessingResponse {
	return ProcessingResponse{Message: msg}
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
