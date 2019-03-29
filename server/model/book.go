package model

import (
	"gopkg.in/src-d/go-kallax.v1"
)

type Book struct {
	kallax.Model `table:"books" pk:"guid"`

	Guid     kallax.ULID
	UserGuid kallax.ULID
	Name     string
	Grouping int32
}
