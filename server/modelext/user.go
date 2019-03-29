package modelext

import (
	"gopkg.in/src-d/go-kallax.v1"

	model "github.com/minond/captainslog/server/model"
)

func NewUser() (*model.User, error) {
	return &model.User{Guid: kallax.NewULID()}, nil
}
