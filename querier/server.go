package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/signal"
	"time"
)

type Response struct {
	Error string      `json:"error,omitempty"`
	Data  interface{} `json:"data,omitempty"`
}

type ServerConfig struct {
	dbConn     string
	dbDriver   string
	httpListen string
}

type Server struct {
	service *Service
	server  *http.Server
}

func NewServer(service *Service) (*Server, error) {
	s := &Server{}
	s.service = service
	s.server = &http.Server{Handler: s}
	return s, nil
}

func NewServerFromConfig(config ServerConfig) (*Server, error) {
	if config.dbConn == "" {
		return nil, errors.New("missing database connection value (QUERIER_DB_CONN)")
	}

	if config.httpListen == "" {
		return nil, errors.New("missing http listen value (QUERIER_HTTP_LISTEN)")
	}

	driver := "postgres"
	if config.dbDriver != "" {
		driver = config.dbDriver
	}

	db, err := sql.Open(driver, config.dbConn)
	if err != nil {
		return nil, fmt.Errorf("unable to open database connection: %v", err)
	}

	repo := NewRepository(db)
	service := NewService(repo)
	server, err := NewServer(service)
	if err != nil {
		return nil, err
	}

	server.SetAddr(config.httpListen)
	return server, nil
}

func NewServerFromEnv() (*Server, error) {
	return NewServerFromConfig(ServerConfig{
		dbConn:     os.Getenv("QUERIER_DB_CONN"),
		httpListen: os.Getenv("QUERIER_HTTP_LISTEN"),
	})
}

func (s *Server) SetAddr(addr string) {
	s.server.Addr = addr
}

func (s *Server) Addr() string {
	return s.server.Addr
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

func (s *Server) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	log.Println("handling request")

	req, err := s.read(w, r)
	if err != nil {
		return
	}

	res, err := s.service.Handle(context.Background(), req)
	if err != nil {
		respond(w, http.StatusBadRequest, errResponse(fmt.Sprintf("unable to handle query: %v", err)))
		return
	}

	respond(w, http.StatusOK, okResponse(res))
}

func (s Server) read(w http.ResponseWriter, r *http.Request) (*QueryRequest, error) {
	contents, err := ioutil.ReadAll(r.Body)
	if err != nil {
		log.Printf("error: unable to read request body: %v", err)
		w.WriteHeader(http.StatusBadRequest)
		return nil, err
	}
	defer r.Body.Close()

	var req *QueryRequest
	if err := json.Unmarshal(contents, &req); err != nil {
		log.Printf("error: unable to parse request body: %v", err)
		respond(w, http.StatusBadRequest, errResponse("unable to parse request body"))
		return nil, err
	}

	return req, nil
}

func errResponse(msg string) Response {
	return Response{Error: msg}
}

func okResponse(res *QueryResponse) Response {
	return Response{Data: res}
}

func respond(w http.ResponseWriter, statusCode int, res Response) error {
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
