package main

import (
	"fmt"

	"github.com/minond/captainslog/querier/query"
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

func Convert(ast query.Ast, userGUID string) (query.Ast, error) {
	env := make(environment)
	switch stmt := ast.(type) {
	case *query.SelectStmt:
		rewritten, err := rewriteAst(stmt, env)
		if err != nil {
			return nil, err
		}
		return withBookFilter(withUserFilter(rewritten.(*query.SelectStmt), userGUID), userGUID), nil
	}
	return nil, fmt.Errorf("invalid query type: %v", ast.QueryType())
}

func and(stmt *query.SelectStmt, expr query.Expr) *query.SelectStmt {
	if stmt.Where == nil {
		stmt.Where = expr
	} else {
		stmt.Where = query.BinaryExpr{
			Left:  expr,
			Op:    query.OpAnd,
			Right: query.Grouping{Sub: stmt.Where},
		}
	}
	return stmt
}

func withUserFilter(stmt *query.SelectStmt, userGUID string) *query.SelectStmt {
	return and(stmt, query.BinaryExpr{
		Left: query.Identifier{Name: "user_guid"},
		Op:   query.OpEq,
		Right: query.Value{
			Ty:  query.TyString,
			Tok: query.Token{Lexeme: userGUID},
		},
	})
}

func withBookFilter(stmt *query.SelectStmt, userGUID string) *query.SelectStmt {
	from := &query.Table{Name: "entries"}
	if stmt.From != nil {
		tableMatcher := query.BinaryExpr{
			Left: query.Identifier{Name: "book_guid"},
			Op:   query.OpEq,
			Right: query.Subquery{
				Stmt: &query.SelectStmt{
					Columns: []query.Expr{query.Identifier{Name: "guid"}},
					From:    &query.Table{Name: "books"},
					Where: query.BinaryExpr{
						Left: query.BinaryExpr{
							Left: query.Identifier{Name: "name"},
							Op:   query.OpIlike,
							Right: query.Value{
								Ty:  query.TyString,
								Tok: query.Token{Lexeme: stmt.From.Name},
							},
						},
						Op: query.OpAnd,
						Right: query.BinaryExpr{
							Left: query.Identifier{Name: "user_guid"},
							Op:   query.OpEq,
							Right: query.Value{
								Ty:  query.TyString,
								Tok: query.Token{Lexeme: userGUID},
							},
						},
					},
				},
			},
		}

		stmt = and(stmt, tableMatcher)
	}
	stmt.From = from
	return stmt
}

func rewriteAst(ast query.Ast, env environment) (query.Ast, error) {
	switch stmt := ast.(type) {
	case *query.SelectStmt:
		var newexpr query.Expr
		var newenv environment

		for i, expr := range stmt.Columns {
			newexpr, newenv = rewriteExpr(expr, env, true)
			env = newenv
			stmt.Columns[i] = newexpr
		}
		for i, expr := range stmt.GroupBy {
			newexpr, _ = rewriteExpr(expr, env, false)
			stmt.GroupBy[i] = newexpr
		}
		for i, expr := range stmt.OrderBy {
			newexpr, _ = rewriteExpr(expr.Expr, env, false)
			stmt.OrderBy[i].Expr = newexpr
		}

		newexpr, _ = rewriteExpr(stmt.Having, env, false)
		stmt.Having = newexpr

		// Column aliases are not available in where clause, so we use a new
		// environment when rewriting the where clause expression.
		newexpr, _ = rewriteExpr(stmt.Where, make(environment), false)
		stmt.Where = newexpr
		return ast, nil
	}
	return nil, fmt.Errorf("invalid query type: %v", ast.QueryType())
}

func rewriteExpr(ex query.Expr, env environment, autoAlias bool) (query.Expr, environment) {
	switch x := ex.(type) {
	case query.Identifier:
		// Note that alises are no possible to use in where clauses. In order
		// to respect this, an empty environment is passed in when rewriting
		// the where clause.
		if env.defined(x.Name) {
			return ex, env
		}
		var field query.Expr
		field = query.JSONField{Col: "data", Prop: x.Name}
		if autoAlias {
			field = query.Aliased{As: x.Name, Expr: field}
		}
		return field, env
	case query.Application:
		for i, ex := range x.Args {
			newexpr, newenv := rewriteExpr(ex, env, false)
			env = newenv
			x.Args[i] = newexpr
		}
		if autoAlias {
			return query.Aliased{As: x.Fn, Expr: x}, env
		}
		return x, env
	case query.Grouping:
		newexpr, newenv := rewriteExpr(x.Sub, env, false)
		x.Sub = newexpr
		return x, newenv
	case query.BinaryExpr:
		newleft, newenv := rewriteExpr(x.Left, env, false)
		newright, lastenv := rewriteExpr(x.Right, newenv, false)
		x.Left = newleft
		x.Right = newright
		return x, lastenv
	case query.UnaryExpr:
		newexpr, newenv := rewriteExpr(x.Right, env, false)
		x.Right = newexpr
		return x, newenv
	case query.IsNull:
		newexpr, newenv := rewriteExpr(x.Expr, env, false)
		x.Expr = newexpr
		return x, newenv
	case query.Aliased:
		newexpr, _ := rewriteExpr(x.Expr, env, false)
		x.Expr = newexpr
		env = env.define(x.As)
		return x, env
	case query.Value:
		return x, env
	case query.JSONField:
		return x, env
	case query.Subquery:
		return x, env
	}
	return ex, env
}
