package log

import (
	"time"

	"github.com/google/uuid"
)

func NewEntry(text string) *Entry {
	now := time.Now().Unix()
	guid := uuid.New().String()
	return &Entry{
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

func (e Entry) Process(xs []Extractor) (Entry, error) {
	for _, x := range xs {
		data, err := x.Process(e.Text)
		if err != nil {
			return e, err
		}

		e.Data = merge(e.Data, data)
	}

	return e, nil
}
