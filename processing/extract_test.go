package processing

import (
	"testing"

	"github.com/minond/captainslog/model"
)

type extractTest struct {
	text string
	data map[string]string
}

func runExtractTests(label string, t *testing.T, tests []extractTest, extractors []*model.Extractor) {
	for _, test := range tests {
		data, err := Extract(test.text, extractors)
		if err != nil {
			t.Errorf("%s: unexpected error: %v", label, err)
		}

		for label, expectedVal := range test.data {
			if data[label] != expectedVal {
				t.Errorf("%s: expected `%s` to have `%s` equal `%s` but got `%s`",
					label, test.text, label, expectedVal, data[label])
			}
		}
	}
}

func TestExtract_WorkoutsSample(t *testing.T) {
	tests := []extractTest{
		{"Bench press, 3x10@65", map[string]string{
			"exercise": "Bench press",
			"sets":     "3",
			"reps":     "10",
			"weight":   "65",
		}},
		{"Squats, 2min", map[string]string{
			"exercise": "Squats",
			"time":     "2min",
		}},
		{"Squats, 3x10@45", map[string]string{
			"exercise": "Squats",
			"sets":     "3",
			"reps":     "10",
			"weight":   "45",
		}},
		{"Running, 30min", map[string]string{
			"exercise": "Running",
			"time":     "30min",
		}},
	}

	extractors := []*model.Extractor{
		&model.Extractor{Label: "exercise", Match: `^(.+),`},
		&model.Extractor{Label: "sets", Match: `,\s{0,}(\d+)\s{0,}x`},
		&model.Extractor{Label: "reps", Match: `x\s{0,}(\d+)\s{0,}@`},
		&model.Extractor{Label: "weight", Match: `@\s{0,}(\d+)$`},
		&model.Extractor{Label: "time", Match: `(\d+\s{0,}(sec|seconds|min|minutes|hour|hours))`},
	}

	runExtractTests("TestProcess_WorkoutsSample", t, tests, extractors)
}
