package sqlparse

import (
	"errors"
	"fmt"
)

var (
	// Remember that adding a new word here likely means it is a keyword and
	// should be added to the sqlInvalidTableAliasTokens array.
	wordAnd      = Token{Tok: tokIdentifier, Lexeme: "and"}
	wordAs       = Token{Tok: tokIdentifier, Lexeme: "as"}
	wordAsc      = Token{Tok: tokIdentifier, Lexeme: "asc"}
	wordBy       = Token{Tok: tokIdentifier, Lexeme: "by"}
	wordDesc     = Token{Tok: tokIdentifier, Lexeme: "desc"}
	wordDistinct = Token{Tok: tokIdentifier, Lexeme: "distinct"}
	wordFalse    = Token{Tok: tokIdentifier, Lexeme: "false"}
	wordFrom     = Token{Tok: tokIdentifier, Lexeme: "from"}
	wordGroup    = Token{Tok: tokIdentifier, Lexeme: "group"}
	wordHaving   = Token{Tok: tokIdentifier, Lexeme: "having"}
	wordIlike    = Token{Tok: tokIdentifier, Lexeme: "ilike"}
	wordIs       = Token{Tok: tokIdentifier, Lexeme: "is"}
	wordLike     = Token{Tok: tokIdentifier, Lexeme: "like"}
	wordLimit    = Token{Tok: tokIdentifier, Lexeme: "limit"}
	wordNot      = Token{Tok: tokIdentifier, Lexeme: "not"}
	wordNull     = Token{Tok: tokIdentifier, Lexeme: "null"}
	wordOr       = Token{Tok: tokIdentifier, Lexeme: "or"}
	wordOrder    = Token{Tok: tokIdentifier, Lexeme: "order"}
	wordSelect   = Token{Tok: tokIdentifier, Lexeme: "select"}
	wordTrue     = Token{Tok: tokIdentifier, Lexeme: "true"}
	wordWhere    = Token{Tok: tokIdentifier, Lexeme: "where"}

	booleanValues    = []Token{wordTrue, wordFalse}
	logicalOperators = []Token{wordAnd, wordOr}

	sqlOperators = []Token{
		tokenDiv,
		tokenEq,
		tokenGe,
		tokenGt,
		tokenLe,
		tokenLt,
		tokenMinus,
		tokenMul,
		tokenPlus,
		wordIlike,
		wordLike,
	}

	// Array of reserved keywords in sql. These cannot be used as table
	// aliases (but may be used in column aliases)
	sqlInvalidTableAliasTokens = []Token{
		wordAnd,
		wordAs,
		wordAsc,
		wordDesc,
		wordDistinct,
		wordFalse,
		wordFrom,
		wordGroup,
		wordHaving,
		wordIlike,
		wordIs,
		wordLike,
		wordLimit,
		wordNot,
		wordNull,
		wordOr,
		wordOrder,
		wordSelect,
		wordTrue,
		wordWhere,
	}
)

func Parse(query string) (Ast, error) {
	toks := lex(query)
	parse := &parser{len: len(toks), toks: toks}
	return parse.do()
}

type parser struct {
	pos  int
	len  int
	toks []Token
}

func (p *parser) done() bool {
	return p.pos >= p.len
}

func (p *parser) peek() Token {
	if p.done() {
		return tokenEOF
	}
	return p.toks[p.pos]
}

func (p *parser) nextIeqWords(ts ...Token) bool {
	next := p.peek()
	for _, t := range ts {
		if next.ieq(t) {
			return true
		}
	}
	return false
}

func (p *parser) nextToks(ts ...Tok) bool {
	next := p.peek().Tok
	for _, t := range ts {
		if next == t {
			return true
		}
	}
	return false
}

func (p *parser) eat() (Token, error) {
	if p.pos+1 > p.len {
		return tokenEOF, errors.New("unexpected EOF")
	}
	prev := p.toks[p.pos]
	p.pos++
	return prev, nil
}

