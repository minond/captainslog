package main

import (
	"net/http"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
)

func TestService_Error_MissingText(t *testing.T) {
	rr := makeRequest(t, `{}`, nil)
	assertEqual(t, http.StatusBadRequest, rr.Code)
	assertEqual(t, `{"message":"missing text in request"}`, rr.Body.String())
}

func TestService_Error_MissingBookID(t *testing.T) {
	rr := makeRequest(t, `{"text":"hi"}`, nil)
	assertEqual(t, http.StatusBadRequest, rr.Code)
	assertEqual(t, `{"message":"missing book id in request"}`, rr.Body.String())
}

func TestService_HappyPath_ServeHTTP(t *testing.T) {
	repo, db, mock := newMockRepo(t)
	defer db.Close()

	bookID := int64(2)

	mock.ExpectQuery("^select (.+) from extractors").
		WithArgs(bookID).
		WillReturnRows(
			sqlmock.NewRows(extractorColumns).
				AddRow(firstExtractorRow...).
				AddRow(secondExtractorRow...))

	mock.ExpectQuery("^select (.+) from shorthands").
		WithArgs(bookID).
		WillReturnRows(
			sqlmock.NewRows(shorthandColumns).
				AddRow(firstShorthandRow...).
				AddRow(secondShorthandRow...))

	rr := makeRequest(t, `{"text":"hi","book_id":2}`, repo)
	assertEqual(t, http.StatusOK, rr.Code)
}
