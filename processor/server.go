package main

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"time"
)

type ServerConfig struct {
	dbConn     string
	httpListen string
}

type Server struct {
	server *http.Server
}

func NewServer(config ServerConfig) (*Server, error) {
	if config.dbConn == "" {
		return nil, errors.New("missing database connection value (PROCESSOR_DB_CONN)")
	}

	if config.httpListen == "" {
		return nil, errors.New("missing http listen value (PROCESSOR_HTTP_LISTEN)")
	}

	db, err := sql.Open("postgres", config.dbConn)
	if err != nil {
		return nil, fmt.Errorf("unable to open database connection: %v", err)
	}

	repo := NewRepository(db)
	serv := NewService(repo)

	return &Server{&http.Server{
		Addr:    config.httpListen,
		Handler: serv,
	}}, nil
}

func (s *Server) Start() {
	if err := s.server.ListenAndServe(); err != nil {
		log.Fatal(err)
	}
}

func (s *Server) ListenForShutdown() {
	stopper := make(chan os.Signal, 1)
	signal.Notify(stopper, os.Interrupt)
	<-stopper

	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	_ = s.server.Shutdown(ctx)
}
