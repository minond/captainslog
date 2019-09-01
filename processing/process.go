package processing

import (
	"github.com/minond/captainslog/model"
)

func Process(orig string, shorthands []*model.Shorthand, extractors []*model.Extractor) (string, map[string]interface{}, error) {
	text, err := Expand(orig, shorthands)
	if err != nil {
		return text, nil, err
	}

	data, err := Extract(text, extractors)
	return text, data, err
}

type systemExtractor struct {
	Type    model.DataType
	Handler func(string, *model.Entry)
}

var systemExtractors = map[string]systemExtractor{
	"created_at": {
		Type: model.NumberData,
		Handler: func(key string, entry *model.Entry) {
			entry.Data[key] = entry.CreatedAt.Unix()
		},
	},
	"updated_at": {
		Type: model.NumberData,
		Handler: func(key string, entry *model.Entry) {
			entry.Data[key] = entry.UpdatedAt.Unix()
		},
	},
}

func System(entry *model.Entry, extractors []*model.Extractor) {
	for _, extractor := range extractors {
		if extractor.Match != "" {
			continue
		}

		sysEx, found := systemExtractors[extractor.Label]
		if !found {
			continue
		}

		if extractor.Type != sysEx.Type {
			continue
		}

		sysEx.Handler(extractor.Label, entry)
	}
}
