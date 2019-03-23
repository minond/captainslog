package log

import (
	"testing"
)

func TestExtractor_Process(t *testing.T) {
	ex := Extractor{Label: "testing", Match: `(aaa)`}
	ret, err := ex.Process("aaa")
	if err != nil {
		t.Errorf("unexpected error: %v", err)
	}
	if ret["testing"] == "" {
		t.Error("expected match")
	}
}
