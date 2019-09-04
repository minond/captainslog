package model

import "gopkg.in/src-d/go-kallax.v1"

type Report struct {
	kallax.Model `table:"reports" pk:"guid"`

	GUID      kallax.ULID `json:"guid"`
	Label     string      `json:"label"`
	Variables []Variable  `json:"variables"`
	Outputs   []Output    `json:"outputs"`

	User *User `fk:"user_guid,inverse"`
}

type Variable struct {
	ID           string `json:"id"`
	Label        string `json:"label"`
	Query        string `json:"query"`
	DefaultValue string `json:"defaultValue"`
}

type OutputType int32

const (
	InvalidOutput OutputType = iota
	TableOutput
	ChartOutput
	ValueOutput
)

type Output struct {
	ID    string     `json:"id"`
	Label string     `json:"label"`
	Type  OutputType `json:"type"`
	Query string     `json:"query"`
}

func newReport(label string, variables []Variable, outputs []Output, user *User) (*Report, error) {
	report := &Report{
		GUID:      kallax.NewULID(),
		Label:     label,
		Variables: variables,
		Outputs:   outputs,
		User:      user,
	}

	return report, nil
}
