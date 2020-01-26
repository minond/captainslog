package main

import (
	"bytes"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/minond/captainslog/querier/repository"
	internaltesting "github.com/minond/captainslog/querier/testing"
)

func makeRequest(t *testing.T, rawBody string, repo repository.Repository) *httptest.ResponseRecorder {
	body := bytes.NewBufferString(rawBody)
	req, err := http.NewRequest(http.MethodPost, "/", body)
	if err != nil {
		t.Fatalf("unexpected error from http.NewRequest: %v", err)
	}

	rr := httptest.NewRecorder()
	service := NewService(repo)
	server, err := NewServer(service)
	if err != nil {
		t.Fatalf("unexpected error from NewServer: %v", err)
	}

	server.ServeHTTP(rr, req)

	return rr
}

func TestNewServer_Error_MissingDBConn(t *testing.T) {
	_, err := NewServerFromConfig(Config{})
	internaltesting.AssertEqual(t, errors.New("missing database connection value (QUERIER_DB_CONN)"), err)
}

func TestNewServer_Error_MissingHTTPListen(t *testing.T) {
	_, err := NewServerFromConfig(Config{dbConn: "A"})
	internaltesting.AssertEqual(t, errors.New("missing http listen value (QUERIER_HTTP_LISTEN)"), err)
}

func TestNewServer_HappyPath_OpenDatabase(t *testing.T) {
	_, err := NewServerFromConfig(Config{
		dbDriver:   "txdb",
		dbConn:     "testconn",
		httpListen: ":8080",
	})
	internaltesting.AssertEqual(t, nil, err)
}

func TestServer_Error_BadJSON(t *testing.T) {
	rr := makeRequest(t, ``, nil)
	internaltesting.AssertEqual(t, http.StatusBadRequest, rr.Code)
	internaltesting.AssertEqual(t, `{"error":"unable to parse request body"}`, rr.Body.String())
}

func TestServer_Error_MissingUserID(t *testing.T) {
	rr := makeRequest(t, `{"query": "select 1"}`, nil)
	internaltesting.AssertEqual(t, http.StatusBadRequest, rr.Code)
	internaltesting.AssertEqual(t, `{"error":"unable to handle query: missing user id in request"}`, rr.Body.String())
}

func TestServer_Error_MissingQuery(t *testing.T) {
	rr := makeRequest(t, `{"user_id": 1}`, nil)
	internaltesting.AssertEqual(t, http.StatusBadRequest, rr.Code)
	internaltesting.AssertEqual(t, `{"error":"unable to handle query: missing query in request"}`, rr.Body.String())
}

func TestServer_Error_ExecutionError(t *testing.T) {
	rr := makeRequest(t, `{"user_id": 1, "query":"select 1"}`, &internaltesting.TestRepository{
		Err: errors.New("bad"),
	})
	internaltesting.AssertEqual(t, http.StatusBadRequest, rr.Code)
	internaltesting.AssertEqual(t, `{"error":"unable to handle query: select 1: bad"}`, rr.Body.String())
}

func TestServer_HappyPath_ServeHTTP(t *testing.T) {
	rr := makeRequest(t, `{"user_id": 1, "query":"select 1"}`, &internaltesting.TestRepository{
		Cols: []string{"one", "two", "three"},
		Rows: [][]interface{}{
			{"1", "2", "3"},
			{"4", "5", "6"},
		},
	})
	internaltesting.AssertEqual(t, http.StatusOK, rr.Code)
	internaltesting.AssertEqual(t, `{"data":{"columns":["one","two","three"],"results":[["1","2","3"],["4","5","6"]]}}`, rr.Body.String())
}

func TestServer_AddGetterSetter(t *testing.T) {
	server, _ := NewServer(nil)
	server.SetAddr("xs")
	internaltesting.AssertEqual(t, "xs", server.Addr())
}
