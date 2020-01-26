package testing

import (
	"reflect"
	"testing"
)

func AssertEqual(t *testing.T, expected, returned interface{}) {
	t.Helper()
	if !reflect.DeepEqual(expected, returned) {
		t.Errorf(`error: not equal:
		expected: %v
		returned: %v`, expected, returned)
	}
}
