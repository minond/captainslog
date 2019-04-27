package processing

import (
	"fmt"
	"regexp"
	"strconv"

	"github.com/minond/captainslog/model"
)

func Extract(text string, extractors []*model.Extractor) (map[string]interface{}, error) {
	data := make(map[string]interface{})

	for _, extractor := range extractors {
		reg, err := regexp.Compile(extractor.Match)
		if err != nil {
			return nil, err
		}

		matches := reg.FindStringSubmatch(text)
		if len(matches) > 1 {
			switch extractor.Type {
			case model.BooleanData:
				data[extractor.Label] = true

			case model.NumberData:
				n, err := strconv.ParseFloat(matches[1], 32)
				if err != nil {
					return nil, fmt.Errorf("unable to convert `%s` to a number value fo %s extractor",
						matches[1], extractor.Label)
				}
				data[extractor.Label] = float32(n)

			case model.StringData:
				fallthrough
			default:
				data[extractor.Label] = matches[1]
			}
		}
	}

	return data, nil
}
