package log

import (
	"testing"
)

type dataTest struct {
	text string
	data map[string]string
}

func runDataTests(label string, t *testing.T, tests []dataTest, xs []Extractor) {
	for _, test := range tests {
		e, err := NewEntry(test.text).Process(xs)
		if err != nil {
			t.Errorf("%s: unexpected error: %v", label, err)
		}

		for label, expectedVal := range test.data {
			if e.Data[label] != expectedVal {
				t.Errorf("%s: expected `%s` to have `%s` equal `%s` but got `%s`",
					label, test.text, label, expectedVal, e.Data[label])
			}
		}
	}
}

func TestEntry_Process_WorkoutsSample(t *testing.T) {
	tests := []dataTest{
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

	xs := []Extractor{
		Extractor{Label: "exercise", Match: `^(.+),`},
		Extractor{Label: "sets", Match: `,\s{0,}(\d+)\s{0,}x`},
		Extractor{Label: "reps", Match: `x\s{0,}(\d+)\s{0,}@`},
		Extractor{Label: "weight", Match: `@\s{0,}(\d+)$`},
		Extractor{Label: "time", Match: `(\d+\s{0,}(sec|seconds|min|minutes|hour|hours))`},
	}

	runDataTests("TestProcess_WorkoutsSample", t, tests, xs)
}
