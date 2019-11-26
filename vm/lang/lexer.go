package lang

import (
	"unicode"
)

type tok uint8

const (
	tokInvalid tok = iota
	tokOpenParen
	tokCloseParen
	tokQuote
	tokString
	tokNumber
	tokWord
	tokBoolean
)

type Token struct {
	tok    tok
	lexeme []rune
}

func (t Token) IsA(o tok) bool {
	return t.tok == o
}

func (t Token) Eqv(o Token) bool {
	return t.tok == o.tok
}

func (t Token) Eq(o Token) bool {
	return t.Eqv(o) && string(t.lexeme) == string(o.lexeme)
}

var (
	tokenOpenParen  = Token{tok: tokOpenParen}
	tokenCloseParen = Token{tok: tokCloseParen}
	tokenQuote      = Token{tok: tokQuote}
)

func tokenString(lexeme []rune) Token {
	return Token{
		tok:    tokString,
		lexeme: lexeme,
	}
}

func tokenBoolean(lexeme []rune) Token {
	return Token{
		tok:    tokBoolean,
		lexeme: lexeme,
	}
}

func tokenNumber(lexeme []rune) Token {
	return Token{
		tok:    tokNumber,
		lexeme: lexeme,
	}
}

func tokenWord(lexeme []rune) Token {
	return Token{
		tok:    tokWord,
		lexeme: lexeme,
	}
}

func lex(text string) []Token {
	var buff []Token

	chars := []rune(text)
	max := len(chars)
	pos := 0

	for ; pos < max; pos++ {
		curr := chars[pos]
		switch {
		case unicode.IsSpace(curr):
		case curr == '(':
			buff = append(buff, tokenOpenParen)
		case curr == ')':
			buff = append(buff, tokenCloseParen)
		case curr == '\'':
			buff = append(buff, tokenQuote)
		case curr == '"':
			lexeme, size := eatUntil(chars, pos+1, max, is('"'))
			pos += size + 1
			buff = append(buff, tokenString(lexeme))
		case curr == '#':
			lexeme, size := eatUntil(chars, pos+1, max, unicode.IsSpace)
			pos += size + 1
			buff = append(buff, tokenBoolean(append([]rune{curr}, lexeme...)))
		case unicode.IsNumber(curr):
			lexeme, size := eatUntil(chars, pos, max, not(unicode.IsNumber))
			pos += size - 1
			buff = append(buff, tokenNumber(lexeme))
		case isIdentifier(curr):
			lexeme, size := eatUntil(chars, pos, max, not(isIdentifier))
			pos += size - 1
			buff = append(buff, tokenWord(lexeme))
		default:
			buff = append(buff, Token{
				tok:    tokInvalid,
				lexeme: []rune{curr},
			})
		}
	}

	return buff
}

type predicate func(rune) bool

func is(c rune) predicate {
	return func(r rune) bool {
		return r == c
	}
}

func not(pred predicate) predicate {
	return func(r rune) bool {
		return !pred(r)
	}
}

func eatUntil(chars []rune, pos, max int, pred predicate) ([]rune, int) {
	var buff []rune
	start := pos

	for ; pos < max; pos++ {
		curr := chars[pos]

		if pred(curr) {
			break
		}

		buff = append(buff, curr)
	}

	return buff, pos - start
}

func isIdentifier(c rune) bool {
	return !unicode.IsSpace(c) &&
		c != '(' &&
		c != ')'
}
