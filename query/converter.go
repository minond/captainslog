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
		op:   opIlike,
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
			newexpr, newenv := rewriteExpr(expr, env)
			env = newenv
			stmt.columns[i] = newexpr
		}
		for i, expr := range stmt.groupBy {
			newexpr, _ := rewriteExpr(expr, env)
			stmt.groupBy[i] = newexpr
		}

		// Column aliases are not available in where clause, so we use a new
		// environment when rewriting the where clause expression.
		newexpr, _ := rewriteExpr(stmt.where, make(environment))
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
	case value:
		return x, env
	case jsonfield:
		return x, env
	case subquery:
		return x, env
	}
	return expr, env
}
