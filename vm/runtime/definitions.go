package runtime

import (
	"fmt"

	"github.com/minond/captainslog/vm/lang"
)

type Builtin struct {
	lang.Value
	fn builtinFn
}

type builtinFn func(args []lang.Expr, env *Environment) (lang.Value, *Environment, error)

func NewBuiltin(fn builtinFn) *Builtin {
	return &Builtin{fn: fn}
}

func (v Builtin) String() string {
	return "#<builtin>"
}

func (v Builtin) Apply(args []lang.Expr, env *Environment) (lang.Value, *Environment, error) {
	return v.fn(args, env)
}

type Procedure struct {
	lang.Value
	name string
	fn   procedureFn
}

type procedureFn func(args []lang.Value) (lang.Value, error)

func NewProcedure(name string, fn procedureFn) *Procedure {
	return &Procedure{fn: fn, name: name}
}

func (v Procedure) String() string {
	return fmt.Sprintf("#<procedure:%s>", v.name)
}

func (v Procedure) Apply(args []lang.Value) (lang.Value, error) {
	return v.fn(args)
}
