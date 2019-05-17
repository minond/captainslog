package model

import (
	"testing"
	"time"
)

func TestBetween(t *testing.T) {
	start := 10
	end := 20

	cond := Between(Schema.Collection.CreatedAt, start, end)(Schema.Collection)
	sql, args, err := cond.ToSql()

	if err != nil {
		t.Errorf("unexpected error for between: %v", err)
	}

	if sql != "__collection.created_at between ? and ?" {
		t.Errorf("unexpected sql for between: %v", sql)
	}

	if len(args) < 2 {
		t.Errorf("unexpected args for between: %v", args)
	} else if args[0] != start || args[1] != end {
		t.Errorf("unexpected args for between: %v", args)
	}
}

func TestBetweenTimes(t *testing.T) {
	start := time.Date(2019, time.Month(3), 30, 9, 0, 0, 0, time.UTC)
	end := time.Date(2019, time.Month(3), 30, 10, 0, 0, -1, time.UTC)

	expectedStart := "2019-03-30T09:00:00Z"
	expectedEnd := "2019-03-30T09:59:59Z"

	cond := BetweenTimes(Schema.Collection.CreatedAt, start, end)(Schema.Collection)
	sql, args, err := cond.ToSql()

	if err != nil {
		t.Errorf("unexpected error for between: %v", err)
	}

	if sql != "__collection.created_at between ? and ?" {
		t.Errorf("unexpected sql for between: %v", sql)
	}

	if len(args) < 2 {
		t.Errorf("unexpected args for between: %v", args)
	} else if args[0] != expectedStart || args[1] != expectedEnd {
		t.Errorf("unexpected args for between: %v", args)
	}
}

func TestSubquery(t *testing.T) {
	expectedName := "workouts"
	factory := Subquery(
		Schema.Entry.BookFK, Eq,
		Schema.Book.GUID, Schema.Book.BaseSchema,
		Schema.Book.Name, Like, expectedName,
	)

	subq := factory(Schema.Entry)
	sql, args, err := subq.ToSql()

	if err != nil {
		t.Errorf("unexpected error for subquery: %v", err)
	}

	if sql != "__entry.book_guid = (select guid from books where name like ?)" {
		t.Errorf("unexpected sql for subquery: %v", sql)
	}

	if len(args) != 1 {
		t.Errorf("expected only one arg for subquery but got: %v", args)
	} else if args[0] != expectedName {
		t.Errorf("unexpected arg for subquery: %v", args)
	}
}
