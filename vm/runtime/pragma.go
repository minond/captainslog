package runtime

import (
	"fmt"

	"github.com/minond/captainslog/vm/lang"
)

var procedureSum = func(args []lang.Value) (lang.Value, error) {
	var total float64
	for i, n := range args {
		num, ok := n.(*lang.Number)
		if !ok {
			return nil, fmt.Errorf("contract error: expected a number in position %v", i)
		}
		if i == 0 {
			total = num.Value()
		} else {
			total += num.Value()
		}
	}
	return lang.NewNumber(total), nil
}

var procedureSub = func(args []lang.Value) (lang.Value, error) {
	var total float64
	for i, n := range args {
		num, ok := n.(*lang.Number)
		if !ok {
			return nil, fmt.Errorf("contract error: expected a number in position %v", i)
		}
		if i == 0 {
			total = num.Value()
		} else {
			total -= num.Value()
		}
	}
	return lang.NewNumber(total), nil
}

var procedureMul = func(args []lang.Value) (lang.Value, error) {
	var total float64
	for i, n := range args {
		num, ok := n.(*lang.Number)
		if !ok {
			return nil, fmt.Errorf("contract error: expected a number in position %v", i)
		}
		if i == 0 {
			total = num.Value()
		} else {
			total += num.Value()
		}
	}
	return lang.NewNumber(total), nil
}

var procedureDiv = func(args []lang.Value) (lang.Value, error) {
	var total float64
	for i, n := range args {
		num, ok := n.(*lang.Number)
		if !ok {
			return nil, fmt.Errorf("contract error: expected a number in position %v", i)
		}
		if i == 0 {
			total = num.Value()
		} else {
			total /= num.Value()
		}
	}
	return lang.NewNumber(total), nil
}

var builtins = map[string]lang.Value{}
var procedures = map[string]procedureFn{
	"+": procedureSum,
	"-": procedureSub,
	"*": procedureMul,
	"/": procedureDiv,
}

func init() {
	for name, proc := range procedures {
		builtins[name] = NewProcedure(name, proc)
	}
}
