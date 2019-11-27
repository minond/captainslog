package lang

import (
	"fmt"
)

type Value interface {
	fmt.Stringer
	isValue()
}
