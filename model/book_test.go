package model

import (
	"regexp"
	"testing"
	"time"
)

func TestBook_timeRange(t *testing.T) {
	now := time.Now().In(time.UTC)
	year, month, day := now.Date()

	expectedStart := time.Date(year, month, day, 0, 0, 0, 0, time.UTC)
	expectedEnd := time.Date(year, month, day+1, 0, 0, 0, -1, time.UTC)

	start, end, err := timeRange(GroupingDay, now)
	if err != nil {
		t.Errorf("unexpected error: %v", err)
	}

	if start != expectedStart {
		t.Errorf("unexpected start: %v", start)
	}

	if end != expectedEnd {
		t.Errorf("unexpected end: %v", end)
	}
}

func TestBook_timeRange_BadGrouping(t *testing.T) {
	var err error

	now := time.Now().In(time.UTC)
	_, _, err = timeRange(GroupingNone, now)
	if err == nil {
		t.Error("expected GroupingNone to return an error")
	}

	_, _, err = timeRange(Grouping(GroupingDay+1), now)
	if err == nil {
		t.Error("expected max[Grouping] + 1 to return an error")
	}
}

func TestBook_activeCollectionQuery(t *testing.T) {
	now := time.Now().In(time.UTC)
	user, _ := NewUser()
	book, _ := NewBook("testing", int32(GroupingDay), user)

	query, err := collectionQuery(book, now)
	if err != nil {
		t.Errorf("unexpected error: %v", err)
	}

	sql, args, err := query.ToSql()
	if err != nil {
		t.Errorf("unexpected error: %v", err)
	}

	cleaner := regexp.MustCompile(`\s+`)
	expectedSQL := cleaner.ReplaceAll([]byte(`
		SELECT __collection.guid, __collection.open, __collection.created_at,
			__collection.book_guid
		FROM collections __collection
		WHERE __collection.book_guid = $1
		AND __collection.open = $2
		AND __collection.created_at between $3 and $4
	`), []byte{})

	if string(cleaner.ReplaceAll([]byte(sql), []byte{})) != string(expectedSQL) {
		t.Errorf(`unexpected sql

returned: %v

expected: %v`, sql, string(expectedSQL))
	}

	if len(args) != 4 {
		t.Errorf("unexpected args: %v", args)
	}

	if args[0] != book.GUID.String() || args[1] != true {
		t.Errorf("unexpected args: %v", args)
	}
}

func TestBook_activeCollectionQuery_BadGrouping(t *testing.T) {
	now := time.Now().In(time.UTC)
	user, _ := NewUser()
	book, _ := NewBook("testing", int32(GroupingDay), user)
	book.Grouping = 77

	_, err := collectionQuery(book, now)
	if err == nil {
		t.Error("expected error with book.Grouping = 77 but got none")
	}
}
