package query

import (
	"errors"
	"fmt"
)

var (
	wordAnd      = token{tok: tokIdentifier, lexeme: "and"}
	wordAs       = token{tok: tokIdentifier, lexeme: "as"}
	wordDistinct = token{tok: tokIdentifier, lexeme: "distinct"}
	wordFalse    = token{tok: tokIdentifier, lexeme: "false"}
	wordFrom     = token{tok: tokIdentifier, lexeme: "from"}
	wordLike     = token{tok: tokIdentifier, lexeme: "like"}
	wordOr       = token{tok: tokIdentifier, lexeme: "or"}
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
		wordLike,
	}
)

func Parse(query string) (Ast, error) {
	p := newParser(query)
	return p.do()
}

type parser struct {
	pos  int
	len  int
	toks []token
}

func newParser(query string) *parser {
	toks := lex(query)
	return &parser{
		pos:  0,
		len:  len(toks),
		toks: toks,
	}
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
	t := p.peek()
	switch {
	case t.ieq(wordSelect):
		return p.parseSelectStmt()
	}
	return nil, fmt.Errorf("invalid query, unknown token `%s`", t)
}

func (p *parser) parseSelectStmt() (*selectStmt, error) {
	var err error

	var columns []column
	var from *table
	var where expr

	_, err = p.expectIeqWord(wordSelect)
	if err != nil {
		return nil, err
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
		where, err = p.parseWhereClause()
		if err != nil {
			return nil, err
		}
	}

	if !p.done() {
		return nil, fmt.Errorf("unexpected token `%v`", p.toks[p.pos])
	}

	return &selectStmt{
		columns: columns,
		from:    from,
		where:   where,
	}, nil
}

func (p *parser) parseColumns() ([]column, error) {
	done := func() bool { return p.peek().ieq(wordFrom) }
	cont := func() bool { return p.peek().eq(tokenComma) }

	var cols []column

	for !done() {
		// A column looks like this: [ "distinct" ] expr. Columns are: column {
		// "," column }
		var distinct bool
		var alias string

		if p.peek().ieq(wordDistinct) {
			_, _ = p.eat()
			distinct = true
		}

		val, err := p.parseExprs()
		if err != nil {
			return nil, err
		}

		if p.peek().ieq(wordAs) {
			// Eat the `as` token
			_, _ = p.eat()
			aliasToken, err := p.expectToks(tokIdentifier)
			if err != nil {
				return nil, err
			}
			alias = aliasToken.lexeme
		}

		cols = append(cols, column{
			distinct: distinct,
			val:      val,
			alias:    alias,
		})

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

	if !p.peek().ieq(wordWhere) {
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

func (p *parser) parseWhereClause() (expr, error) {
	// A where clause looks like this: "where" exprs
	_, err := p.expectIeqWord(wordWhere)
	if err != nil {
		return nil, err
	}
	return p.parseExprs()
}

func (p *parser) parseExprs() (expr, error) {
	// value = string-value
	//       | number-value
	//       | boolean-value
	//
	// operator = "list"
	//          | ...
	//
	// expr = ["("] expr [")"]
	//      | identifier operator value
	//      | expr "or" expr
	//      | expr "and" expr
	//      | identifier
	//      | boolean-value
	var exp expr
	var err error

	// Handles grouped expressions
	if p.peek().eq(tokenOpenParenthesis) {
		// Eat the open paren token
		_, _ = p.eat()
		sub, err := p.parseExprs()
		if err != nil {
			return nil, err
		}
		_, err = p.expectToks(tokCloseParenthesis)
		if err != nil {
			return nil, err
		}
		exp = grouping{sub: sub}
	} else if p.nextToks(tokIdentifier) {
		// Handles single-identifier expressions
		exp, err = p.parseIdentifier()
		if err != nil {
			return nil, err
		}
	} else if p.nextIeqWords(booleanValues...) {
		// Handles single-boolean expressions
		val, _ := p.eat()
		exp = value{ty: tyBool, tok: val}
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
		right, err := p.parseExprs()
		if err != nil {
			return nil, err
		}
		exp = binaryExpr{
			left:  left,
			op:    op,
			right: right,
		}
	}

	if p.nextIeqWords(logicalOperators...) {
		op, err := p.parseLogicalOperator()
		if err != nil {
			return nil, err
		}

		left := exp
		right, err := p.parseExprs()
		if err != nil {
			return nil, err
		}
		exp = binaryExpr{
			left:  left,
			op:    op,
			right: right,
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

	return identifier{name: name, source: source}, nil
}