func (p *parser) expectIeqWord(expected Token) (Token, error) {
	curr, err := p.eat()
	if err != nil {
		return tokenInvalid, err
	} else if !expected.ieq(curr) {
		return tokenInvalid, fmt.Errorf("invalid token, expecting `%s` but found `%s`",
			expected, curr)
	}
	return curr, nil
}

func (p *parser) expectIeqWords(expected ...Token) (Token, error) {
	curr, err := p.eat()
	if err != nil {
		return tokenInvalid, err
	}

	for _, ex := range expected {
		if ex.ieq(curr) {
			return curr, nil
		}
	}

	return tokenInvalid, fmt.Errorf("invalid token, expecting on of [%v] but found `%s`",
		expected, curr)
}

func (p *parser) expectToks(allowed ...Tok) (Token, error) {
	curr, err := p.eat()
	if err != nil {
		return tokenInvalid, err
	}
	for _, t := range allowed {
		if curr.Tok == t {
			return curr, nil
		}
	}
	return tokenInvalid, fmt.Errorf("invalid token, expecting one of [%v] but found a `%s`",
		allowed, curr.Tok.String())
}

func (p *parser) do() (Ast, error) {
	var err error
	var stmt Ast

	t := p.peek()
	switch {
	case t.ieq(wordSelect):
		stmt, err = p.parseSelectStmt()
	default:
		return nil, fmt.Errorf("invalid query, unknown token `%s`", t)
	}

	if !p.done() {
		return nil, fmt.Errorf("unexpected token `%v`, expecting EOF", p.toks[p.pos])
	}

	return stmt, err
}

func (p *parser) parseSelectStmt() (*SelectStmt, error) {
	var err error

	var distinct bool
	var columns []Expr
	var from *Table
	var where Expr
	var groupBy []Expr
	var having Expr
	var orderBy []Order
	var lim *Limit

	_, err = p.expectIeqWord(wordSelect)
	if err != nil {
		return nil, err
	}

	if p.peek().ieq(wordDistinct) {
		// Eat "distinct" token
		_, _ = p.eat()
		distinct = true
	}

	columns, err = p.parseColumns()
	if err != nil {
		return nil, err
	}

	if p.peek().ieq(wordFrom) {
		from, err = p.parseFromClause()
		if err != nil {
			return nil, err
		}
	}

	if p.peek().ieq(wordWhere) {
		where, err = p.parseFilterClause()
		if err != nil {
			return nil, err
		}
	}

	if p.peek().ieq(wordGroup) {
		_, _ = p.eat()
		if _, err := p.expectIeqWord(wordBy); err != nil {
			return nil, err
		}
		groupBy, err = p.parseExprs()
		if err != nil {
			return nil, err
		}
	}

	if p.peek().ieq(wordHaving) {
		having, err = p.parseFilterClause()
		if err != nil {
			return nil, err
		}
	}

	if p.peek().ieq(wordOrder) {
		// Eat "order" token
		_, _ = p.eat()
		if _, err := p.expectIeqWord(wordBy); err != nil {
			return nil, err
		}
		orderBy, err = p.parseOrders()
		if err != nil {
			return nil, err
		}
	}

	if p.peek().ieq(wordLimit) {
		_, _ = p.eat()
		expr, err := p.parseExpr()
		if err != nil {
			return nil, err
		}
		lim = &Limit{expr}
	}

	return &SelectStmt{
		Distinct: distinct,
		Columns:  columns,
		From:     from,
		Where:    where,
		GroupBy:  groupBy,
		Having:   having,
		OrderBy:  orderBy,
		Limit:    lim,
	}, nil
}

func (p *parser) parseColumns() ([]Expr, error) {
	done := func() bool { return p.peek().ieq(wordFrom) }
	cont := func() bool { return p.peek().eq(tokenComma) }

	var cols []Expr

	for !done() {
		val, err := p.parseExpr()
		if err != nil {
			return nil, err
		}

		if val != nil {
			cols = append(cols, val)
		}

		if !cont() {
			break
		}

		// Eat the comma
		_, _ = p.eat()
	}

	return cols, nil
}

