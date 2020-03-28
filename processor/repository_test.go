package main

import (
	"context"
	"database/sql/driver"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
)

var (
	extractorColumns = []string{"label", "match", "type"}

	firstExtractor = Extractor{
		Label:    "a",
		Match:    "/a/",
		DataType: NumberData,
	}

	firstExtractorRow = []driver.Value{
		firstExtractor.Label,
		firstExtractor.Match,
		firstExtractor.DataType,
	}

	secondExtractor = Extractor{
		Label:    "b",
		Match:    "/b/",
		DataType: BooleanData,
	}

	secondExtractorRow = []driver.Value{
		secondExtractor.Label,
		secondExtractor.Match,
		secondExtractor.DataType,
	}
)

func TestRepository_FindExtractors(t *testing.T) {
	repo, db, mock := newMockRepo(t)
	defer db.Close()

	bookID := int64(2)

	rows := sqlmock.NewRows(extractorColumns).
		AddRow(firstExtractorRow...).
		AddRow(secondExtractorRow...)

	mock.ExpectQuery("^select (.+) from extractors").
		WithArgs(bookID).
		WillReturnRows(rows)

	ctx := context.TODO()
	extractors, err := repo.FindExtractors(ctx, bookID)
	if err != nil {
		t.Fatalf("unexpected error from repo.FindExtractors: %v", err)
	}

	assertEqual(t, firstExtractor, extractors[0])
	assertEqual(t, secondExtractor, extractors[1])
}

var (
	shorthandColumns = []string{"priority", "expansion", "match", "text"}

	firstShorthandMatch = "a"
	firstShorthandText  = "a"
	firstShorthand      = Shorthand{
		Priority:  1,
		Expansion: "a",
		Match:     &firstShorthandMatch,
		Text:      &firstShorthandText,
	}

	firstShorthandRow = []driver.Value{
		firstShorthand.Priority,
		firstShorthand.Expansion,
		firstShorthand.Match,
		firstShorthand.Text,
	}

	secondShorthandMatch = "b"
	secondShorthandText  = "b"
	secondShorthand      = Shorthand{
		Priority:  2,
		Expansion: "b",
		Match:     &secondShorthandMatch,
		Text:      &secondShorthandText,
	}

	secondShorthandRow = []driver.Value{
		secondShorthand.Priority,
		secondShorthand.Expansion,
		secondShorthand.Match,
		secondShorthand.Text,
	}
)

func TestRepository_FindShorthands(t *testing.T) {
	repo, db, mock := newMockRepo(t)
	defer db.Close()

	bookID := int64(2)

	rows := sqlmock.NewRows(shorthandColumns).
		AddRow(firstShorthandRow...).
		AddRow(secondShorthandRow...)

	mock.ExpectQuery("^select (.+) from shorthands").
		WithArgs(bookID).
		WillReturnRows(rows)

	ctx := context.TODO()
	shorthands, err := repo.FindShorthands(ctx, bookID)
	if err != nil {
		t.Fatalf("unexpected error from repo.FindShorthands: %v", err)
	}

	assertEqual(t, firstShorthand, shorthands[0])
	assertEqual(t, secondShorthand, shorthands[1])
}
