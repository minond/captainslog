package main

import (
	"bytes"
	"context"
	"net/http"
	"net/http/httptest"
	"reflect"
	"testing"

	txdb "github.com/DATA-DOG/go-txdb"
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

// func newMockDB(t *testing.T) (*sql.DB, sqlmock.Sqlmock) {
// 	db, mock, err := sqlmock.New()
// 	if err != nil {
// 		t.Fatalf("an error '%s' was not expected when opening a stub database connection", err)
// 	}
// 	return db, mock
// }

// func newMockRepo(t *testing.T) (Repository, *sql.DB, sqlmock.Sqlmock) {
// 	db, mock := newMockDB(t)
// 	return NewRepository(db), db, mock
// }

func makeRequest(t *testing.T, rawBody string, repo Repository) *httptest.ResponseRecorder {
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

type testRepository struct {
	cols []string
	rows [][]interface{}
	err  error
}

func (r testRepository) Execute(ctx context.Context, query string) ([]string, [][]interface{}, error) {
	return r.cols, r.rows, r.err
}
