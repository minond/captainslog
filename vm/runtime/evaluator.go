package runtime

import (
	"errors"
	"fmt"

	"github.com/minond/captainslog/vm/lang"
	"github.com/minond/captainslog/vm/lang/parser"
)

type Environment struct {
	parent   *Environment
	bindings map[string]lang.Value
}

func NewEnvironment() *Environment {
	return &Environment{
		bindings: make(map[string]lang.Value),
		parent: &Environment{
			bindings: builtins,
		},
	}
}

func (env Environment) Get(id string) (lang.Value, error) {
	val, ok := env.bindings[id]
	if !ok && env.parent != nil {
		return env.parent.Get(id)
	} else if !ok {
		return nil, fmt.Errorf("undefined: %v", id)
	}
	return val, nil
}

func Eval(code string, env *Environment) ([]lang.Value, error) {
	exprs, err := parser.Parse(code)
	if err != nil {
		return nil, err
	}

	var values []lang.Value
	for _, expr := range exprs {
		val, err := eval(expr, env)
		if err != nil {
			return nil, err
		}
		values = append(values, val)
	}

	return values, nil
}

func eval(expr lang.Expr, env *Environment) (lang.Value, error) {
	switch e := expr.(type) {
	case *lang.String:
		return e, nil
	case *lang.Boolean:
		return e, nil
	case *lang.Number:
		return e, nil
	case *lang.Identifier:
		return env.Get(e.Value())
	case *lang.Sexpr:
		val, err := eval(e.Head(), env)
		if err != nil {
			return nil, err
		}

		proc, ok := val.(lang.Applicable)
		if !ok {
			return nil, fmt.Errorf("not a procedure: %v", val)
		}

		params := make([]lang.Value, len(e.Tail()))
		for i, item := range e.Tail() {
			val, err := eval(item, env)
			if err != nil {
				return nil, err
			}
			params[i] = val
		}

		return proc.Apply(params)
	}

	return nil, errors.New("unable to handle expression")
}
