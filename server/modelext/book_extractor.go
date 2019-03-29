package modelext

import (
	"gopkg.in/src-d/go-kallax.v1"

	model "github.com/minond/captainslog/server/model"
)

func NewBookExtractor(book *model.Book, extractor *model.Extractor) (*model.BookExtractor, error) {
	return &model.BookExtractor{
		Guid:          kallax.NewULID(),
		BookGuid:      book.Guid,
		ExtractorGuid: extractor.Guid,
	}, nil
}
