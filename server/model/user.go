package model

import "gopkg.in/src-d/go-kallax.v1"

type User struct {
	kallax.Model `pk:"guid"`

	Guid kallax.ULID
}

func newUser() (*User, error) {
	return &User{Guid: kallax.NewULID()}, nil
}
