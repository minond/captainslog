package query

import (
	"fmt"
	"testing"
)

func tokseq(expecting, got []Token) bool {
	if len(got) != len(expecting) {
		return false
	}
	for i := range got {
		if !got[i].eq(expecting[i]) {
			return false
		}
	}
	return true
}

func compmsg(msg string, expecting, got []Token) string {
	return fmt.Sprintf(`%s

		expecting: %s

		      got: %s`, msg, expecting, got)
}

func TestLexer_SkipSpaces(t *testing.T) {
	toks := lex(`
										`)
	if len(toks) != 0 {
		t.Error("expected spaces to be skipped")
	}
}

func TestLexer_Symbols(t *testing.T) {
	got := lex(`(),. < > = <= >= + - * /`)
	expecting := []Token{
		tokenOpenParenthesis,
		tokenCloseParenthesis,
		tokenComma,
		tokenPeriod,
		tokenLt,
		tokenGt,
		tokenEq,
		tokenLe,
		tokenGe,
		tokenPlus,
		tokenMinus,
		tokenMul,
		tokenDiv,
	}
	if !tokseq(expecting, got) {
		t.Errorf(compmsg("lexing symbols did not return expected tokens.",
			expecting, got))
	}
}

func TestLexer_Identifiers(t *testing.T) {
	got := lex(`one two_three four__ __five six6`)
	expecting := []Token{
		{Tok: tokIdentifier, Lexeme: "one"},
		{Tok: tokIdentifier, Lexeme: "two_three"},
		{Tok: tokIdentifier, Lexeme: "four__"},
		{Tok: tokIdentifier, Lexeme: "__five"},
		{Tok: tokIdentifier, Lexeme: "six6"},
	}
	if !tokseq(expecting, got) {
		t.Errorf(compmsg("lexing identifiers did not return expected tokens.",
			expecting, got))
	}
}

func TestLexer_Numbers(t *testing.T) {
	got := lex(`1 23 4 5`)
	expecting := []Token{
		{Tok: tokNumber, Lexeme: "1"},
		{Tok: tokNumber, Lexeme: "23"},
		{Tok: tokNumber, Lexeme: "4"},
		{Tok: tokNumber, Lexeme: "5"},
	}
	if !tokseq(expecting, got) {
		t.Errorf(compmsg("lexing numbers did not return expected tokens.",
			expecting, got))
	}
}

func TestLexer_QuotedValues(t *testing.T) {
	got := lex(`'' 'one' 'two three' "four" "" "five six"`)
	expecting := []Token{
		{Tok: tokSingleQuoteString, Lexeme: ""},
		{Tok: tokSingleQuoteString, Lexeme: "one"},
		{Tok: tokSingleQuoteString, Lexeme: "two three"},
		{Tok: tokDoubleQuoteString, Lexeme: "four"},
		{Tok: tokDoubleQuoteString, Lexeme: ""},
		{Tok: tokDoubleQuoteString, Lexeme: "five six"},
	}
	if !tokseq(expecting, got) {
		t.Errorf(compmsg("lexing quoted values did not return expected tokens.",
			expecting, got))
	}
}

func TestLexer_SampleQuery(t *testing.T) {
	got := lex(`

select max(w.weight) as max_weight,
	max(min(w.weight)) as min_max_weight,
	distinct w.exercise,
	w.weight
from workouts as w
where w.exercise like 'bench press' or w.exercise like 'bicep curl'

`)

	expecting := []Token{
		{Tok: tokIdentifier, Lexeme: "select"},
		{Tok: tokIdentifier, Lexeme: "max"},
		tokenOpenParenthesis,
		{Tok: tokIdentifier, Lexeme: "w"},
		tokenPeriod,
		{Tok: tokIdentifier, Lexeme: "weight"},
		tokenCloseParenthesis,
		{Tok: tokIdentifier, Lexeme: "as"},
		{Tok: tokIdentifier, Lexeme: "max_weight"},
		tokenComma,
		{Tok: tokIdentifier, Lexeme: "max"},
		tokenOpenParenthesis,
		{Tok: tokIdentifier, Lexeme: "min"},
		tokenOpenParenthesis,
		{Tok: tokIdentifier, Lexeme: "w"},
		tokenPeriod,
		{Tok: tokIdentifier, Lexeme: "weight"},
		tokenCloseParenthesis,
		tokenCloseParenthesis,
		{Tok: tokIdentifier, Lexeme: "as"},
		{Tok: tokIdentifier, Lexeme: "min_max_weight"},
		tokenComma,
		{Tok: tokIdentifier, Lexeme: "distinct"},
		{Tok: tokIdentifier, Lexeme: "w"},
		tokenPeriod,
		{Tok: tokIdentifier, Lexeme: "exercise"},
		tokenComma,
		{Tok: tokIdentifier, Lexeme: "w"},
		tokenPeriod,
		{Tok: tokIdentifier, Lexeme: "weight"},
		{Tok: tokIdentifier, Lexeme: "from"},
		{Tok: tokIdentifier, Lexeme: "workouts"},
		{Tok: tokIdentifier, Lexeme: "as"},
		{Tok: tokIdentifier, Lexeme: "w"},
		{Tok: tokIdentifier, Lexeme: "where"},
		{Tok: tokIdentifier, Lexeme: "w"},
		tokenPeriod,
		{Tok: tokIdentifier, Lexeme: "exercise"},
		{Tok: tokIdentifier, Lexeme: "like"},
		{Tok: tokSingleQuoteString, Lexeme: "bench press"},
		{Tok: tokIdentifier, Lexeme: "or"},
		{Tok: tokIdentifier, Lexeme: "w"},
		tokenPeriod,
		{Tok: tokIdentifier, Lexeme: "exercise"},
		{Tok: tokIdentifier, Lexeme: "like"},
		{Tok: tokSingleQuoteString, Lexeme: "bicep curl"},
	}
	if !tokseq(expecting, got) {
		t.Errorf(compmsg("lexing sample query did not return expected tokens.",
			expecting, got))
	}
}
