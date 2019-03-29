package modelext

import (
	"time"

	"gopkg.in/src-d/go-kallax.v1"

	model "github.com/minond/captainslog/server/model"
	"github.com/minond/captainslog/server/proto"
)

type entry struct{}

var Entry = entry{}

func NewEntry(text string, data map[string]string, collection *model.Collection) (*model.Entry, error) {
	now := time.Now()
	entry := &model.Entry{
		Guid:      kallax.NewULID(),
		Text:      text,
		Data:      data,
		CreatedAt: now,
		UpdatedAt: now,
	}

	if collection != nil {
		entry.CollectionGuid = collection.Guid
	}

	return entry, nil
}

func (entry) ToProto(e *model.Entry) *proto.Entry {
	return &proto.Entry{
		Guid:      e.Guid.String(),
		Text:      e.Text,
		Timestamp: e.CreatedAt.Unix(),
		Data:      e.Data,
	}
}
