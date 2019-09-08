package model

import "gopkg.in/src-d/go-kallax.v1"

type User struct {
	kallax.Model `table:"users" pk:"guid"`

	GUID     kallax.ULID
	Name     string `json:"name"`
	Email    string `json:"email"`
	Password string `json:"-"`
}

func newUser() (*User, error) {
	return &User{GUID: kallax.NewULID()}, nil
}
