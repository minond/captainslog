package runtime

import (
	"errors"
	"fmt"

	"github.com/minond/captainslog/vm/lang"
)

var builtins = map[string]lang.Value{
	"cond": builtinCond,
}

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

// builtinCond expects exprs to be a list of sexprs with at least one item. The
// first item is evaluated. If it is not #f then evaluate the tail and return
// the last item. Otherwise move on to the next item. If no cond is true then
// return an error. An `else` clause is only allowed as the last item in the
// list and it always evaluates to true.
var builtinCond = NewBuiltin(func(exprs []lang.Expr, env *Environment) (lang.Value, error) {
	conds := make([]*lang.Sexpr, len(exprs))
	for i, expr := range exprs {
		switch sexpr := expr.(type) {
		case *lang.Sexpr:
			conds[i] = sexpr
		default:
			return nil, errors.New("cond: invalid syntax")
		}
	}
	for _, cond := range conds {
		// TODO implement else
		val, err := eval(cond.Head(), env)
		if err != nil {
			return nil, err
		}
		switch b := val.(type) {
		case *lang.Boolean:
			if b.Value() == false {
				continue
			}
			if len(cond.Tail()) == 0 {
				return val, nil
			}
			vals, err := evalAll(cond.Tail(), env)
			if err != nil {
				return nil, err
			}
			return vals[len(vals)-1], nil
		}
	}
	return nil, errors.New("cond: no return value")
})

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
