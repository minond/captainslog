package log

import (
	"testing"
)

func TestExtractor_Process(t *testing.T) {
	ex, _ := NewExtractor("testing", `(aaa)`)
	ret, err := ex.Process("aaa")
	if err != nil {
		t.Errorf("unexpected error: %v", err)
	}
	if ret["testing"] == "" {
		t.Error("expected match")
	}
}
