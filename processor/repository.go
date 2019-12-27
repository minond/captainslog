package main

import (
	"context"
	"database/sql"

	_ "github.com/lib/pq"
)

type Repository interface {
	FindShorthands(context.Context, int64) ([]Shorthand, error)
	FindExtractors(context.Context, int64) ([]Extractor, error)
}

type repository struct {
	db *sql.DB
}

func NewRepository(db *sql.DB) Repository {
	return &repository{
		db: db,
	}
}

func (r *repository) FindExtractors(ctx context.Context, bookID int64) ([]Extractor, error) {
	var extractors []Extractor

	rows, err := r.db.QueryContext(ctx, "select label, match, type from extractors where book_id = $1", bookID)
	if err != nil {
		return nil, err
	}

	defer rows.Close()
	for rows.Next() {
		var label string
		var match string
		var typ DataType

		if err := rows.Scan(&label, &match, &typ); err != nil {
			return nil, err
		}

		extractor := Extractor{
			Label: label,
			Match: match,
			Type:  typ,
		}

		extractors = append(extractors, extractor)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return extractors, nil
}

func (r *repository) FindShorthands(ctx context.Context, bookID int64) ([]Shorthand, error) {
	var shorthands []Shorthand

	rows, err := r.db.QueryContext(ctx, "select priority, expansion, match, text from shorthands where book_id = $1", bookID)
	if err != nil {
		return nil, err
	}

	defer rows.Close()
	for rows.Next() {
		var priority int
		var expansion string
		var match sql.NullString
		var text sql.NullString

		if err := rows.Scan(&priority, &expansion, &match, &text); err != nil {
			return nil, err
		}

		shorthand := Shorthand{
			Priority:  priority,
			Expansion: expansion,
		}

		if match.Valid {
			shorthand.Match = &match.String
		}

		if text.Valid {
			shorthand.Text = &text.String
		}

		shorthands = append(shorthands, shorthand)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return shorthands, nil
}