func (p *parser) parseFromClause() (*Table, error) {
	from := &Table{}
	aliased := false

	// A from clause looks like this: "from" name [ [ "as" ] alias ]
	_, err := p.expectIeqWord(wordFrom)
	if err != nil {
		return nil, err
	}

	nameToken, err := p.expectToks(tokIdentifier)
	if err != nil {
		return nil, err
	}
	from.Name = nameToken.Lexeme

	if p.done() {
		return from, nil
	}

	if p.peek().ieq(wordAs) {
		// Eat the `as` token
		_, _ = p.eat()
		aliased = true
	}

	if !p.nextIeqWords(sqlInvalidTableAliasTokens...) {
		aliased = true
	}

	if aliased {
		aliasToken, err := p.expectToks(tokIdentifier)
		if err != nil {
			return nil, err
		}
		from.Alias = aliasToken.Lexeme
	}

	return from, nil
}

func (p *parser) parseFilterClause() (Expr, error) {
	// A filter clause looks like this: "where" exprs | "having" exprs
	_, err := p.expectIeqWords(wordWhere, wordHaving)
	if err != nil {
		return nil, err
	}
	return p.parseExpr()
}

func (p *parser) parseOrders() ([]Order, error) {
	var orders []Order
	for !p.done() {
		expr, err := p.parseExpr()
		if err != nil {
			return nil, err
		}

		dir := Asc
		if p.nextIeqWords(wordAsc, wordDesc) {
			if tok, _ := p.eat(); tok.ieq(wordAsc) {
				dir = Asc
			} else {
				dir = Desc
			}
		}

		orders = append(orders, Order{Dir: dir, Expr: expr})
		if !p.nextToks(tokComma) {
			break
		}
		// Eat comma token
		_, _ = p.eat()
	}
	return orders, nil
}

func (p *parser) parseExprs() ([]Expr, error) {
	var exprs []Expr
	for !p.done() {
		expr, err := p.parseExpr()
		if err != nil {
			return nil, err
		}
		if expr == nil {
			break
		}
		exprs = append(exprs, expr)
		if !p.nextToks(tokComma) {
			break
		}
		// Eat comma token
		_, _ = p.eat()
	}
	return exprs, nil
}

