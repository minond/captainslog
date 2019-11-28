package runtime

import (
	"errors"
	"fmt"

	"github.com/minond/captainslog/vm/lang"
)

var builtins = map[string]lang.Value{
	"cond": builtinCond,
	"set!": builtinSetBang,
}

var procedures = map[string]procedureFn{
	"+": binaryFloat64Op(func(a, b float64) float64 { return a + b }),
	"-": binaryFloat64Op(func(a, b float64) float64 { return a - b }),
	"*": binaryFloat64Op(func(a, b float64) float64 { return a * b }),
	"/": binaryFloat64Op(func(a, b float64) float64 { return a / b }),

	"not":    unaryBoolOp(func(a bool) bool { return !a }),
	"true?":  unaryBoolOp(func(a bool) bool { return a == true }),
	"false?": unaryBoolOp(func(a bool) bool { return a == false }),
}

func init() {
	for name, proc := range procedures {
		builtins[name] = NewProcedure(name, proc)
	}
}

var builtinSetBang = NewBuiltin(func(exprs []lang.Expr, env *Environment) (lang.Value, *Environment, error) {
	if len(exprs) != 2 {
		return nil, env, errors.New("contract error: expected two arguments")
	}

	label, ok := exprs[0].(*lang.Identifier)
	if !ok {
		return nil, env, errors.New("contract error: expected an identifier as the first parameter")
	}

	val, newEnv, err := eval(exprs[1], env)
	env = newEnv
	if err != nil {
		return nil, env, err
	}

	env.TopMostParent().Set(label.Label(), val)
	return nil, env, nil
})

// builtinCond expects exprs to be a list of sexprs with at least one item. The
// first item is evaluated. If it is not #f then evaluate the tail and return
// the last item. Otherwise move on to the next item. If no cond is true then
// return an error. An `else` clause is only allowed as the last item in the
// list and it always evaluates to true.
var builtinCond = NewBuiltin(func(exprs []lang.Expr, env *Environment) (lang.Value, *Environment, error) {
	isElse := func(expr lang.Expr) bool {
		id, ok := expr.(*lang.Identifier)
		return ok && id.Label() == "else"
	}

	conds := make([]*lang.Sexpr, len(exprs))
	for i, expr := range exprs {
		switch sexpr := expr.(type) {
		case *lang.Sexpr:
			if sexpr.Size() == 0 {
				return nil, env, errors.New("cond: clause is not a pair")
			} else if isElse(sexpr.Head()) && i != len(exprs)-1 {
				return nil, env, errors.New("cond: `else` clause must be at the end")
			}

			conds[i] = sexpr
		default:
			return nil, env, errors.New("cond: invalid syntax")
		}
	}

	for _, cond := range conds {
		if isElse(cond.Head()) {
			// Else must have subsequent expression to evaluate
			if len(cond.Tail()) == 0 {
				return nil, env, errors.New("cond: missing expresison in `else` clause")
			}
		} else {
			// We're in an "else" clause, move on to tail evaluation
			val, newEnv, err := eval(cond.Head(), env)
			env = newEnv
			if err != nil {
				return nil, env, err
			}

			switch b := val.(type) {
			case *lang.Boolean:
				if b.False() {
					continue
				}
			}

			// Single item list, return the head
			if len(cond.Tail()) == 0 {
				return val, env, nil
			}
		}

		vals, env, err := evalAll(cond.Tail(), env)
		if err != nil {
			return nil, env, err
		}

		return vals[len(vals)-1], env, nil
	}

	return nil, env, errors.New("cond: no return value")
})

func binaryFloat64Op(op func(float64, float64) float64) func([]lang.Value) (lang.Value, error) {
	return func(args []lang.Value) (lang.Value, error) {
		var total float64
		for i, n := range args {
			num, ok := n.(*lang.Number)
			if !ok {
				return nil, fmt.Errorf("contract error: expected a number in position %v", i)
			}

			if i == 0 {
				total = num.Float64()
			} else {
				total = op(total, num.Float64())
			}
		}

		return lang.NewNumber(total), nil
	}
}

func unaryBoolOp(op func(bool) bool) func([]lang.Value) (lang.Value, error) {
	return func(args []lang.Value) (lang.Value, error) {
		if len(args) == 0 {
			return nil, errors.New("contract error: expected an argument")
		}

		arg, ok := args[0].(*lang.Boolean)
		if !ok {
			return nil, errors.New("contract error: expected a boolean")
		}

		return lang.NewBoolean(op(arg.Bool())), nil
	}
}
