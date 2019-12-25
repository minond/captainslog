package processor

import "fmt"

// DataType represents the data type of extracted data.
type DataType int32

const (
	StringData DataType = iota
	NumberData
	BooleanData
)

type Extractor struct {
	Label string
	Match string
	Type  DataType
}

func (e Extractor) String() string {
	return fmt.Sprintf("<#extractor label: `%s` match: `%s` type: %d>",
		e.Label, e.Match, e.Type)
}

type Shorthand struct {
	Priority  int
	Expansion string
	Match     *string
	Text      *string
}

func (s Shorthand) String() string {
	var match, text string

	if s.Match != nil {
		match = *s.Match
	}

	if s.Text != nil {
		text = *s.Text
	}

	return fmt.Sprintf("<#shorthand priority: %d expansion: `%s` match: `%s` text: `%s`>",
		s.Priority, s.Expansion, match, text)
}
