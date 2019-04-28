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
		if !got[i].Eq(expecting[i]) {
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
	toks := Lex(`
										`)
	if len(toks) != 0 {
		t.Error("expected spaces to be skipped")
	}
}

func TestLexer_Symbols(t *testing.T) {
	got := Lex(`(),. < > = <= >= + - * /`)
	expecting := []Token{
		TokenOpenParenthesis,
		TokenCloseParenthesis,
		TokenComma,
		TokenPeriod,
		TokenLt,
		TokenGt,
		TokenEq,
		TokenLe,
		TokenGe,
		TokenPlus,
		TokenMinus,
		TokenMul,
		TokenDiv,
	}
	if !tokseq(expecting, got) {
		t.Errorf(compmsg("lexing symbols did not return expected tokens.",
			expecting, got))
	}
}

func TestLexer_Identifiers(t *testing.T) {
	got := Lex(`one two_three four__ __five`)
	expecting := []Token{
		Token{Tok: tokIdentifier, Lexeme: "one"},
		Token{Tok: tokIdentifier, Lexeme: "two_three"},
		Token{Tok: tokIdentifier, Lexeme: "four__"},
		Token{Tok: tokIdentifier, Lexeme: "__five"},
	}
	if !tokseq(expecting, got) {
		t.Errorf(compmsg("lexing identifiers did not return expected tokens.",
			expecting, got))
	}
}

func TestLexer_Numbers(t *testing.T) {
	got := Lex(`1 23 4 5`)
	expecting := []Token{
		Token{Tok: tokNumber, Lexeme: "1"},
		Token{Tok: tokNumber, Lexeme: "23"},
		Token{Tok: tokNumber, Lexeme: "4"},
		Token{Tok: tokNumber, Lexeme: "5"},
	}
	if !tokseq(expecting, got) {
		t.Errorf(compmsg("lexing numbers did not return expected tokens.",
			expecting, got))
	}
}

func TestLexer_QuotedValues(t *testing.T) {
	got := Lex(`'' 'one' 'two three' "four" "" "five six"`)
	expecting := []Token{
		Token{Tok: tokSingleQuoteString, Lexeme: ""},
		Token{Tok: tokSingleQuoteString, Lexeme: "one"},
		Token{Tok: tokSingleQuoteString, Lexeme: "two three"},
		Token{Tok: tokDoubleQuoteString, Lexeme: "four"},
		Token{Tok: tokDoubleQuoteString, Lexeme: ""},
		Token{Tok: tokDoubleQuoteString, Lexeme: "five six"},
	}
	if !tokseq(expecting, got) {
		t.Errorf(compmsg("lexing quoted values did not return expected tokens.",
			expecting, got))
	}
}

func TestLexer_SampleQuery(t *testing.T) {
	got := Lex(`

select max(w.weight) as max_weight,
	max(min(w.weight)) as min_max_weight,
	distinct w.exercise,
	w.weight
from workouts as w
where w.exercise like 'bench press' or w.exercise like 'bicep curl'

`)

	expecting := []Token{
		Token{Tok: tokIdentifier, Lexeme: "select"},
		Token{Tok: tokIdentifier, Lexeme: "max"},
		TokenOpenParenthesis,
		Token{Tok: tokIdentifier, Lexeme: "w"},
		TokenPeriod,
		Token{Tok: tokIdentifier, Lexeme: "weight"},
		TokenCloseParenthesis,
		Token{Tok: tokIdentifier, Lexeme: "as"},
		Token{Tok: tokIdentifier, Lexeme: "max_weight"},
		TokenComma,
		Token{Tok: tokIdentifier, Lexeme: "max"},
		TokenOpenParenthesis,
		Token{Tok: tokIdentifier, Lexeme: "min"},
		TokenOpenParenthesis,
		Token{Tok: tokIdentifier, Lexeme: "w"},
		TokenPeriod,
		Token{Tok: tokIdentifier, Lexeme: "weight"},
		TokenCloseParenthesis,
		TokenCloseParenthesis,
		Token{Tok: tokIdentifier, Lexeme: "as"},
		Token{Tok: tokIdentifier, Lexeme: "min_max_weight"},
		TokenComma,
		Token{Tok: tokIdentifier, Lexeme: "distinct"},
		Token{Tok: tokIdentifier, Lexeme: "w"},
		TokenPeriod,
		Token{Tok: tokIdentifier, Lexeme: "exercise"},
		TokenComma,
		Token{Tok: tokIdentifier, Lexeme: "w"},
		TokenPeriod,
		Token{Tok: tokIdentifier, Lexeme: "weight"},
		Token{Tok: tokIdentifier, Lexeme: "from"},
		Token{Tok: tokIdentifier, Lexeme: "workouts"},
		Token{Tok: tokIdentifier, Lexeme: "as"},
		Token{Tok: tokIdentifier, Lexeme: "w"},
		Token{Tok: tokIdentifier, Lexeme: "where"},
		Token{Tok: tokIdentifier, Lexeme: "w"},
		TokenPeriod,
		Token{Tok: tokIdentifier, Lexeme: "exercise"},
		Token{Tok: tokIdentifier, Lexeme: "like"},
		Token{Tok: tokSingleQuoteString, Lexeme: "bench press"},
		Token{Tok: tokIdentifier, Lexeme: "or"},
		Token{Tok: tokIdentifier, Lexeme: "w"},
		TokenPeriod,
		Token{Tok: tokIdentifier, Lexeme: "exercise"},
		Token{Tok: tokIdentifier, Lexeme: "like"},
		Token{Tok: tokSingleQuoteString, Lexeme: "bicep curl"},
	}
	if !tokseq(expecting, got) {
		t.Errorf(compmsg("lexing sample query did not return expected tokens.",
			expecting, got))
	}
}
