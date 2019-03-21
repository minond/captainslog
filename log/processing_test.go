package log

import (
	"testing"
)

func must(x Extractor, err error) Extractor {
	if err != nil {
		panic(err)
	}
	return x
}

type dataTest struct {
	text string
	data map[string]string
}

func runDataTests(label string, t *testing.T, tests []dataTest, xs []Extractor) {
	for _, test := range tests {
		l, err := Process(NewLog(test.text), xs)
		if err != nil {
			t.Errorf("%s: unexpected error: %v", label, err)
		}

		for label, expectedVal := range test.data {
			if l.Data[label] != expectedVal {
				t.Errorf("%s: expected `%s` to have `%s` equal `%s` but got `%s`",
					label, test.text, label, expectedVal, l.Data[label])
			}
		}
	}
}

func TestProcess_WorkoutsSample(t *testing.T) {
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
		must(NewExtractor("exercise", `^(.+),`)),
		must(NewExtractor("sets", `,\s{0,}(\d+)\s{0,}x`)),
		must(NewExtractor("reps", `x\s{0,}(\d+)\s{0,}@`)),
		must(NewExtractor("weight", `@\s{0,}(\d+)$`)),
		must(NewExtractor("time", `(\d+\s{0,}(sec|seconds|min|minutes|hour|hours))`)),
	}

	runDataTests("TestProcess_WorkoutsSample", t, tests, xs)
}
