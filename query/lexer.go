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
	// sure to update the Token.Eq method.
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

type Token struct {
	Tok    tok
	Lexeme string
}

func (t Token) String() string {
	if t.Lexeme == "" {
		return fmt.Sprintf("(%s)", t.Tok)
	}
	return fmt.Sprintf("(%s `%s`)", t.Tok, t.Lexeme)
}

func (t Token) Eq(other Token) bool {
	// Compare to late item in the tokens wiht known lexeme values group.
	if t.Tok <= tokPlus {
		return t.Tok == other.Tok
	}
	return t.Tok == other.Tok && t.Lexeme == other.Lexeme
}

var (
	TokenCloseParenthesis = Token{Tok: tokCloseParenthesis}
	TokenComma            = Token{Tok: tokComma}
	TokenDiv              = Token{Tok: tokDiv}
	TokenEq               = Token{Tok: tokEq}
	TokenGe               = Token{Tok: tokGe}
	TokenGt               = Token{Tok: tokGt}
	TokenInvalid          = Token{Tok: tokInvalid}
	TokenLe               = Token{Tok: tokLe}
	TokenLt               = Token{Tok: tokLt}
	TokenMinus            = Token{Tok: tokMinus}
	TokenMul              = Token{Tok: tokMul}
	TokenOpenParenthesis  = Token{Tok: tokOpenParenthesis}
	TokenPeriod           = Token{Tok: tokPeriod}
	TokenPlus             = Token{Tok: tokPlus}
)

var (
	mappedToken = map[rune]Token{
		closeParen: TokenCloseParenthesis,
		comma:      TokenComma,
		div:        TokenDiv,
		eq:         TokenEq,
		minus:      TokenMinus,
		mul:        TokenMul,
		openParen:  TokenOpenParenthesis,
		period:     TokenPeriod,
		plus:       TokenPlus,
	}
)

func Lex(raw string) []Token {
	rs := []rune(raw)
	total := len(rs)

	var toks []Token

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
				toks = append(toks, TokenGe)
				curr++
			} else {
				toks = append(toks, TokenGt)
			}
			curr++

		case r == lt:
			if peek(rs, curr, total) == eq {
				toks = append(toks, TokenLe)
				curr++
			} else {
				toks = append(toks, TokenLt)
			}
			curr++

		case r == singleQuote:
			lexeme, curr = eatWhile(not(is(singleQuote)), rs, curr+1, total)
			toks = append(toks, Token{
				Tok:    tokSingleQuoteString,
				Lexeme: lexeme,
			})
			curr++

		case r == doubleQuote:
			lexeme, curr = eatWhile(not(is(doubleQuote)), rs, curr+1, total)
			toks = append(toks, Token{
				Tok:    tokDoubleQuoteString,
				Lexeme: lexeme,
			})
			curr++

		case unicode.IsNumber(r):
			lexeme, curr = eatWhile(unicode.IsNumber, rs, curr+1, total)
			toks = append(toks, Token{
				Tok:    tokNumber,
				Lexeme: string(r) + lexeme,
			})

		case isIdentifier(r):
			lexeme, curr = eatWhile(isIdentifier, rs, curr+1, total)
			toks = append(toks, Token{
				Tok:    tokIdentifier,
				Lexeme: string(r) + lexeme,
			})

		default:
			toks = append(toks, TokenInvalid)
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
