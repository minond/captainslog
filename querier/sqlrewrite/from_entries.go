package sqlrewrite

import (
	"github.com/minond/captainslog/querier/sqlparse"
)

type FromEntries struct {
	UserID int64
}

func (r FromEntries) RewriteSelect(stmt *sqlparse.SelectStmt, env Environment) (*sqlparse.SelectStmt, Environment, error) {
	stmt.From = &sqlparse.Table{Name: "entries"}
	return stmt, env, nil
}
