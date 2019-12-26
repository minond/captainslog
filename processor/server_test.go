package main

import (
	"errors"
	"net/http"
	"testing"
)

func TestNewServer_Error_MissingDBConn(t *testing.T) {
	_, err := NewServerFromConfig(ServerConfig{})
	assertEqual(t, errors.New("missing database connection value (PROCESSOR_DB_CONN)"), err)
}

func TestNewServer_Error_MissingHTTPListen(t *testing.T) {
	_, err := NewServerFromConfig(ServerConfig{dbConn: "A"})
	assertEqual(t, errors.New("missing http listen value (PROCESSOR_HTTP_LISTEN)"), err)
}

func TestNewServer_HappyPath_OpenDatabase(t *testing.T) {
	_, err := NewServerFromConfig(ServerConfig{
		dbDriver:   "txdb",
		dbConn:     "testconn",
		httpListen: ":8080",
	})
	assertEqual(t, nil, err)
}

func TestServer_Error_BadJSON(t *testing.T) {
	rr := makeRequest(t, ``, nil)
	assertEqual(t, http.StatusBadRequest, rr.Code)
	assertEqual(t, `{"error":"unable to parse request body"}`, rr.Body.String())
}

func TestServer_Error_MissingText(t *testing.T) {
	rr := makeRequest(t, `{}`, nil)
	assertEqual(t, http.StatusBadRequest, rr.Code)
	assertEqual(t, `{"error":"unable to process text: missing text in request"}`, rr.Body.String())
}

func TestServer_Error_MissingBookID(t *testing.T) {
	rr := makeRequest(t, `{"text":"hi"}`, nil)
	assertEqual(t, http.StatusBadRequest, rr.Code)
	assertEqual(t, `{"error":"unable to process text: missing book id in request"}`, rr.Body.String())
}

func TestServer_Error_ExtractorLookup(t *testing.T) {
	rr := makeRequest(t, `{"text":"hi","book_id":2}`, &testRepository{
		extractorLookupError: errors.New("bad"),
	})
	assertEqual(t, http.StatusBadRequest, rr.Code)
	assertEqual(t, `{"error":"unable to process text: unable to fetch extractors"}`, rr.Body.String())
}

func TestServer_Error_ShorhandLookup(t *testing.T) {
	rr := makeRequest(t, `{"text":"hi","book_id":2}`, &testRepository{
		shorthandLookupError: errors.New("bad"),
	})
	assertEqual(t, http.StatusBadRequest, rr.Code)
	assertEqual(t, `{"error":"unable to process text: unable to fetch shorthands"}`, rr.Body.String())
}

func TestServer_HappyPath_ServeHTTP(t *testing.T) {
	rr := makeRequest(t, `{"text":"hi","book_id":2}`, &testRepository{})
	assertEqual(t, http.StatusOK, rr.Code)
	assertEqual(t, `{"data":{"text":"hi"}}`, rr.Body.String())
}

func TestServer_AddGetterSetter(t *testing.T) {
	server, _ := NewServer(nil)
	server.SetAddr("xs")
	assertEqual(t, "xs", server.Addr())
}
