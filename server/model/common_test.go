package model

import "testing"

func TestBetween_Numbers(t *testing.T) {
	cond := Between(Schema.Collection.CreatedAt, 10, 20)(Schema.Collection)
	sql, args, err := cond.ToSql()

	if err != nil {
		t.Errorf("unexpected error for between: %v", err)
	}

	if sql != "__collection.created_at between ? and ?" {
		t.Errorf("unexpected sql for between: %v", sql)
	}

	if len(args) < 2 {
		t.Errorf("unexpected args for between: %v", args)
	} else if args[0] != 10 || args[1] != 20 {
		t.Errorf("unexpected args for between: %v", args)
	}
}
