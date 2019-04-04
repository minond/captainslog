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
		switch {
		// This handles rule #1
		case shorthand.Text != nil && shorthand.Match == nil:
			text = strings.Replace(text, *shorthand.Text, shorthand.Expansion, -1)

		// This handles rule #2
		case shorthand.Text != nil && shorthand.Match != nil:
			reg, err := regexp.Compile(*shorthand.Match)
			if err != nil {
				return text, err
			} else if reg.MatchString(text) {
				text = strings.Replace(text, *shorthand.Text, shorthand.Expansion, -1)
			}

			text = reg.ReplaceAllString(text, shorthand.Expansion)

		// This handles rule #3
		case shorthand.Text == nil && shorthand.Match != nil:
			reg, err := regexp.Compile(*shorthand.Match)
			if err != nil {
				return text, err
			}

			text = reg.ReplaceAllString(text, shorthand.Expansion)

		// This handles rule #4
		default:
			return text, fmt.Errorf("shorthand with guid `%s` is missing text and match", shorthand.GUID)
		}

	}

	return text, nil
}
