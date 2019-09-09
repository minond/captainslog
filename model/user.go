package model

import (
	"golang.org/x/crypto/bcrypt"
	"gopkg.in/src-d/go-kallax.v1"
)

type User struct {
	kallax.Model `table:"users" pk:"guid"`

	GUID     kallax.ULID
	Name     string `json:"name"`
	Email    string `json:"email"`
	Password string `json:"-"`
}

func (u *User) Authenticate(plainPassword string) bool {
	return bcrypt.CompareHashAndPassword([]byte(u.Password), []byte(plainPassword)) == nil
}

func newUser(name, email, plainPassword string) (*User, error) {
	hash, err := bcrypt.GenerateFromPassword([]byte(plainPassword), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	return &User{
		GUID:     kallax.NewULID(),
		Name:     name,
		Email:    email,
		Password: string(hash),
	}, nil
}
