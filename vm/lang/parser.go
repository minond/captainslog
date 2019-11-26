package lang

import (
	"fmt"
	"strconv"
	"strings"
)

type expr uint8

const (
	exprInvalid expr = iota
	exprSexpr
	exprQuote
	exprScalar
	exprId
)

/**
 * main			 = epxr*
 *               ;
 *
 * expr          = "(" expr ")"
 *               | "'" expr
 *               | identifier
 *               | number
 *               | string
 *               | boolean
 *               ;
 *
 * boolean       = "#t"
 *               | "#f"
 *               ;
 *
 * identifier    = ?? identifier ??
 *               ;
 *
 * number        = ?? number ??
 *               ;
 *
 * string        = ?? string ??
 *               ;
 */
type Expr interface {
	fmt.Stringer
	expr() expr
}

type sexpr struct{ Values []Expr }

func Sexpr(values ...Expr) *sexpr { return &sexpr{Values: values} }
func (sexpr) expr() expr          { return exprSexpr }
func (e sexpr) String() string {
	buff := strings.Builder{}
	buff.WriteString("(")
	for i, val := range e.Values {
		if i != 0 {
			buff.WriteRune(' ')
		}
		buff.WriteString(val.String())
	}
	buff.WriteString(")")
	return buff.String()
}

type quote struct{ Value Expr }

func Quote(value Expr) *quote  { return &quote{Value: value} }
func (quote) expr() expr       { return exprQuote }
func (e quote) String() string { return fmt.Sprintf("'%v", e.Value.String()) }

type identifier struct{ Value string }

func Identifier(value string) *identifier { return &identifier{Value: value} }
func (identifier) expr() expr             { return exprId }
func (e identifier) String() string       { return e.Value }

type number struct{ Value float64 }

func Number(value float64) *number { return &number{Value: value} }
func (number) expr() expr          { return exprScalar }
func (e number) String() string    { return strconv.FormatFloat(e.Value, 'f', -1, 64) }

type str struct{ Value string }

func String(value string) *str { return &str{Value: value} }
func (str) expr() expr         { return exprScalar }
func (e str) String() string   { return fmt.Sprintf(`"%v"`, e.Value) }

type boolean struct{ Value bool }

func Boolean(value bool) *boolean { return &boolean{Value: value} }
func (boolean) expr() expr        { return exprScalar }
func (e boolean) String() string {
	if e.Value {
		return "#t"
	}
	return "#f"
}

func Parse(code string) ([]Expr, error) {
	tokens := lex(code)
	p := parser{
		tokens: tokens,
		len:    len(tokens),
		pos:    0,
	}

	return p.do()
}

type parser struct {
	tokens []Token
	len    int
	pos    int
}

func (p parser) done() bool {
	return p.pos >= p.len
}

func (p *parser) eat() {
	p.pos++
}

func (p parser) curr() Token {
	return p.tokens[p.pos]
}

func (p parser) currEq(o Token) bool {
	return p.tokens[p.pos].Eq(o)
}

func (p parser) currIsA(o tok) bool {
	return p.tokens[p.pos].IsA(o)
}

func (p *parser) expectA(t tok) error {
	if p.done() {
		return fmt.Errorf("expected %v but reached eof", t)
	}

	curr := p.curr()
	if !curr.IsA(t) {
		return fmt.Errorf("expected %v but found %v", t, curr.tok)
	}

	return nil
}

func (p *parser) expectEq(t Token) error {
	if p.done() {
		return fmt.Errorf("expected %v but reached eof", t)
	}

	curr := p.curr()
	if !curr.Eq(t) {
		return fmt.Errorf("expected %v but found %v", t, curr.tok)
	}

	return nil
}

func (p *parser) do() ([]Expr, error) {
	var buff []Expr

	for !p.done() {
		part, err := p.parseExpr()
		if err != nil {
			return nil, err
		}
		buff = append(buff, part)
	}

	return buff, nil
}

func (p *parser) parseExpr() (Expr, error) {
	if p.currEq(tokenOpenParen) {
		return p.parseSexpr()
	} else if p.currEq(tokenQuote) {
		return p.parseQuote()
	} else if p.currIsA(tokWord) {
		return p.parseId()
	} else if p.currIsA(tokNumber) {
		return p.parseNumber()
	} else if p.currIsA(tokString) {
		return p.parseString()
	} else if p.currIsA(tokBoolean) {
		return p.parseBoolean()
	}

	return nil, fmt.Errorf("invalid syntax: %v", p.curr())
}

func (p *parser) parseSexpr() (*sexpr, error) {
	if err := p.expectEq(tokenOpenParen); err != nil {
		return nil, err
	}

	p.eat() // Eat the open paren

	var values []Expr
	for !p.done() && !p.currEq(tokenCloseParen) {
		val, err := p.parseExpr()
		if err != nil {
			return nil, err
		}

		values = append(values, val)
	}

	if err := p.expectEq(tokenCloseParen); err != nil {
		return nil, err
	}

	p.eat() // Eat the closing paren

	return Sexpr(values...), nil
}

func (p *parser) parseQuote() (*quote, error) {
	if err := p.expectEq(tokenQuote); err != nil {
		return nil, err
	}

	p.eat() // Eat the quote

	val, err := p.parseExpr()
	if err != nil {
		return nil, err
	}

	return Quote(val), nil
}

func (p *parser) parseId() (*identifier, error) {
	if err := p.expectA(tokWord); err != nil {
		return nil, err
	}

	curr := p.curr()
	p.eat() // Eat the id

	return Identifier(string(curr.lexeme)), nil
}

func (p *parser) parseNumber() (*number, error) {
	if err := p.expectA(tokNumber); err != nil {
		return nil, err
	}

	curr := p.curr()
	p.eat() // Eat the number

	val, err := strconv.ParseFloat(string(curr.lexeme), 64)
	if err != nil {
		return nil, fmt.Errorf("invalid number: %v", curr)
	}

	return Number(val), nil
}

func (p *parser) parseString() (*str, error) {
	if err := p.expectA(tokString); err != nil {
		return nil, err
	}

	curr := p.curr()
	p.eat() // Eat the string

	return String(string(curr.lexeme)), nil
}

func (p *parser) parseBoolean() (*boolean, error) {
	if err := p.expectA(tokBoolean); err != nil {
		return nil, err
	}

	curr := p.curr()
	p.eat() // Eat the boolean

	var val bool
	switch string(curr.lexeme) {
	case "#t":
		val = true
	case "#f":
		val = false
	default:
		return nil, fmt.Errorf("invalid boolean: %v", curr)
	}

	return Boolean(val), nil
}
