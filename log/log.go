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

func merge(a, b map[string]string) map[string]string {
	if b == nil {
		return a
	}
	for k, v := range b {
		a[k] = v
	}
	return a
}

func Process(l Log, xs []Extractor) (Log, error) {
	for _, x := range xs {
		data, err := x.Process(l.Text)
		if err != nil {
			return l, err
		}

		l.Data = merge(l.Data, data)
	}

	return l, nil
}
