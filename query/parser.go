package query

import (
	"errors"
	"fmt"
)

var (
	// Remember that adding a new word here likely means it is a keyword and
	// should be added to the sqlInvalidTableAliasTokens array.
	wordAnd      = token{tok: tokIdentifier, lexeme: "and"}
	wordAs       = token{tok: tokIdentifier, lexeme: "as"}
	wordAsc      = token{tok: tokIdentifier, lexeme: "asc"}
	wordBy       = token{tok: tokIdentifier, lexeme: "by"}
	wordDesc     = token{tok: tokIdentifier, lexeme: "desc"}
	wordDistinct = token{tok: tokIdentifier, lexeme: "distinct"}
	wordFalse    = token{tok: tokIdentifier, lexeme: "false"}
	wordFrom     = token{tok: tokIdentifier, lexeme: "from"}
	wordGroup    = token{tok: tokIdentifier, lexeme: "group"}
	wordHaving   = token{tok: tokIdentifier, lexeme: "having"}
	wordIlike    = token{tok: tokIdentifier, lexeme: "ilike"}
	wordIs       = token{tok: tokIdentifier, lexeme: "is"}
	wordLike     = token{tok: tokIdentifier, lexeme: "like"}
	wordLimit    = token{tok: tokIdentifier, lexeme: "limit"}
	wordNot      = token{tok: tokIdentifier, lexeme: "not"}
	wordNull     = token{tok: tokIdentifier, lexeme: "null"}
	wordOr       = token{tok: tokIdentifier, lexeme: "or"}
	wordOrder    = token{tok: tokIdentifier, lexeme: "order"}
	wordSelect   = token{tok: tokIdentifier, lexeme: "select"}
	wordTrue     = token{tok: tokIdentifier, lexeme: "true"}
	wordWhere    = token{tok: tokIdentifier, lexeme: "where"}

	booleanValues    = []token{wordTrue, wordFalse}
	logicalOperators = []token{wordAnd, wordOr}

	sqlOperators = []token{
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
	sqlInvalidTableAliasTokens = []token{
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
	toks []token
}

func (p *parser) done() bool {
	return p.pos >= p.len
}

func (p *parser) peek() token {
	if p.done() {
		return tokenEof
	}
	return p.toks[p.pos]
}

func (p *parser) nextIeqWords(ts ...token) bool {
	next := p.peek()
	for _, t := range ts {
		if next.ieq(t) {
			return true
		}
	}
	return false
}

func (p *parser) nextToks(ts ...tok) bool {
	next := p.peek().tok
	for _, t := range ts {
		if next == t {
			return true
		}
	}
	return false
}

func (p *parser) eat() (token, error) {
	if p.pos+1 > p.len {
		return tokenEof, errors.New("unexpected EOF")
	}
	prev := p.toks[p.pos]
	p.pos += 1
	return prev, nil
}

func (p *parser) expectIeqWord(expected token) (token, error) {
	curr, err := p.eat()
	if err != nil {
		return tokenInvalid, err
	} else if !expected.ieq(curr) {
		return tokenInvalid, fmt.Errorf("invalid token, expecting `%s` but found `%s`",
			expected, curr)
	}
	return curr, nil
}

func (p *parser) expectIeqWords(expected ...token) (token, error) {
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

func (p *parser) expectToks(allowed ...tok) (token, error) {
	curr, err := p.eat()
	if err != nil {
		return tokenInvalid, err
	}
	for _, t := range allowed {
		if curr.tok == t {
			return curr, nil
		}
	}
	return tokenInvalid, fmt.Errorf("invalid token, expecting one of [%v] but found a `%s`",
		allowed, curr.tok.String())
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

func (p *parser) parseSelectStmt() (*selectStmt, error) {
	var err error

	var distinct bool
	var columns []expr
	var from *table
	var where expr
	var groupBy []expr
	var having expr
	var orderBy []order
	var lim *limit

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
		lim = &limit{expr}
	}

	return &selectStmt{
		distinct: distinct,
		columns:  columns,
		from:     from,
		where:    where,
		groupBy:  groupBy,
		having:   having,
		orderBy:  orderBy,
		limit:    lim,
	}, nil
}

func (p *parser) parseColumns() ([]expr, error) {
	done := func() bool { return p.peek().ieq(wordFrom) }
	cont := func() bool { return p.peek().eq(tokenComma) }

	var cols []expr

	for !done() {
		val, err := p.parseExpr()
		if err != nil {
			return nil, err
		}

		cols = append(cols, val)

		if !cont() {
			break
		}

		// Eat the comma
		_, _ = p.eat()
	}

	return cols, nil
}

func (p *parser) parseFromClause() (*table, error) {
	from := &table{}
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
	from.name = nameToken.lexeme

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
		from.alias = aliasToken.lexeme
	}

	return from, nil
}

func (p *parser) parseFilterClause() (expr, error) {
	// A filter clause looks like this: "where" exprs | "having" exprs
	_, err := p.expectIeqWords(wordWhere, wordHaving)
	if err != nil {
		return nil, err
	}
	return p.parseExpr()
}

func (p *parser) parseOrders() ([]order, error) {
	var orders []order
	for !p.done() {
		expr, err := p.parseExpr()
		if err != nil {
			return nil, err
		}

		dir := asc
		if p.nextIeqWords(wordAsc, wordDesc) {
			if tok, _ := p.eat(); tok.ieq(wordAsc) {
				dir = asc
			} else {
				dir = desc
			}
		}

		orders = append(orders, order{dir: dir, expr: expr})
		if !p.nextToks(tokComma) {
			break
		}
		// Eat comma token
		_, _ = p.eat()
	}
	return orders, nil
}

func (p *parser) parseExprs() ([]expr, error) {
	var exprs []expr
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

func (p *parser) parseExpr() (expr, error) {
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
	var exp expr
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
		exp = grouping{sub: sub}
	} else if p.nextIeqWords(booleanValues...) {
		// Handles single-boolean expressions
		val, _ := p.eat()
		exp = value{ty: tyBool, tok: val}
	} else if p.nextToks(tokIdentifier) {
		// Handles single-identifier expressions
		exp, err = p.parseIdentifier()
		if err != nil {
			return nil, err
		}

		if p.nextToks(tokOpenParenthesis) {
			var args []expr
			// Eat open paren token
			_, _ = p.eat()
			args, err := p.parseExprs()
			if err != nil {
				return nil, err
			}
			if _, err = p.expectToks(tokCloseParenthesis); err != nil {
				return nil, err
			}
			exp = application{
				fn:   exp.String(),
				args: args,
			}
		}
	} else if p.nextToks(tokNumber) {
		// Handles single-number expressions
		val, _ := p.eat()
		exp = value{ty: tyNumber, tok: val}
	} else if p.nextToks(tokSingleQuoteString) {
		// Handles single-string expressions
		val, _ := p.eat()
		exp = value{ty: tyString, tok: val}
	}

	// No need to check for bin-expr when we're at EOF
	if p.done() {
		return exp, nil
	}

	if p.nextIeqWords(sqlOperators...) {
		op, err := p.parseSqlOperator()
		if err != nil {
			return nil, err
		}

		left := exp
		right, err := p.parseExpr()
		if err != nil {
			return nil, err
		}
		exp = binaryExpr{
			left:  left,
			op:    op,
			right: right,
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
		exp = isNull{
			not:  not,
			expr: exp,
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
		exp = binaryExpr{
			left:  left,
			op:    op,
			right: right,
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
		exp = aliased{
			as:   as.lexeme,
			expr: exp,
		}
	}

	return exp, nil
}

func (p *parser) parseSqlOperator() (operator, error) {
	t, err := p.expectIeqWords(sqlOperators...)
	if err != nil {
		return opInvalid, err
	}
	switch {
	case t.ieq(tokenDiv):
		return opDiv, nil
	case t.ieq(tokenEq):
		return opEq, nil
	case t.ieq(tokenGe):
		return opGe, nil
	case t.ieq(tokenGt):
		return opGt, nil
	case t.ieq(tokenLe):
		return opLe, nil
	case t.ieq(wordIlike):
		return opIlike, nil
	case t.ieq(wordLike):
		return opLike, nil
	case t.ieq(tokenLt):
		return opLt, nil
	case t.ieq(tokenMinus):
		return opMinus, nil
	case t.ieq(tokenMul):
		return opMul, nil
	case t.ieq(tokenPlus):
		return opPlus, nil
	}
	return opInvalid, nil
}

func (p *parser) parseLogicalOperator() (operator, error) {
	t, err := p.expectIeqWords(logicalOperators...)
	if err != nil {
		return opInvalid, err
	}
	switch {
	case t.ieq(wordAnd):
		return opAnd, nil
	case t.ieq(wordOr):
		return opOr, nil
	}
	return opInvalid, nil
}

func (p *parser) parseIdentifier() (expr, error) {
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
		source = sourceOrNameToken.lexeme
		name = nameToken.lexeme
	} else {
		name = sourceOrNameToken.lexeme
	}

	return identifier{source: source, name: name}, nil
}
