package sqlrewrite

import (
	"strconv"

	"github.com/minond/captainslog/querier/sqlparse"
)

type BookScopingRewriter struct {
	UserID int64
}

func (r BookScopingRewriter) RewriteSelect(stmt *sqlparse.SelectStmt, env Environment) (*sqlparse.SelectStmt, Environment, error) {
	if stmt.From != nil {
		userIDStr := strconv.Itoa(int(r.UserID))
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

		stmt = addFilterToSelect(stmt, tableMatcher)
	}

	return stmt, env, nil
}
