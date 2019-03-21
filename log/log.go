package log

import (
	"time"

	"github.com/google/uuid"
)

type Log struct {
	GUID      string            `json:"guid"`
	Text      string            `json:"text"`
	Data      map[string]string `json:"data"`
	CreatedOn int64             `json:"createdOn"`
	CreatedBy string            `json:"createdBy"`
	UpdatedOn int64             `json:"updatedOn"`
	UpdatedBy string            `json:"updatedBy"`
	DeletedOn *int64            `json:"deletedOn"`
	DeletedBy *string           `json:"deletedBy"`
}

func NewLog(text string) Log {
	now := time.Now().Unix()
	return Log{
		GUID:      uuid.New().String(),
		Text:      text,
		Data:      make(map[string]string),
		CreatedOn: now,
		UpdatedOn: now,
	}
}
