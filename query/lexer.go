//go:generate stringer -type=tok
package query

import (
	"fmt"
	"unicode"
)

const (
	closeParen  = rune(')')
	comma       = rune(',')
	div         = rune('/')
	doubleQuote = rune('"')
	eof         = rune(0)
	eq          = rune('=')
	gt          = rune('>')
	lt          = rune('<')
	minus       = rune('-')
	mul         = rune('*')
	openParen   = rune('(')
	period      = rune('.')
	plus        = rune('+')
	singleQuote = rune('\'')
	underscore  = rune('_')
)

type tok int8

const (
	tokInvalid tok = iota

	// Tokens with known lexeme values should go here. If this changes make
	// sure to update the token.eq method.
	tokCloseParenthesis
	tokComma
	tokDiv
	tokEq
	tokGe
	tokGt
	tokLe
	tokLt
	tokMinus
	tokMul
	tokOpenParenthesis
	tokPeriod
	tokPlus

	// Tokens with unknown lexeme values should go here.
	tokDoubleQuoteString
	tokIdentifier
	tokNumber
	tokSingleQuoteString
)

type token struct {
	tok    tok
	lexeme string
}

func (t token) String() string {
	if t.lexeme == "" {
		return fmt.Sprintf("(%s)", t.tok)
	}
	return fmt.Sprintf("(%s `%s`)", t.tok, t.lexeme)
}

func (t token) eq(other token) bool {
	// Compare to late item in the tokens wiht known lexeme values group.
	if t.tok <= tokPlus {
		return t.tok == other.tok
	}
	return t.tok == other.tok && t.lexeme == other.lexeme
}

var (
	tokenCloseParenthesis = token{tok: tokCloseParenthesis}
	tokenComma            = token{tok: tokComma}
	tokenDiv              = token{tok: tokDiv}
	tokenEq               = token{tok: tokEq}
	tokenGe               = token{tok: tokGe}
	tokenGt               = token{tok: tokGt}
	tokenInvalid          = token{tok: tokInvalid}
	tokenLe               = token{tok: tokLe}
	tokenLt               = token{tok: tokLt}
	tokenMinus            = token{tok: tokMinus}
	tokenMul              = token{tok: tokMul}
	tokenOpenParenthesis  = token{tok: tokOpenParenthesis}
	tokenPeriod           = token{tok: tokPeriod}
	tokenPlus             = token{tok: tokPlus}
)

var (
	mappedToken = map[rune]token{
		closeParen: tokenCloseParenthesis,
		comma:      tokenComma,
		div:        tokenDiv,
		eq:         tokenEq,
		minus:      tokenMinus,
		mul:        tokenMul,
		openParen:  tokenOpenParenthesis,
		period:     tokenPeriod,
		plus:       tokenPlus,
	}
)

func lex(raw string) []token {
	rs := []rune(raw)
	total := len(rs)

	var toks []token

	for curr := 0; curr < total; {
		r := rs[curr]
		var lexeme string

		if tok, ok := mappedToken[r]; ok {
			toks = append(toks, tok)
			curr++
			continue
		}

		switch {
		case unicode.IsSpace(r):
			curr++

		case r == gt:
			if peek(rs, curr, total) == eq {
				toks = append(toks, tokenGe)
				curr++
			} else {
				toks = append(toks, tokenGt)
			}
			curr++

		case r == lt:
			if peek(rs, curr, total) == eq {
				toks = append(toks, tokenLe)
				curr++
			} else {
				toks = append(toks, tokenLt)
			}
			curr++

		case r == singleQuote:
			lexeme, curr = eatWhile(not(is(singleQuote)), rs, curr+1, total)
			toks = append(toks, token{
				tok:    tokSingleQuoteString,
				lexeme: lexeme,
			})
			curr++

		case r == doubleQuote:
			lexeme, curr = eatWhile(not(is(doubleQuote)), rs, curr+1, total)
			toks = append(toks, token{
				tok:    tokDoubleQuoteString,
				lexeme: lexeme,
			})
			curr++

		case unicode.IsNumber(r):
			lexeme, curr = eatWhile(unicode.IsNumber, rs, curr+1, total)
			toks = append(toks, token{
				tok:    tokNumber,
				lexeme: string(r) + lexeme,
			})

		case isIdentifier(r):
			lexeme, curr = eatWhile(isIdentifier, rs, curr+1, total)
			toks = append(toks, token{
				tok:    tokIdentifier,
				lexeme: string(r) + lexeme,
			})

		default:
			toks = append(toks, tokenInvalid)
			curr++
		}
	}

	return toks
}

type predicate func(rune) bool

func is(r rune) predicate {
	return func(x rune) bool {
		return r == x
	}
}

func not(fn predicate) predicate {
	return func(r rune) bool {
		return !fn(r)
	}
}

func isIdentifier(r rune) bool {
	return unicode.IsLetter(r) || r == underscore
}

func peek(rs []rune, curr, total int) rune {
	if curr < total {
		return rs[curr+1]
	}
	return eof
}

func eatWhile(fn predicate, rs []rune, curr, total int) (string, int) {
	buff := make([]rune, 0, 10)

	for ; curr < total; curr++ {
		r := rs[curr]
		if !fn(r) {
			break
		}
		buff = append(buff, r)
	}

	return string(buff), curr
}
