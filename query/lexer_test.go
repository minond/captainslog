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
		token{tok: tokIdentifier, lexeme: "one"},
		token{tok: tokIdentifier, lexeme: "two_three"},
		token{tok: tokIdentifier, lexeme: "four__"},
		token{tok: tokIdentifier, lexeme: "__five"},
	}
	if !tokseq(expecting, got) {
		t.Errorf(compmsg("lexing identifiers did not return expected tokens.",
			expecting, got))
	}
}

func TestLexer_Numbers(t *testing.T) {
	got := lex(`1 23 4 5`)
	expecting := []token{
		token{tok: tokNumber, lexeme: "1"},
		token{tok: tokNumber, lexeme: "23"},
		token{tok: tokNumber, lexeme: "4"},
		token{tok: tokNumber, lexeme: "5"},
	}
	if !tokseq(expecting, got) {
		t.Errorf(compmsg("lexing numbers did not return expected tokens.",
			expecting, got))
	}
}

func TestLexer_QuotedValues(t *testing.T) {
	got := lex(`'' 'one' 'two three' "four" "" "five six"`)
	expecting := []token{
		token{tok: tokSingleQuoteString, lexeme: ""},
		token{tok: tokSingleQuoteString, lexeme: "one"},
		token{tok: tokSingleQuoteString, lexeme: "two three"},
		token{tok: tokDoubleQuoteString, lexeme: "four"},
		token{tok: tokDoubleQuoteString, lexeme: ""},
		token{tok: tokDoubleQuoteString, lexeme: "five six"},
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
		token{tok: tokIdentifier, lexeme: "select"},
		token{tok: tokIdentifier, lexeme: "max"},
		tokenOpenParenthesis,
		token{tok: tokIdentifier, lexeme: "w"},
		tokenPeriod,
		token{tok: tokIdentifier, lexeme: "weight"},
		tokenCloseParenthesis,
		token{tok: tokIdentifier, lexeme: "as"},
		token{tok: tokIdentifier, lexeme: "max_weight"},
		tokenComma,
		token{tok: tokIdentifier, lexeme: "max"},
		tokenOpenParenthesis,
		token{tok: tokIdentifier, lexeme: "min"},
		tokenOpenParenthesis,
		token{tok: tokIdentifier, lexeme: "w"},
		tokenPeriod,
		token{tok: tokIdentifier, lexeme: "weight"},
		tokenCloseParenthesis,
		tokenCloseParenthesis,
		token{tok: tokIdentifier, lexeme: "as"},
		token{tok: tokIdentifier, lexeme: "min_max_weight"},
		tokenComma,
		token{tok: tokIdentifier, lexeme: "distinct"},
		token{tok: tokIdentifier, lexeme: "w"},
		tokenPeriod,
		token{tok: tokIdentifier, lexeme: "exercise"},
		tokenComma,
		token{tok: tokIdentifier, lexeme: "w"},
		tokenPeriod,
		token{tok: tokIdentifier, lexeme: "weight"},
		token{tok: tokIdentifier, lexeme: "from"},
		token{tok: tokIdentifier, lexeme: "workouts"},
		token{tok: tokIdentifier, lexeme: "as"},
		token{tok: tokIdentifier, lexeme: "w"},
		token{tok: tokIdentifier, lexeme: "where"},
		token{tok: tokIdentifier, lexeme: "w"},
		tokenPeriod,
		token{tok: tokIdentifier, lexeme: "exercise"},
		token{tok: tokIdentifier, lexeme: "like"},
		token{tok: tokSingleQuoteString, lexeme: "bench press"},
		token{tok: tokIdentifier, lexeme: "or"},
		token{tok: tokIdentifier, lexeme: "w"},
		tokenPeriod,
		token{tok: tokIdentifier, lexeme: "exercise"},
		token{tok: tokIdentifier, lexeme: "like"},
		token{tok: tokSingleQuoteString, lexeme: "bicep curl"},
	}
	if !tokseq(expecting, got) {
		t.Errorf(compmsg("lexing sample query did not return expected tokens.",
			expecting, got))
	}
}
