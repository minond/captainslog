package processing

import "github.com/minond/captainslog/model"

func Process(orig string, shorthands []*model.Shorthand, extractors []*model.Extractor) (string, map[string]interface{}, error) {
	text, err := Expand(orig, shorthands)
	if err != nil {
		return text, nil, err
	}

	data, err := Extract(text, extractors)
	return text, data, err
}
