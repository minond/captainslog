package lang

import (
	"unicode"
)

type kind uint8

const (
	kindInvalid kind = iota
	kindOpenParen
	kindCloseParen
	kindQuote
	kindString
	kindNumber
	kindWord
)

type token struct {
	kind   kind
	lexeme []rune
}

func (t token) eqv(o token) bool {
	return t.kind == o.kind
}

func (t token) eq(o token) bool {
	return t.eqv(o) && string(t.lexeme) == string(o.lexeme)
}

var (
	tokenOpenParen  = token{kind: kindOpenParen}
	tokenCloseParen = token{kind: kindCloseParen}
	tokenQuote      = token{kind: kindQuote}
)

func tokenString(lexeme []rune) token {
	return token{
		kind:   kindString,
		lexeme: lexeme,
	}
}

func tokenNumber(lexeme []rune) token {
	return token{
		kind:   kindNumber,
		lexeme: lexeme,
	}
}

func tokenWord(lexeme []rune) token {
	return token{
		kind:   kindWord,
		lexeme: lexeme,
	}
}

func lex(text string) []token {
	var buff []token

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
		case unicode.IsNumber(curr):
			lexeme, size := eatUntil(chars, pos, max, not(unicode.IsNumber))
			pos += size - 1
			buff = append(buff, tokenNumber(lexeme))
		case isIdentifier(curr):
			lexeme, size := eatUntil(chars, pos, max, not(isIdentifier))
			pos += size - 1
			buff = append(buff, tokenWord(lexeme))
		default:
			buff = append(buff, token{
				kind:   kindInvalid,
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
