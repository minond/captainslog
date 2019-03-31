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
	} else if args[0] != start || args[1] != end {
		t.Errorf("unexpected args for between: %v", args)
	}
}
