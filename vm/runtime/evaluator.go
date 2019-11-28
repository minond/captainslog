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

func (env *Environment) TopMostParent() *Environment {
	if env.parent == nil {
		return env
	}
	return env.parent
}

func (env *Environment) Set(id string, val lang.Value) {
	env.bindings[id] = val
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

func Eval(code string, env *Environment) ([]lang.Value, *Environment, error) {
	exprs, err := parser.Parse(code)
	if err != nil {
		return nil, env, err
	}

	var values []lang.Value
	for _, expr := range exprs {
		val, newEnv, err := eval(expr, env)
		env = newEnv
		if err != nil {
			return nil, env, err
		}
		values = append(values, val)
	}

	return values, env, nil
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
		if e.Size() == 0 {
			return nil, env, errors.New("missing procedure expression")
		}

		val, newEnv, err := eval(e.Head(), env)
		env = newEnv
		if err != nil {
			return nil, env, err
		}

		switch fn := val.(type) {
		case *Builtin:
			return fn.Apply(e.Tail(), env)
		case *Procedure:
			params, newEnv, err := evalAll(e.Tail(), env)
			env = newEnv
			if err != nil {
				return nil, env, err
			}

			val, err := fn.Apply(params)
			return val, env, err
		default:
			return nil, env, fmt.Errorf("not a procedure: %v", val)
		}
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
