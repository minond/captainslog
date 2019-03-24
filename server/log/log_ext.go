package log

import (
	"time"

	"github.com/google/uuid"
)

func NewLog(text string) *Log {
	now := time.Now().Unix()
	guid := uuid.New().String()
	return &Log{
		Guid:      guid,
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

func (l Log) Process(xs []Extractor) (Log, error) {
	for _, x := range xs {
		data, err := x.Process(l.Text)
		if err != nil {
			return l, err
		}

		l.Data = merge(l.Data, data)
	}

	return l, nil
}
