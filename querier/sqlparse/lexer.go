//go:generate stringer -type=Tok
package sqlparse

import (
	"fmt"
	"strings"
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

type Tok uint8

const (
	tokInvalid Tok = iota
	tokEOF

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

type Token struct {
	Tok    Tok
	Lexeme string
}

func (t Token) String() string {
	if t.Lexeme == "" {
		return fmt.Sprintf("(%s)", t.Tok.String())
	}
	return fmt.Sprintf("(%s `%s`)", t.Tok.String(), t.Lexeme)
}

func (t Token) eq(other Token) bool {
	// Compare to late item in the tokens with known lexeme values group.
	if t.Tok <= tokPlus {
		return t.Tok == other.Tok
	}
	return t.Tok == other.Tok && t.Lexeme == other.Lexeme
}

func (t Token) ieq(other Token) bool {
	return Token{
		Tok:    t.Tok,
		Lexeme: strings.ToLower(t.Lexeme),
	}.eq(Token{
		Tok:    other.Tok,
		Lexeme: strings.ToLower(other.Lexeme),
	})
}

var (
	tokenCloseParenthesis = Token{Tok: tokCloseParenthesis}
	tokenComma            = Token{Tok: tokComma}
	tokenDiv              = Token{Tok: tokDiv}
	tokenEOF              = Token{Tok: tokEOF}
	tokenEq               = Token{Tok: tokEq}
	tokenGe               = Token{Tok: tokGe}
	tokenGt               = Token{Tok: tokGt}
	tokenInvalid          = Token{Tok: tokInvalid}
	tokenLe               = Token{Tok: tokLe}
	tokenLt               = Token{Tok: tokLt}
	tokenMinus            = Token{Tok: tokMinus}
	tokenMul              = Token{Tok: tokMul}
	tokenOpenParenthesis  = Token{Tok: tokOpenParenthesis}
	tokenPeriod           = Token{Tok: tokPeriod}
	tokenPlus             = Token{Tok: tokPlus}
)

var (
	mappedToken = map[rune]Token{
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

func lex(raw string) []Token {
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

		case isHeadIdentifier(r):
			lexeme, curr = eatWhile(isTailIdentifier, rs, curr+1, total)
			toks = append(toks, Token{
				Tok:    tokIdentifier,
				Lexeme: string(r) + lexeme,
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

func isHeadIdentifier(r rune) bool {
	return unicode.IsLetter(r) || r == underscore
}

func isTailIdentifier(r rune) bool {
	return isHeadIdentifier(r) || unicode.IsNumber(r)
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
