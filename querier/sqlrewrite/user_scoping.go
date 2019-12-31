package sqlrewrite

import (
	"strconv"

	"github.com/minond/captainslog/querier/sqlparse"
)

type UserScoping struct {
	UserID int64
}

func (r UserScoping) RewriteSelect(stmt *sqlparse.SelectStmt, env Environment) (*sqlparse.SelectStmt, Environment, error) {
	userIDStr := strconv.Itoa(int(r.UserID))
	rewritten := addFilterToSelect(stmt, sqlparse.BinaryExpr{
		Left: sqlparse.Identifier{Name: "user_id"},
		Op:   sqlparse.OpEq,
		Right: sqlparse.Value{
			Ty:  sqlparse.TyNumber,
			Tok: sqlparse.Token{Lexeme: userIDStr},
		},
	})

	return rewritten, env, nil
}
