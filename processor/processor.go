package main

import (
	"errors"
	"fmt"
	"regexp"
	"strconv"
	"strings"
)

type Processor interface {
	Process(string, []Shorthand, []Extractor) (string, map[string]interface{}, error)
}

type processor struct{}

func NewProcessor() Processor {
	return processor{}
}

func (p processor) Process(orig string, shorthands []Shorthand, extractors []Extractor) (string, map[string]interface{}, error) {
	text, err := p.Expand(orig, shorthands)
	if err != nil {
		return text, nil, err
	}

	data, err := p.Extract(text, extractors)
	return text, data, err
}

func (processor) Extract(text string, extractors []Extractor) (map[string]interface{}, error) {
	data := make(map[string]interface{})

	for _, extractor := range extractors {
		if extractor.Match == "" {
			continue
		}

		reg, err := regexp.Compile(extractor.Match)
		if err != nil {
			return nil, err
		}

		matches := reg.FindStringSubmatch(text)
		if len(matches) > 1 {
			switch extractor.DataType {
			case BooleanData:
				data[extractor.Label] = true

			case NumberData:
				n, err := strconv.ParseFloat(matches[1], 32)
				if err != nil {
					return nil, fmt.Errorf("unable to convert `%s` to a number value fo %s extractor",
						matches[1], extractor.Label)
				}
				data[extractor.Label] = float32(n)

			case StringData:
				fallthrough
			default:
				data[extractor.Label] = matches[1]
			}
		}
	}

	return data, nil
}

// Expand expands a string of text using shorthands. The rules for expansion
// are taken from what is defined in the documentation for the Shorthand model.
func (processor) Expand(text string, shorthands []Shorthand) (string, error) {
	for _, shorthand := range shorthands {
		validText := shorthand.Text != nil
		validMatch := shorthand.Match != nil

		switch {
		// Handles rule #1 as defined in the documentation for model.Shorthand.
		case validText && !validMatch:
			text = strings.Replace(text, *shorthand.Text, shorthand.Expansion, -1)

		// Handles rule #2 as defined in the documentation for model.Shorthand.
		case validText && validMatch:
			reg, err := regexp.Compile(*shorthand.Match)
			if err != nil {
				return text, err
			} else if reg.MatchString(text) {
				text = strings.Replace(text, *shorthand.Text, shorthand.Expansion, -1)
			}

		// Handles rule #3 as defined in the documentation for model.Shorthand.
		case !validText && validMatch:
			reg, err := regexp.Compile(*shorthand.Match)
			if err != nil {
				return text, err
			}

			text = reg.ReplaceAllString(text, shorthand.Expansion)

		// Handles rule #4 as defined in the documentation for model.Shorthand.
		default:
			return text, errors.New("bad shorthand")
		}

	}

	return text, nil
}
