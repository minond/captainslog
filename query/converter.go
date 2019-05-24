package query

import (
	"fmt"
)

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

func Convert(ast Ast, userGUID string) (Ast, error) {
	env := make(environment)
	switch stmt := ast.(type) {
	case *selectStmt:
		rewritten, err := rewriteAst(stmt, env)
		if err != nil {
			return nil, err
		}
		return withBookFilter(withUserFilter(rewritten.(*selectStmt), userGUID)), nil
	}
	return nil, fmt.Errorf("invalid query type: %v", ast.queryType())
}

func and(stmt *selectStmt, expr expr) *selectStmt {
	if stmt.where == nil {
		stmt.where = expr
	} else {
		stmt.where = binaryExpr{
			left:  expr,
			op:    opAnd,
			right: grouping{sub: stmt.where},
		}
	}
	return stmt
}

func withUserFilter(stmt *selectStmt, userGUID string) *selectStmt {
	return and(stmt, binaryExpr{
		left: identifier{name: "user_guid"},
		op:   opEq,
		right: value{
			ty:  tyString,
			tok: token{lexeme: userGUID},
		},
	})
}

func withBookFilter(stmt *selectStmt) *selectStmt {
	from := &table{name: "entries"}
	if stmt.from != nil {
		tableMatcher := binaryExpr{
			left: identifier{name: "book_guid"},
			op:   opEq,
			right: subquery{
				stmt: &selectStmt{
					columns: []expr{identifier{name: "guid"}},
					from:    &table{name: "books"},
					where: binaryExpr{
						left: identifier{name: "name"},
						op:   opIlike,
						right: value{
							ty:  tyString,
							tok: token{lexeme: stmt.from.name},
						},
					},
				},
			},
		}

		stmt = and(stmt, tableMatcher)
	}
	stmt.from = from
	return stmt
}

func rewriteAst(ast Ast, env environment) (Ast, error) {
	switch stmt := ast.(type) {
	case *selectStmt:
		for i, expr := range stmt.columns {
			newexpr, newenv := rewriteExpr(expr, env, true)
			env = newenv
			stmt.columns[i] = newexpr
		}
		for i, expr := range stmt.groupBy {
			newexpr, _ := rewriteExpr(expr, env, false)
			stmt.groupBy[i] = newexpr
		}

		// Column aliases are not available in where clause, so we use a new
		// environment when rewriting the where clause expression.
		newexpr, _ := rewriteExpr(stmt.where, make(environment), false)
		stmt.where = newexpr
		return ast, nil
	}
	return nil, fmt.Errorf("invalid query type: %v", ast.queryType())
}

func rewriteExpr(ex expr, env environment, autoAlias bool) (expr, environment) {
	switch x := ex.(type) {
	case identifier:
		var field expr
		field = jsonfield{col: "data", prop: x.name}
		if autoAlias {
			field = aliased{as: x.name, expr: field}
		}
		return field, env
	case application:
		for i, ex := range x.args {
			newexpr, newenv := rewriteExpr(ex, env, false)
			env = newenv
			x.args[i] = newexpr
		}
		if autoAlias {
			return aliased{as: x.fn, expr: x}, env
		}
		return x, env
	case grouping:
		newexpr, newenv := rewriteExpr(x.sub, env, false)
		x.sub = newexpr
		return x, newenv
	case binaryExpr:
		newleft, newenv := rewriteExpr(x.left, env, false)
		newright, lastenv := rewriteExpr(x.right, newenv, false)
		x.left = newleft
		x.right = newright
		return x, lastenv
	case unaryExpr:
		newexpr, newenv := rewriteExpr(x.right, env, false)
		x.right = newexpr
		return x, newenv
	case isNull:
		newexpr, newenv := rewriteExpr(x.expr, env, false)
		x.expr = newexpr
		return x, newenv
	case aliased:
		newexpr, _ := rewriteExpr(x.expr, env, false)
		x.expr = newexpr
		env = env.define(x.as)
		return x, env
	case value:
		return x, env
	case jsonfield:
		return x, env
	case subquery:
		return x, env
	}
	return ex, env
}
