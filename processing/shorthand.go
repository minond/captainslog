package processing

import (
	"fmt"
	"regexp"
	"strings"

	"github.com/minond/captainslog/model"
)

// Expand expands a string of text using shorthands. The rules for expansion
// are taken from what is defined in the documentation for the Shorthand model.
func Expand(text string, shorthands []*model.Shorthand) (string, error) {
	for _, shorthand := range shorthands {
		validText := shorthand.Text != nil && shorthand.Text.Valid
		validMatch := shorthand.Match != nil && shorthand.Match.Valid

		switch {
		// Handles rule #1 as defined in the documentation for model.Shorthand.
		case validText && !validMatch:
			text = strings.Replace(text, shorthand.Text.String, shorthand.Expansion, -1)

		// Handles rule #2 as defined in the documentation for model.Shorthand.
		case validText && validMatch:
			reg, err := regexp.Compile(shorthand.Match.String)
			if err != nil {
				return text, err
			} else if reg.MatchString(text) {
				text = strings.Replace(text, shorthand.Text.String, shorthand.Expansion, -1)
			}

			text = reg.ReplaceAllString(text, shorthand.Expansion)

		// Handles rule #3 as defined in the documentation for model.Shorthand.
		case !validText && validMatch:
			reg, err := regexp.Compile(shorthand.Match.String)
			if err != nil {
				return text, err
			}

			text = reg.ReplaceAllString(text, shorthand.Expansion)

		// Handles rule #4 as defined in the documentation for model.Shorthand.
		default:
			return text, fmt.Errorf("shorthand with guid `%s` is missing text and match", shorthand.GUID)
		}

	}

	return text, nil
}
