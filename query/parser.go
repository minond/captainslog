package query

import (
	"errors"
	"fmt"
)

var (
	wordAs       = token{tok: tokIdentifier, lexeme: "as"}
	wordDistinct = token{tok: tokIdentifier, lexeme: "distinct"}
	wordFrom     = token{tok: tokIdentifier, lexeme: "from"}
	wordSelect   = token{tok: tokIdentifier, lexeme: "select"}
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

func (p *parser) peek() token {
	if p.pos >= p.len {
		return tokenEof
	}
	return p.toks[p.pos]
}

func (p *parser) eat() (token, error) {
	if p.pos+1 > p.len {
		return tokenEof, errors.New("unexpected EOF")
	}
	prev := p.toks[p.pos]
	p.pos += 1
	return prev, nil
}

func (p *parser) expectWord(expected token) (token, error) {
	curr, err := p.eat()
	if err != nil {
		return tokenInvalid, err
	} else if !expected.ieq(curr) {
		return tokenInvalid, fmt.Errorf("invalid token, expecting `%s` but found `%s`",
			expected, curr)
	}
	return curr, nil
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
	return tokenInvalid, fmt.Errorf("invalid token, expecting one of [%s] but found a `%s`",
		allowed, curr.tok)
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

	_, err = p.expectWord(wordSelect)
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

	// where, err := p.parseWhereClause()
	// if err != nil {
	// 	return nil, err
	// }

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
		// A column looks like this: [ "distinct" ] [ source "." ] name [ "as"
		// alias ], right? And columns look like this: column { [","] column }
		var distinct bool
		var source, name, alias string

		if p.peek().ieq(wordDistinct) {
			_, _ = p.eat()
			distinct = true
		}

		sourceOrNameToken, err := p.expectToks(tokIdentifier)
		if err != nil {
			return nil, err
		}

		if p.peek().ieq(tokenPeriod) {
			// Eat the period
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
			alias:    alias,
			distinct: distinct,
			name:     name,
			source:   source,
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

	// A from clause looks like this: "from" name [ alias ]
	_, err := p.expectWord(wordFrom)
	if err != nil {
		return nil, err
	}

	nameToken, err := p.expectToks(tokIdentifier)
	if err != nil {
		return nil, err
	}
	from.name = nameToken.lexeme

	return from, nil
}
