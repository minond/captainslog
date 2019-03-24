package model

import (
	"gopkg.in/src-d/go-kallax.v1"
)

type Entry struct {
	kallax.Model `pk:"guid"`

	Guid      kallax.ULID
	GroupGuid kallax.ULID
	Text      string
	Data      map[string]string
}

func newEntry(text string, data map[string]string, group *Group) (*Entry, error) {
	entry := &Entry{
		Guid: kallax.NewULID(),
		Text: text,
		Data: data,
	}

	if group != nil {
		entry.GroupGuid = group.Guid
	}

	return entry, nil
}
