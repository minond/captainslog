package model

import (
	"database/sql"
	"errors"

	"gopkg.in/src-d/go-kallax.v1"
)

// Shorthand is a shorthand/abbreviation that may be used in an entry.
// Shorthands can be made up of regular expression matches (Match) or plain
// text matches (Text), or a combination of the two. An expansion is always
// required. Rules for exapansion:
//
// Rule #1: When Text is not nil and Match is nil, Text will be replaced with
// Expansion in the entry.
//
// Rule #2: When Text is not nil and Match is not nil, if Match matches the
// entry, Text will be replaced with Expansion in the entry.
//
// Rule #3: When Text is nil and Match is not nil, Match will be replaced with
// Expansion in the entry.
//
// Rule #4: If both Text and Match are nil this is an invalid Shorthand and an
// error is returned.
type Shorthand struct {
	kallax.Model `table:"shorthands" pk:"guid"`

	GUID      kallax.ULID `json:"guid"`
	BookGUID  kallax.ULID
	Expansion string
	Match     *sql.NullString `sqltype:"text"`
	Text      *sql.NullString `sqltype:"text"`
}

func newShorthand(expansion, match, text string, book *Book) (*Shorthand, error) {
	validMatch := match != ""
	validText := text != ""
	if !validMatch && !validText {
		return nil, errors.New("a text value of match value is required for a shorthand to be valid")
	}

	shorthand := &Shorthand{
		GUID:      kallax.NewULID(),
		Expansion: expansion,
		Match:     &sql.NullString{String: match, Valid: validMatch},
		Text:      &sql.NullString{String: text, Valid: validText},
	}

	if shorthand != nil {
		shorthand.BookGUID = book.GUID
	}

	return shorthand, nil
}
