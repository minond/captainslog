package log

import (
	"time"

	"github.com/google/uuid"
)

type UnsyncedLog struct {
	TempID string `json:"tempID"`
	Text   string `json:"text"`
}

func NewLog(text string) Log {
	now := time.Now().Unix()
	return Log{
		Guid:      uuid.New().String(),
		Text:      text,
		Data:      make(map[string]string),
		CreatedOn: now,
		UpdatedOn: now,
	}
}
