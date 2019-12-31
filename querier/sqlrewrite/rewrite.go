package sqlrewrite

import (
	"fmt"
	"strconv"

	"github.com/minond/captainslog/querier/sqlparse"
)

// Rewrite takes an AST and rewrites it so that it is able to be executed in
// the application database (converts columns to JSON selectors, rewrites book
// in from clause to use correct filter, etc.) and add filters to the query for
// the appropriate user and book.
func Rewrite(ast sqlparse.Ast, userID int64) (sqlparse.Ast, error) {
	env := make(environment)
	switch stmt := ast.(type) {
	case *sqlparse.SelectStmt:
		rewritten, err := rewriteSelectStmt(stmt, env)
		if err != nil {
			return nil, err
		}

		withUser := addUserFilter(rewritten, userID)
		withBook := addBookFilter(withUser, userID)
		return withBook, nil
	}
	return nil, fmt.Errorf("invalid query type: %v", ast.QueryType())
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

func and(stmt *sqlparse.SelectStmt, expr sqlparse.Expr) *sqlparse.SelectStmt {
	if stmt.Where == nil {
		stmt.Where = expr
	} else {
		stmt.Where = sqlparse.BinaryExpr{
			Left:  expr,
			Op:    sqlparse.OpAnd,
			Right: sqlparse.Grouping{Sub: stmt.Where},
		}
	}
	return stmt
}

func addUserFilter(stmt *sqlparse.SelectStmt, userID int64) *sqlparse.SelectStmt {
	userIDStr := strconv.Itoa(int(userID))

	return and(stmt, sqlparse.BinaryExpr{
		Left: sqlparse.Identifier{Name: "user_id"},
		Op:   sqlparse.OpEq,
		Right: sqlparse.Value{
			Ty:  sqlparse.TyNumber,
			Tok: sqlparse.Token{Lexeme: userIDStr},
		},
	})
}

func addBookFilter(stmt *sqlparse.SelectStmt, userID int64) *sqlparse.SelectStmt {
	from := &sqlparse.Table{Name: "entries"}
	userIDStr := strconv.Itoa(int(userID))

	if stmt.From != nil {
		tableMatcher := sqlparse.BinaryExpr{
			Left: sqlparse.Identifier{Name: "book_id"},
			Op:   sqlparse.OpEq,
			Right: sqlparse.Subquery{
				Stmt: &sqlparse.SelectStmt{
					Columns: []sqlparse.Expr{sqlparse.Identifier{Name: "id"}},
					From:    &sqlparse.Table{Name: "books"},
					Where: sqlparse.BinaryExpr{
						Left: sqlparse.BinaryExpr{
							Left: sqlparse.Identifier{Name: "name"},
							Op:   sqlparse.OpIlike,
							Right: sqlparse.Value{
								Ty:  sqlparse.TyString,
								Tok: sqlparse.Token{Lexeme: stmt.From.Name},
							},
						},
						Op: sqlparse.OpAnd,
						Right: sqlparse.BinaryExpr{
							Left: sqlparse.Identifier{Name: "user_id"},
							Op:   sqlparse.OpEq,
							Right: sqlparse.Value{
								Ty:  sqlparse.TyNumber,
								Tok: sqlparse.Token{Lexeme: userIDStr},
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

func rewriteSelectStmt(stmt *sqlparse.SelectStmt, env environment) (*sqlparse.SelectStmt, error) {
	var newexpr sqlparse.Expr
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
	return stmt, nil
}

func rewriteExpr(ex sqlparse.Expr, env environment, autoAlias bool) (sqlparse.Expr, environment) {
	switch x := ex.(type) {
	case sqlparse.Identifier:
		// Note that alises are no possible to use in where clauses. In order
		// to respect this, an empty environment is passed in when rewriting
		// the where clause.
		if env.defined(x.Name) {
			return ex, env
		}
		var field sqlparse.Expr
		field = sqlparse.JSONField{Col: "data", Prop: x.Name}
		if autoAlias {
			field = sqlparse.Aliased{As: x.Name, Expr: field}
		}
		return field, env
	case sqlparse.Application:
		for i, ex := range x.Args {
			newexpr, newenv := rewriteExpr(ex, env, false)
			env = newenv
			x.Args[i] = newexpr
		}
		if autoAlias {
			return sqlparse.Aliased{As: x.Fn, Expr: x}, env
		}
		return x, env
	case sqlparse.Grouping:
		newexpr, newenv := rewriteExpr(x.Sub, env, false)
		x.Sub = newexpr
		return x, newenv
	case sqlparse.BinaryExpr:
		newleft, newenv := rewriteExpr(x.Left, env, false)
		newright, lastenv := rewriteExpr(x.Right, newenv, false)
		x.Left = newleft
		x.Right = newright
		return x, lastenv
	case sqlparse.UnaryExpr:
		newexpr, newenv := rewriteExpr(x.Right, env, false)
		x.Right = newexpr
		return x, newenv
	case sqlparse.IsNull:
		newexpr, newenv := rewriteExpr(x.Expr, env, false)
		x.Expr = newexpr
		return x, newenv
	case sqlparse.Aliased:
		newexpr, _ := rewriteExpr(x.Expr, env, false)
		x.Expr = newexpr
		env = env.define(x.As)
		return x, env
	case sqlparse.Value:
		return x, env
	case sqlparse.JSONField:
		return x, env
	case sqlparse.Subquery:
		return x, env
	}
	return ex, env
}
