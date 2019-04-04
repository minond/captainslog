package processing

import (
	"testing"

	"github.com/minond/captainslog/model"
)

type expandTest struct {
	expected string
	input    string
}

func stringptr(str string) *string {
	return &str
}

func runExpandTests(label string, t *testing.T, tests []expandTest, shorthands []*model.Shorthand) {
	for _, test := range tests {
		output, err := Expand(test.input, shorthands)
		if err != nil {
			t.Errorf("%s: unexpected error: %v", label, err)
		}

		if output != test.expected {
			t.Errorf("%s: expected `%s` to be expanded to `%s` but got `%s` instead",
				label, test.input, test.expected, output)
		}
	}
}

func TestExpand_WorkoutSample(t *testing.T) {
	tests := []expandTest{
		{"Bench press, 3x10@65", "Bench press, 3x10@65"},
		{"Bench press, 3x10@65", "Bench press. xxx@65"},
		{"Bench press, 3x10@65", "Bench press, xxx@65"},
		{"Bench press, 3x10@65", "Bench press xxx@65"},
		{"Bench press, 3x10@65", "Bench press        xxx@65"},
		{"Bench press, 3x10@65", "Bench press. Xxx@65"},
	}

	shorthands := []*model.Shorthand{
		&model.Shorthand{Expansion: " ", Match: stringptr(`\s{1,}`)},
		&model.Shorthand{Expansion: ", 3x10", Match: stringptr(`[^,|\.]\s{1,}xxx`), Text: stringptr(" xxx")},
		&model.Shorthand{Expansion: ", 3x10", Text: stringptr(". Xxx")},
		&model.Shorthand{Expansion: ", 3x10", Match: stringptr(`\. xxx`)},
		&model.Shorthand{Expansion: "3x10", Match: stringptr("xxx")},
	}

	runExpandTests("TestExpand_WorkoutSample", t, tests, shorthands)
}
