package query

import (
	"fmt"
)

func Convert(ast Ast) (Ast, error) {
	return rewrite(ast)
}

type environment map[string]struct{}

func (env environment) defined(alias string) bool {
	for v := range env {
		if v == alias {
			return true
		}
	}
	return false
}

func (env environment) define(alias string) environment {
	env[alias] = struct{}{}
	return env
}

func rewrite(ast Ast) (Ast, error) {
	switch stmt := ast.(type) {
	case *selectStmt:
		env := make(environment)
		for i, expr := range stmt.columns {
			newexpr, newenv := rewriteExpr(expr, env)
			env = newenv
			stmt.columns[i] = newexpr
		}
		for i, expr := range stmt.groupBy {
			newexpr, _ := rewriteExpr(expr, env)
			stmt.groupBy[i] = newexpr
		}
		newexpr, _ := rewriteExpr(stmt.where, env)
		stmt.where = newexpr
		return ast, nil
	}
	return nil, fmt.Errorf("invalid query type: %v", ast.queryType())
}

func rewriteExpr(expr expr, env environment) (expr, environment) {
	switch x := expr.(type) {
	case identifier:
		if !env.defined(x.name) {
			return jsonfield{col: "data", prop: x.name}, env
		}
		return x, env
	case application:
		for i, expr := range x.args {
			newexpr, newenv := rewriteExpr(expr, env)
			env = newenv
			x.args[i] = newexpr
		}
		return x, env
	case grouping:
		newexpr, newenv := rewriteExpr(x.sub, env)
		x.sub = newexpr
		return x, newenv
	case binaryExpr:
		newleft, newenv := rewriteExpr(x.left, env)
		newright, lastenv := rewriteExpr(x.right, newenv)
		x.left = newleft
		x.right = newright
		return x, lastenv
	case unaryExpr:
		newexpr, newenv := rewriteExpr(x.right, env)
		x.right = newexpr
		return x, newenv
	case isNull:
		newexpr, newenv := rewriteExpr(x.expr, env)
		x.expr = newexpr
		return x, newenv
	case aliased:
		newexpr, _ := rewriteExpr(x.expr, env)
		x.expr = newexpr
		env = env.define(x.as)
		return x, env
	}
	return expr, env
}
