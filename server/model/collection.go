package model

import (
	"time"

	"gopkg.in/src-d/go-kallax.v1"
)

type Collection struct {
	kallax.Model `table:"collections" pk:"guid"`

	Guid      kallax.ULID
	BookGuid  kallax.ULID
	CreatedAt time.Time
}
