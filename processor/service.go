package main

import (
	"log"
	"net/http"
)

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
	w.Write([]byte("hello"))
}
