package main

// DataType represents the data type of extracted data.
type DataType int32

const (
	StringData DataType = iota
	NumberData
	BooleanData
)

type Extractor struct {
	Label    string
	Match    string
	DataType DataType
}

type Shorthand struct {
	Priority  int
	Expansion string
	Match     *string
	Text      *string
}
