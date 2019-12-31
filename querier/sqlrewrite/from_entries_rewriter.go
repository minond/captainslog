package sqlrewrite

import (
	"github.com/minond/captainslog/querier/sqlparse"
)

type FromEntriesRewriter struct {
	UserID int64
}

func (r FromEntriesRewriter) RewriteSelect(stmt *sqlparse.SelectStmt, env Environment) (*sqlparse.SelectStmt, Environment, error) {
	stmt.From = &sqlparse.Table{Name: "entries"}
	return stmt, env, nil
}
