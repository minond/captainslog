package main

import (
	"errors"
	"net/http"
	"testing"
)

func TestNewServer_Error_MissingDBConn(t *testing.T) {
	_, err := NewServerFromConfig(ServerConfig{})
	assertEqual(t, errors.New("missing database connection value (QUERIER_DB_CONN)"), err)
}

func TestNewServer_Error_MissingHTTPListen(t *testing.T) {
	_, err := NewServerFromConfig(ServerConfig{dbConn: "A"})
	assertEqual(t, errors.New("missing http listen value (QUERIER_HTTP_LISTEN)"), err)
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

func TestServer_Error_MissingUserID(t *testing.T) {
	rr := makeRequest(t, `{"query": "select 1"}`, nil)
	assertEqual(t, http.StatusBadRequest, rr.Code)
	assertEqual(t, `{"error":"unable to handle query: missing user id in request"}`, rr.Body.String())
}

func TestServer_Error_MissingQuery(t *testing.T) {
	rr := makeRequest(t, `{"user_id": 1}`, nil)
	assertEqual(t, http.StatusBadRequest, rr.Code)
	assertEqual(t, `{"error":"unable to handle query: missing query in request"}`, rr.Body.String())
}

func TestServer_Error_ExecutionError(t *testing.T) {
	rr := makeRequest(t, `{"user_id": 1, "query":"select 1"}`, &testRepository{
		err: errors.New("bad"),
	})
	assertEqual(t, http.StatusBadRequest, rr.Code)
	assertEqual(t, `{"error":"unable to handle query: select 1: bad"}`, rr.Body.String())
}

func TestServer_HappyPath_ServeHTTP(t *testing.T) {
	rr := makeRequest(t, `{"user_id": 1, "query":"select 1"}`, &testRepository{
		cols: []string{"one", "two", "three"},
		rows: [][]interface{}{
			{"1", "2", "3"},
			{"4", "5", "6"},
		},
	})
	assertEqual(t, http.StatusOK, rr.Code)
	assertEqual(t, `{"data":{"columns":["one","two","three"],"results":[["1","2","3"],["4","5","6"]]}}`, rr.Body.String())
}

func TestServer_AddGetterSetter(t *testing.T) {
	server, _ := NewServer(nil)
	server.SetAddr("xs")
	assertEqual(t, "xs", server.Addr())
}
