package repository

import (
	"context"
	"database/sql/driver"
	"encoding/json"
	"testing"

	internaltesting "github.com/minond/captainslog/querier/testing"

	"github.com/DATA-DOG/go-sqlmock"
)

var (
	tableCols = []string{"one", "two"}

	firstRow  = []driver.Value{"one", "two"}
	secondRow = []driver.Value{"one", "two"}
)

// TODO Test using a real database

func TestRepository_Handle_ReturnsTheRightColumns(t *testing.T) {
	repo, db, mock := newMockRepo(t)
	defer db.Close()

	rows := sqlmock.NewRows(tableCols).
		AddRow(firstRow...).
		AddRow(secondRow...)

	mock.ExpectQuery("^select one, two from entries").
		WillReturnRows(rows)

	ctx := context.TODO()
	returnedCols, _, err := repo.Execute(ctx, "select one, two from entries")
	if err != nil {
		t.Fatalf("unexpected error from repo.Execute: %v", err)
	}

	internaltesting.AssertEqual(t, tableCols, returnedCols)
}

func TestRepository_Handle_ReturnsTheRightRows(t *testing.T) {
	repo, db, mock := newMockRepo(t)
	defer db.Close()

	rows := sqlmock.NewRows(tableCols).
		AddRow(firstRow...).
		AddRow(secondRow...)

	mock.ExpectQuery("^select one, two from entries").
		WillReturnRows(rows)

	ctx := context.TODO()
	_, returnedRows, err := repo.Execute(ctx, "select one, two from entries")
	if err != nil {
		t.Fatalf("unexpected error from repo.Execute: %v", err)
	}

	data, err := json.Marshal(returnedRows)
	if err != nil {
		t.Fatalf("unexpected error while marshaling returned rows: %v", err)
	}

	internaltesting.AssertEqual(t, string(data), `[[{"String":"one","Valid":true},{"String":"two","Valid":true}],[{"String":"one","Valid":true},{"String":"two","Valid":true}]]`)
}
