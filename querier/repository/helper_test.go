package repository

import (
	"database/sql"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
)

func newMockDB(t *testing.T) (*sql.DB, sqlmock.Sqlmock) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("an error '%s' was not expected when opening a stub database connection", err)
	}
	return db, mock
}

func newMockRepo(t *testing.T) (Repository, *sql.DB, sqlmock.Sqlmock) {
	db, mock := newMockDB(t)
	return New(db), db, mock
}
