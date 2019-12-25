package main

import "testing"

type extractTest struct {
	text string
	data map[string]interface{}
}

func runExtractTests(label string, t *testing.T, tests []extractTest, extractors []Extractor) {
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
		{"Bench press, 3x10@65", map[string]interface{}{
			"exercise": "Bench press",
			"sets":     float32(3),
			"reps":     float32(10),
			"weight":   float32(65),
		}},
		{"Squats, 2min", map[string]interface{}{
			"exercise": "Squats",
			"time":     "2min",
		}},
		{"Squats, 3x10@45", map[string]interface{}{
			"exercise": "Squats",
			"sets":     float32(3),
			"reps":     float32(10),
			"weight":   float32(45),
		}},
		{"Running, 30min", map[string]interface{}{
			"exercise": "Running",
			"time":     "30min",
		}},
	}

	extractors := []Extractor{
		{Label: "exercise", Match: `^(.+),`, Type: StringData},
		{Label: "sets", Match: `,\s{0,}(\d+)\s{0,}x`, Type: NumberData},
		{Label: "reps", Match: `x\s{0,}(\d+)\s{0,}@`, Type: NumberData},
		{Label: "weight", Match: `@\s{0,}(\d+)$`, Type: NumberData},
		{Label: "time", Match: `(\d+\s{0,}(sec|seconds|min|minutes|hour|hours))`, Type: StringData},
	}

	runExtractTests("TestExtract_WorkoutsSample", t, tests, extractors)
}
