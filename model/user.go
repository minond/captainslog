package model

import (
	"math/rand"
	"strings"

	"golang.org/x/crypto/bcrypt"
	"gopkg.in/src-d/go-kallax.v1"
)

type User struct {
	kallax.Model `table:"users" pk:"guid"`

	GUID     kallax.ULID
	Name     string `json:"name"`
	Email    string `json:"email"`
	Salt     string `json:"-"`
	Password string `json:"-"`
}

func (u *User) Authenticate(plainPassword string) bool {
	return bcrypt.CompareHashAndPassword([]byte(u.Password), []byte(u.Salt+plainPassword)) == nil
}

func newUser(name, email, plainPassword string) (*User, error) {
	salt := randString(32)
	hash, err := bcrypt.GenerateFromPassword([]byte(salt+plainPassword), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	return &User{
		GUID:     kallax.NewULID(),
		Name:     name,
		Email:    email,
		Password: string(hash),
		Salt:     salt,
	}, nil
}

var (
	chars = [...]rune{
		'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
		'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
		'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
		'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
	}

	charsLen = len(chars)
)

func randString(size int) string {
	buff := strings.Builder{}
	for i := 0; i < size; i++ {
		buff.WriteRune(chars[rand.Intn(charsLen)])
	}
	return buff.String()
}
