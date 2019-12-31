package sqlrewrite

import (
	"github.com/minond/captainslog/querier/sqlparse"
)

type SelectEntryData struct{}

func (r SelectEntryData) RewriteSelect(stmt *sqlparse.SelectStmt, env Environment) (*sqlparse.SelectStmt, Environment, error) {
	var newexpr sqlparse.Expr
	var newenv Environment

	for i, expr := range stmt.Columns {
		newexpr, newenv = r.rewriteExpr(expr, env, true)
		env = newenv
		stmt.Columns[i] = newexpr
	}
	for i, expr := range stmt.GroupBy {
		newexpr, _ = r.rewriteExpr(expr, env, false)
		stmt.GroupBy[i] = newexpr
	}
	for i, expr := range stmt.OrderBy {
		newexpr, _ = r.rewriteExpr(expr.Expr, env, false)
		stmt.OrderBy[i].Expr = newexpr
	}

	newexpr, _ = r.rewriteExpr(stmt.Having, env, false)
	stmt.Having = newexpr

	// Column aliases are not available in where clause, so we use a new
	// environment when rewriting the where clause expression.
	newexpr, _ = r.rewriteExpr(stmt.Where, make(Environment), false)
	stmt.Where = newexpr
	return stmt, env, nil
}

func (r SelectEntryData) rewriteExpr(ex sqlparse.Expr, env Environment, autoAlias bool) (sqlparse.Expr, Environment) {
	switch x := ex.(type) {
	case sqlparse.Identifier:
		// Note that alises are no possible to use in where clauses. In order
		// to respect this, an empty environment is passed in when rewriting
		// the where clause.
		if env.Defined(x.Name) {
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
			newexpr, newenv := r.rewriteExpr(ex, env, false)
			env = newenv
			x.Args[i] = newexpr
		}
		if autoAlias {
			return sqlparse.Aliased{As: x.Fn, Expr: x}, env
		}
		return x, env
	case sqlparse.Grouping:
		newexpr, newenv := r.rewriteExpr(x.Sub, env, false)
		x.Sub = newexpr
		return x, newenv
	case sqlparse.BinaryExpr:
		newleft, newenv := r.rewriteExpr(x.Left, env, false)
		newright, lastenv := r.rewriteExpr(x.Right, newenv, false)
		x.Left = newleft
		x.Right = newright
		return x, lastenv
	case sqlparse.UnaryExpr:
		newexpr, newenv := r.rewriteExpr(x.Right, env, false)
		x.Right = newexpr
		return x, newenv
	case sqlparse.IsNull:
		newexpr, newenv := r.rewriteExpr(x.Expr, env, false)
		x.Expr = newexpr
		return x, newenv
	case sqlparse.Aliased:
		newexpr, _ := r.rewriteExpr(x.Expr, env, false)
		x.Expr = newexpr
		env = env.Define(x.As)
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
