package model

import (
	"gopkg.in/src-d/go-kallax.v1"
)

type SavedQuery struct {
	kallax.Model `table:"saved_queries" pk:"guid"`

	GUID    kallax.ULID `json:"guid"`
	Label   string      `json:"label"`
	Content string      `json:"content" sqltype:"text"`

	User *User `fk:"user_guid,inverse" json:"-"`
}
