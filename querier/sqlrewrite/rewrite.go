package sqlrewrite

import (
	"fmt"

	"github.com/minond/captainslog/querier/sqlparse"
)

type SelectRewriter interface {
	RewriteSelect(*sqlparse.SelectStmt, Environment) (*sqlparse.SelectStmt, Environment, error)
}

func Rewrite(ast sqlparse.Ast, rewriters ...SelectRewriter) (sqlparse.Ast, error) {
	switch stmt := ast.(type) {
	case *sqlparse.SelectStmt:
		var err error
		env := make(Environment)

		for _, r := range rewriters {
			stmt, env, err = r.RewriteSelect(stmt, env)
			if err != nil {
				return nil, err
			}
		}

		return stmt, err
	}

	return nil, fmt.Errorf("invalid query type: %v", ast.QueryType())
}

func RewriteEntryQuery(ast sqlparse.Ast, userID int64) (sqlparse.Ast, error) {
	return Rewrite(ast,
		ApplicationSchema{},
		UserScoping{UserID: userID},
		BookScoping{UserID: userID},
		FromEntries{},
	)
}

func addFilterToSelect(stmt *sqlparse.SelectStmt, expr sqlparse.Expr) *sqlparse.SelectStmt {
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
