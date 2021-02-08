package service

import (
	"bytes"
	"context"
	"database/sql"
	"net/http"
	"net/http/httptest"
	"reflect"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/DATA-DOG/go-txdb"
)

func init() {
	txdb.Register("txdb", "postgres", "testconn")
}

func assertEqual(t *testing.T, expected, returned interface{}) {
	t.Helper()
	if !reflect.DeepEqual(expected, returned) {
		t.Errorf(`error: not equal:
		expected: %v
		returned: %v`, expected, returned)
	}
}

func newMockDB(t *testing.T) (*sql.DB, sqlmock.Sqlmock) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("an error '%s' was not expected when opening a stub database connection", err)
	}
	return db, mock
}

func makeRequest(t *testing.T, rawBody string, handler ServiceHandler) *httptest.ResponseRecorder {
	body := bytes.NewBufferString(rawBody)
	req, err := http.NewRequest(http.MethodPost, "/", body)
	if err != nil {
		t.Fatalf("unexpected error from http.NewRequest: %v", err)
	}

	rr := httptest.NewRecorder()
	server := NewServer("", ServiceWrapper{handler})
	server.ServeHTTP(rr, req)

	return rr
}

type testResponse struct {
	Message string `json:"message"`
}

type testService struct{}

func (testService) Handle(ctx context.Context, req *Request) (interface{}, error) {
	return testResponse{}, nil
}
