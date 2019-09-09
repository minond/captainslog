package model

import (
	"testing"
)

func TestUser_Authenticate(t *testing.T) {
	password := "password12345"
	user, err := newUser("zephod", "z@co", password)
	if err != nil {
		t.Errorf("unexpected error when creating user: %v", err)
	}

	if !user.Authenticate(password) {
		t.Error("could not authenticate user")
	}
}
