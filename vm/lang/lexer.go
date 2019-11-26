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
	offset int
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

func buildTokenOpenParen(offset int) Token {
	return Token{
		tok:    tokenOpenParen.tok,
		lexeme: tokenOpenParen.lexeme,
		offset: offset,
	}
}

func buildTokenCloseParen(offset int) Token {
	return Token{
		tok:    tokenCloseParen.tok,
		lexeme: tokenCloseParen.lexeme,
		offset: offset,
	}
}

func buildTokenQuote(offset int) Token {
	return Token{
		tok:    tokenQuote.tok,
		lexeme: tokenQuote.lexeme,
		offset: offset,
	}
}

func buildTokenString(lexeme []rune, offset int) Token {
	return Token{
		tok:    tokString,
		lexeme: lexeme,
		offset: offset,
	}
}

func buildTokenBoolean(lexeme []rune, offset int) Token {
	return Token{
		tok:    tokBoolean,
		lexeme: lexeme,
		offset: offset,
	}
}

func buildTokenNumber(lexeme []rune, offset int) Token {
	return Token{
		tok:    tokNumber,
		lexeme: lexeme,
		offset: offset,
	}
}

func buildTokenWord(lexeme []rune, offset int) Token {
	return Token{
		tok:    tokWord,
		lexeme: lexeme,
		offset: offset,
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
			buff = append(buff, buildTokenOpenParen(pos))
		case curr == ')':
			buff = append(buff, buildTokenCloseParen(pos))
		case curr == '\'':
			buff = append(buff, buildTokenQuote(pos))
		case curr == '"':
			lexeme, size := eatUntil(chars, pos+1, max, is('"'))
			buff = append(buff, buildTokenString(lexeme, pos))
			pos += size + 1
		case curr == '#':
			lexeme, size := eatUntil(chars, pos+1, max, unicode.IsSpace)
			buff = append(buff, buildTokenBoolean(append([]rune{curr}, lexeme...), pos))
			pos += size + 1
		case unicode.IsNumber(curr):
			lexeme, size := eatUntil(chars, pos, max, not(or(unicode.IsNumber, is('.'))))
			buff = append(buff, buildTokenNumber(lexeme, pos))
			pos += size - 1
		case isIdentifier(curr):
			lexeme, size := eatUntil(chars, pos, max, not(isIdentifier))
			buff = append(buff, buildTokenWord(lexeme, pos))
			pos += size - 1
		default:
			buff = append(buff, Token{
				tok:    tokInvalid,
				lexeme: []rune{curr},
				offset: pos,
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

func or(preds ...predicate) predicate {
	return func(r rune) bool {
		for _, pred := range preds {
			if pred(r) {
				return true
			}
		}
		return false
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
