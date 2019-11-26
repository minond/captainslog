package lang

import "testing"

func assertTokensEq(t *testing.T, returned, expected []Token) {
	t.Helper()

	if len(returned) != len(expected) {
		t.Errorf(`missmatched length:\n
returned: (len=%v) %v
expected: (len=%v) %v`, len(returned), returned, len(expected), expected)
		return
	}

	for i := range returned {
		if !returned[i].Eq(expected[i]) {
			t.Errorf(`missmatched token:\n
returned: (index=%v) %v
expected: (index=%v) %v`, i, returned, i, expected)
		}
	}
}

func TestLexer(t *testing.T) {
	var tests = []struct {
		label    string
		input    string
		expected []Token
	}{
		{
			label:    "empty string",
			input:    ``,
			expected: nil,
		},
		{
			label: "whitespace",
			input: `					      `,
			expected: nil,
		},
		{
			label:    "open and close paren",
			input:    `()`,
			expected: []Token{tokenOpenParen, tokenCloseParen},
		},
		{
			label:    "quoted list",
			input:    `'()`,
			expected: []Token{tokenQuote, tokenOpenParen, tokenCloseParen},
		},
		{
			label:    "string",
			input:    `"hi there, how are you today?"`,
			expected: []Token{tokenString([]rune("hi there, how are you today?"))},
		},
		{
			label: "strings",
			input: `"hi there" "how are you today?"`,
			expected: []Token{
				tokenString([]rune("hi there")),
				tokenString([]rune("how are you today?")),
			},
		},
		{
			label:    "boolean",
			input:    `#f`,
			expected: []Token{tokenBoolean([]rune("#f"))},
		},
		{
			label: "booleans",
			input: `#f #t #t #f`,
			expected: []Token{
				tokenBoolean([]rune("#f")),
				tokenBoolean([]rune("#t")),
				tokenBoolean([]rune("#t")),
				tokenBoolean([]rune("#f")),
			},
		},
		{
			label:    "number",
			input:    `123`,
			expected: []Token{tokenNumber([]rune("123"))},
		},
		{
			label: "numbers",
			input: `1 2 3 456 0.1 432432.432342432`,
			expected: []Token{
				tokenNumber([]rune("1")),
				tokenNumber([]rune("2")),
				tokenNumber([]rune("3")),
				tokenNumber([]rune("456")),
				tokenNumber([]rune("0.1")),
				tokenNumber([]rune("432432.432342432")),
			},
		},
		{
			label:    "word",
			input:    `one`,
			expected: []Token{tokenWord([]rune("one"))},
		},
		{
			label: "words",
			input: `one two? three-four+five*six!`,
			expected: []Token{
				tokenWord([]rune("one")),
				tokenWord([]rune("two?")),
				tokenWord([]rune("three-four+five*six!")),
			},
		},
		{
			label: "everything",
			input: `	 (+1 21 twenty_two #f abc#abc)`,
			expected: []Token{
				tokenOpenParen,
				tokenWord([]rune("+1")),
				tokenNumber([]rune("21")),
				tokenWord([]rune("twenty_two")),
				tokenBoolean([]rune("#f")),
				tokenWord([]rune("abc#abc")),
				tokenCloseParen,
			},
		},
	}

	for _, test := range tests {
		t.Run(test.label, func(t *testing.T) {
			assertTokensEq(t, lex(test.input), test.expected)
		})
	}
}
