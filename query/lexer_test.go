package query

import (
	"fmt"
	"testing"
)

func tokseq(expecting, got []token) bool {
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

func compmsg(msg string, expecting, got []token) string {
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
	expecting := []token{
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
	got := lex(`one two_three four__ __five`)
	expecting := []token{
		{tok: tokIdentifier, lexeme: "one"},
		{tok: tokIdentifier, lexeme: "two_three"},
		{tok: tokIdentifier, lexeme: "four__"},
		{tok: tokIdentifier, lexeme: "__five"},
	}
	if !tokseq(expecting, got) {
		t.Errorf(compmsg("lexing identifiers did not return expected tokens.",
			expecting, got))
	}
}

func TestLexer_Numbers(t *testing.T) {
	got := lex(`1 23 4 5`)
	expecting := []token{
		{tok: tokNumber, lexeme: "1"},
		{tok: tokNumber, lexeme: "23"},
		{tok: tokNumber, lexeme: "4"},
		{tok: tokNumber, lexeme: "5"},
	}
	if !tokseq(expecting, got) {
		t.Errorf(compmsg("lexing numbers did not return expected tokens.",
			expecting, got))
	}
}

func TestLexer_QuotedValues(t *testing.T) {
	got := lex(`'' 'one' 'two three' "four" "" "five six"`)
	expecting := []token{
		{tok: tokSingleQuoteString, lexeme: ""},
		{tok: tokSingleQuoteString, lexeme: "one"},
		{tok: tokSingleQuoteString, lexeme: "two three"},
		{tok: tokDoubleQuoteString, lexeme: "four"},
		{tok: tokDoubleQuoteString, lexeme: ""},
		{tok: tokDoubleQuoteString, lexeme: "five six"},
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

	expecting := []token{
		{tok: tokIdentifier, lexeme: "select"},
		{tok: tokIdentifier, lexeme: "max"},
		tokenOpenParenthesis,
		{tok: tokIdentifier, lexeme: "w"},
		tokenPeriod,
		{tok: tokIdentifier, lexeme: "weight"},
		tokenCloseParenthesis,
		{tok: tokIdentifier, lexeme: "as"},
		{tok: tokIdentifier, lexeme: "max_weight"},
		tokenComma,
		{tok: tokIdentifier, lexeme: "max"},
		tokenOpenParenthesis,
		{tok: tokIdentifier, lexeme: "min"},
		tokenOpenParenthesis,
		{tok: tokIdentifier, lexeme: "w"},
		tokenPeriod,
		{tok: tokIdentifier, lexeme: "weight"},
		tokenCloseParenthesis,
		tokenCloseParenthesis,
		{tok: tokIdentifier, lexeme: "as"},
		{tok: tokIdentifier, lexeme: "min_max_weight"},
		tokenComma,
		{tok: tokIdentifier, lexeme: "distinct"},
		{tok: tokIdentifier, lexeme: "w"},
		tokenPeriod,
		{tok: tokIdentifier, lexeme: "exercise"},
		tokenComma,
		{tok: tokIdentifier, lexeme: "w"},
		tokenPeriod,
		{tok: tokIdentifier, lexeme: "weight"},
		{tok: tokIdentifier, lexeme: "from"},
		{tok: tokIdentifier, lexeme: "workouts"},
		{tok: tokIdentifier, lexeme: "as"},
		{tok: tokIdentifier, lexeme: "w"},
		{tok: tokIdentifier, lexeme: "where"},
		{tok: tokIdentifier, lexeme: "w"},
		tokenPeriod,
		{tok: tokIdentifier, lexeme: "exercise"},
		{tok: tokIdentifier, lexeme: "like"},
		{tok: tokSingleQuoteString, lexeme: "bench press"},
		{tok: tokIdentifier, lexeme: "or"},
		{tok: tokIdentifier, lexeme: "w"},
		tokenPeriod,
		{tok: tokIdentifier, lexeme: "exercise"},
		{tok: tokIdentifier, lexeme: "like"},
		{tok: tokSingleQuoteString, lexeme: "bicep curl"},
	}
	if !tokseq(expecting, got) {
		t.Errorf(compmsg("lexing sample query did not return expected tokens.",
			expecting, got))
	}
}
