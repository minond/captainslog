package internal

import (
	"context"
	"encoding/json"
	"errors"
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

type Request struct {
	contents []byte
}

func (r *Request) Unmarshal(v interface{}) error {
	if err := json.Unmarshal(r.contents, v); err != nil {
		return errors.New("unable to parse request body")
	}
	return nil
}

type ServiceHandler func(context.Context, *Request) (interface{}, error)

type ServiceWrapper struct {
	handler ServiceHandler
}

func (s ServiceWrapper) Handle(ctx context.Context, req *Request) (interface{}, error) {
	return s.handler(ctx, req)
}

type Service interface {
	Handle(context.Context, *Request) (interface{}, error)
}

type Server struct {
	service      Service
	httpListener *http.Server
}

func NewServer(listen string, service Service) *Server {
	s := &Server{}
	s.service = service
	s.httpListener = &http.Server{Handler: s}
	s.SetAddr(listen)
	return s
}

func (s *Server) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	log.Println("handling request")

	req, err := readRequest(w, r)
	if err != nil {
		return
	}

	res, err := s.service.Handle(context.Background(), req)
	if err != nil {
		respond(w, http.StatusBadRequest, errResponse(err.Error()))
		return
	}

	respond(w, http.StatusOK, okResponse(res))
}

func (s *Server) SetAddr(addr string) {
	s.httpListener.Addr = addr
}

func (s *Server) Addr() string {
	return s.httpListener.Addr
}

func (s *Server) Start() {
	if err := s.httpListener.ListenAndServe(); err != nil {
		log.Fatal(err)
	}
}

func (s *Server) ListenForShutdown() {
	stopper := make(chan os.Signal, 1)
	signal.Notify(stopper, os.Interrupt)
	<-stopper

	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	_ = s.httpListener.Shutdown(ctx)
}

func (s *Server) Run() {
	log.Printf("listening on %s", s.Addr())
	go s.Start()
	s.ListenForShutdown()
	log.Print("server shutdown is complete")
}

func readRequest(w http.ResponseWriter, r *http.Request) (*Request, error) {
	contents, err := ioutil.ReadAll(r.Body)
	if err != nil {
		log.Printf("error: unable to read request body: %v", err)
		w.WriteHeader(http.StatusBadRequest)
		return nil, err
	}
	defer r.Body.Close()

	return &Request{contents: contents}, nil
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

func errResponse(msg string) Response {
	return Response{Error: msg}
}

func okResponse(res interface{}) Response {
	return Response{Data: res}
}
