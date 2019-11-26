package runtime

import (
	"fmt"

	"github.com/minond/captainslog/vm/lang"
)

var builtinSum = lang.NewBuiltin(func(args ...lang.Value) (lang.Value, error) {
	sum := float64(0)
	for i, arg := range args {
		num, ok := arg.(*lang.Number)
		if !ok {
			return nil, fmt.Errorf("contract error: expected a number in position %v", i)
		}
		sum += num.Value()
	}

	return lang.NewNumber(sum), nil
})

var builtins = map[string]lang.Value{
	"+": builtinSum,
}
