package processing

import (
	"reflect"
	"testing"

	"github.com/minond/captainslog/model"
)

func TestProcess(t *testing.T) {
	expectedText := "Bench press, 3x10 @ 65"
	expectedData := map[string]interface{}{
		"exercise": "Bench press",
		"sets":     float32(3),
		"reps":     float32(10),
		"weight":   float32(65),
	}

	shorthands := []*model.Shorthand{
		{Expansion: "xx @ ", Text: str("xx "), Match: str(`xx \d`), Priority: 1},
		{Expansion: "3x10", Match: str("xxx"), Priority: 2},
	}

	extractors := []*model.Extractor{
		{Label: "exercise", Match: `^(.+),`, Type: model.StringData},
		{Label: "sets", Match: `,\s{0,}(\d+)\s{0,}x`, Type: model.NumberData},
		{Label: "reps", Match: `x\s{0,}(\d+)\s{0,}@`, Type: model.NumberData},
		{Label: "weight", Match: `@\s{0,}(\d+)$`, Type: model.NumberData},
	}

	text, data, err := Process("Bench press, xxx 65", shorthands, extractors)
	if err != nil {
		t.Errorf("unexpected error: %v", err)
	} else if text != expectedText {
		t.Errorf("unexpected text: got `%s` but expected `%s`", text, expectedText)
	} else if !reflect.DeepEqual(data, expectedData) {
		t.Errorf("unexpected data: got `%s` but expected `%s`", data, expectedData)
	}
}
