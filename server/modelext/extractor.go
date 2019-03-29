package modelext

import (
	"gopkg.in/src-d/go-kallax.v1"

	model "github.com/minond/captainslog/server/model"
)

func NewExtractor(label, match string) (*model.Extractor, error) {
	return &model.Extractor{
		Guid:  kallax.NewULID(),
		Label: label,
		Match: match,
	}, nil
}
