package runtime

import (
	"errors"
	"fmt"

	"github.com/minond/captainslog/vm/lang"
	"github.com/minond/captainslog/vm/lang/parser"
)

func Eval(code string, env *Environment) ([]lang.Value, *Environment, error) {
	exprs, err := parser.Parse(code)
	if err != nil {
		return nil, env, err
	}

	return evalAll(exprs, env)
}

func eval(expr lang.Expr, env *Environment) (lang.Value, *Environment, error) {
	switch e := expr.(type) {
	case *lang.String:
		return e, env, nil
	case *lang.Boolean:
		return e, env, nil
	case *lang.Number:
		return e, env, nil
	case *lang.Identifier:
		val, err := env.Get(e.Label())
		return val, env, err
	case *lang.Sexpr:
		return app(e, env)
	case *lang.Quote:
		val, err := unquote(e)
		return val, env, err
	}

	return nil, env, errors.New("unable to handle expression")
}

func evalAll(exprs []lang.Expr, env *Environment) ([]lang.Value, *Environment, error) {
	vals := make([]lang.Value, len(exprs))
	for i, expr := range exprs {
		val, newEnv, err := eval(expr, env)
		env = newEnv
		if err != nil {
			return nil, env, err
		}

		vals[i] = val
	}

	return vals, env, nil
}

func app(expr *lang.Sexpr, env *Environment) (lang.Value, *Environment, error) {
	if expr.Size() == 0 {
		return nil, env, errors.New("missing procedure expression")
	}

	val, newEnv, err := eval(expr.Head(), env)
	env = newEnv
	if err != nil {
		return nil, env, err
	}

	fn, ok := val.(Applicable)
	if !ok {
		return nil, env, fmt.Errorf("not a procedure: %v", val)
	}

	return fn.Apply(expr.Tail(), env)
}

func unquote(expr *lang.Quote) (lang.Value, error) {
	switch e := expr.Unquote().(type) {
	case *lang.String:
		return e, nil
	case *lang.Boolean:
		return e, nil
	case *lang.Number:
		return e, nil
	case *lang.Identifier:
		return expr, nil
	case *lang.Quote:
		return expr, nil
	case *lang.Sexpr:
		return lang.NewList(e.Map(lang.NewQuotedExpr)), nil
	}
	return nil, errors.New("invalid quoted expression")
}
