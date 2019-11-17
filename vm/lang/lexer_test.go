package lang

import "testing"

func assertTokensEq(t *testing.T, returned, expected []token) {
	t.Helper()

	if len(returned) != len(expected) {
		t.Errorf(`missmatched length:\n
returned: (len=%v) %v
expected: (len=%v) %v`, len(returned), returned, len(expected), expected)
		return
	}

	for i := range returned {
		if !returned[i].eq(expected[i]) {
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
		expected []token
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
			expected: []token{tokenOpenParen, tokenCloseParen},
		},
		{
			label:    "quoted list",
			input:    `'()`,
			expected: []token{tokenQuote, tokenOpenParen, tokenCloseParen},
		},
		{
			label:    "string",
			input:    `"hi there, how are you today?"`,
			expected: []token{tokenString([]rune("hi there, how are you today?"))},
		},
		{
			label: "strings",
			input: `"hi there" "how are you today?"`,
			expected: []token{
				tokenString([]rune("hi there")),
				tokenString([]rune("how are you today?")),
			},
		},
		{
			label:    "number",
			input:    `123`,
			expected: []token{tokenNumber([]rune("123"))},
		},
		{
			label: "numbers",
			input: `1 2 3 456`,
			expected: []token{
				tokenNumber([]rune("1")),
				tokenNumber([]rune("2")),
				tokenNumber([]rune("3")),
				tokenNumber([]rune("456")),
			},
		},
		{
			label:    "word",
			input:    `one`,
			expected: []token{tokenWord([]rune("one"))},
		},
		{
			label: "words",
			input: `one two? three-four+five*six!`,
			expected: []token{
				tokenWord([]rune("one")),
				tokenWord([]rune("two?")),
				tokenWord([]rune("three-four+five*six!")),
			},
		},
		{
			label: "everything",
			input: `	 (+1 21 twenty_two)`,
			expected: []token{
				tokenOpenParen,
				tokenWord([]rune("+1")),
				tokenNumber([]rune("21")),
				tokenWord([]rune("twenty_two")),
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
