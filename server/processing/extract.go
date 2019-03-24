package processing

import (
	"regexp"

	"github.com/minond/captainslog/server/model"
)

func Extract(text string, extractors []*model.Extractor) (map[string]string, error) {
	data := make(map[string]string)

	for _, extractor := range extractors {
		reg, err := regexp.Compile(extractor.Match)
		if err != nil {
			return nil, err
		}

		matches := reg.FindStringSubmatch(text)
		if len(matches) > 1 {
			data[extractor.Label] = matches[1]
		}
	}

	return data, nil
}