func (p *parser) parseExpr() (Expr, error) {
	// value = string-value
	//       | number-value
	//       | boolean-value
	//
	// operator = "list"
	//          | ...
	//
	// typ = "decimal"
	//     | "float"
	//
	// expr = ["("] expr [")"]
	//      | expr "(" [ expr { "," expr } ] ")"
	//      | expr "is null"
	//      | expr "is not null"
	//      | expr operator expr
	//      | expr "or" expr
	//      | expr "and" expr
	//      | identifier [ "as" typ ]
	//      | boolean-value
	var exp Expr
	var err error

	// Handles grouped expressions
	if p.peek().eq(tokenOpenParenthesis) {
		// Eat the open paren token
		_, _ = p.eat()
		sub, err := p.parseExpr()
		if err != nil {
			return nil, err
		}
		_, err = p.expectToks(tokCloseParenthesis)
		if err != nil {
			return nil, err
		}
		exp = Grouping{Sub: sub}
	} else if p.nextIeqWords(booleanValues...) {
		// Handles single-boolean expressions
		val, _ := p.eat()
		exp = Value{Ty: TyBool, Tok: val}
	} else if p.nextToks(tokIdentifier) {
		// Handles single-identifier expressions
		exp, err = p.parseIdentifier()
		if err != nil {
			return nil, err
		}

		if p.nextToks(tokOpenParenthesis) {
			var args []Expr
			// Eat open paren token
			_, _ = p.eat()
			args, err := p.parseExprs()
			if err != nil {
				return nil, err
			}
			if _, err = p.expectToks(tokCloseParenthesis); err != nil {
				return nil, err
			}
			exp = Application{
				Fn:   exp.String(),
				Args: args,
			}
		}
	} else if p.nextToks(tokNumber) {
		// Handles single-number expressions
		val, _ := p.eat()
		exp = Value{Ty: TyNumber, Tok: val}
	} else if p.nextToks(tokSingleQuoteString) {
		// Handles single-string expressions
		val, _ := p.eat()
		exp = Value{Ty: TyString, Tok: val}
	}

	// No need to check for bin-expr when we're at EOF
	if p.done() {
		return exp, nil
	}

	if p.nextIeqWords(sqlOperators...) {
		op, err := p.parseSQLOperator()
		if err != nil {
			return nil, err
		}

		left := exp
		right, err := p.parseExpr()
		if err != nil {
			return nil, err
		}
		exp = BinaryExpr{
			Left:  left,
			Op:    op,
			Right: right,
		}
	}

	if p.nextIeqWords(wordIs) {
		not := false
		// Eat "is" token
		_, _ = p.eat()
		if p.nextIeqWords(wordNot) {
			// Eat "not" token
			_, _ = p.eat()
			not = true
		}
		if _, err := p.expectIeqWord(wordNull); err != nil {
			return nil, err
		}
		exp = IsNull{
			Not:  not,
			Expr: exp,
		}
	}

	if p.nextIeqWords(logicalOperators...) {
		op, err := p.parseLogicalOperator()
		if err != nil {
			return nil, err
		}

		left := exp
		right, err := p.parseExpr()
		if err != nil {
			return nil, err
		}
		exp = BinaryExpr{
			Left:  left,
			Op:    op,
			Right: right,
		}
	}

	if p.peek().ieq(wordAs) {
		// Eat the "as" token
		_, _ = p.eat()
		// cast, err := p.expectIeqWords(typValues...)
		as, err := p.expectToks(tokIdentifier)
		if err != nil {
			return nil, err
		}
		exp = Aliased{
			As:   as.Lexeme,
			Expr: exp,
		}
	}

	return exp, nil
}

func (p *parser) parseSQLOperator() (Operator, error) {
	t, err := p.expectIeqWords(sqlOperators...)
	if err != nil {
		return OpInvalid, err
	}
	switch {
	case t.ieq(tokenDiv):
		return OpDiv, nil
	case t.ieq(tokenEq):
		return OpEq, nil
	case t.ieq(tokenGe):
		return OpGe, nil
	case t.ieq(tokenGt):
		return OpGt, nil
	case t.ieq(tokenLe):
		return OpLe, nil
	case t.ieq(wordIlike):
		return OpIlike, nil
	case t.ieq(wordLike):
		return OpLike, nil
	case t.ieq(tokenLt):
		return OpLt, nil
	case t.ieq(tokenMinus):
		return OpMinus, nil
	case t.ieq(tokenMul):
		return OpMul, nil
	case t.ieq(tokenPlus):
		return OpPlus, nil
	}
	return OpInvalid, nil
}

func (p *parser) parseLogicalOperator() (Operator, error) {
	t, err := p.expectIeqWords(logicalOperators...)
	if err != nil {
		return OpInvalid, err
	}
	switch {
	case t.ieq(wordAnd):
		return OpAnd, nil
	case t.ieq(wordOr):
		return OpOr, nil
	}
	return OpInvalid, nil
}

func (p *parser) parseIdentifier() (Expr, error) {
	var source, name string

	sourceOrNameToken, err := p.eat()
	if err != nil {
		return nil, err
	}

	if p.peek().ieq(tokenPeriod) {
		// Eat the period token
		_, _ = p.eat()
		nameToken, err := p.expectToks(tokIdentifier)
		if err != nil {
			return nil, err
		}
		source = sourceOrNameToken.Lexeme
		name = nameToken.Lexeme
	} else {
		name = sourceOrNameToken.Lexeme
	}

	return Identifier{Source: source, Name: name}, nil
}
