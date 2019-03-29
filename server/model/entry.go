package model

import (
	"time"

	"gopkg.in/src-d/go-kallax.v1"
)

type Entry struct {
	kallax.Model `table:"entries" pk:"guid"`

	Guid           kallax.ULID
	CollectionGuid kallax.ULID
	Text           string
	Data           map[string]string
	CreatedAt      time.Time
	UpdatedAt      time.Time
}
