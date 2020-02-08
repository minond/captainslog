package main

import (
	"bytes"
	"context"
	"database/sql"
	"net/http"
	"net/http/httptest"
	"reflect"
	"testing"

	"github.com/DATA-DOG/go-txdb"

	"github.com/DATA-DOG/go-sqlmock"
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

func newMockRepo(t *testing.T) (Repository, *sql.DB, sqlmock.Sqlmock) {
	db, mock := newMockDB(t)
	return NewRepository(db), db, mock
}

func makeRequest(t *testing.T, rawBody string, repo Repository) *httptest.ResponseRecorder {
	body := bytes.NewBufferString(rawBody)
	req, err := http.NewRequest(http.MethodPost, "/", body)
	if err != nil {
		t.Fatalf("unexpected error from http.NewRequest: %v", err)
	}

	rr := httptest.NewRecorder()
	service := NewService(repo, NewProcessor())
	server, err := NewServer(service)
	if err != nil {
		t.Fatalf("unexpected error from NewServer: %v", err)
	}

	server.ServeHTTP(rr, req)

	return rr
}

type testRepository struct {
	extractorLookupError error
	shorthandLookupError error
	extractors           []Extractor
	shorthands           []Shorthand
}

func (r testRepository) FindExtractors(ctx context.Context, bookID int64) ([]Extractor, error) {
	return r.extractors, r.extractorLookupError
}

func (r testRepository) FindShorthands(ctx context.Context, bookID int64) ([]Shorthand, error) {
	return r.shorthands, r.shorthandLookupError
}

type testProcessor struct {
	text string
	data map[string]interface{}
	err  error
}

func (r testProcessor) Process(text string, ss []Shorthand, es []Extractor) (string, map[string]interface{}, error) {
	return r.text, r.data, r.err
}
