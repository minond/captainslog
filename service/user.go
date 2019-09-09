package service

import (
	"context"
	"database/sql"
	"errors"

	"gopkg.in/src-d/go-kallax.v1"

	"github.com/minond/captainslog/model"
)

type UserService struct {
	userStore *model.UserStore
}

func NewUserService(db *sql.DB) *UserService {
	return &UserService{
		userStore: model.NewUserStore(db),
	}
}

type UserCreateRequest struct {
	Name          string `json:"name"`
	Email         string `json:"email"`
	PlainPassword string `json:"plainPassword"`
}

func (s UserService) Create(ctx context.Context, req *UserCreateRequest) (*model.User, error) {
	user, err := model.NewUser(req.Name, req.Email, req.PlainPassword)
	if err != nil {
		return nil, err
	}

	if err = s.userStore.Insert(user); err != nil {
		return nil, err
	}

	return user, nil
}

var CouldNotAuthenticateUserErr = errors.New("count not authenticate user")

type UserLoginRequest struct {
	Email         string `json:"email"`
	PlainPassword string `json:"plainPassword"`
}

func (req UserLoginRequest) Valid() bool {
	return req.Email != "" && req.PlainPassword != ""
}

func (s UserService) Login(ctx context.Context, req *UserLoginRequest) (*model.User, error) {
	user, err := s.userStore.FindOne(model.NewUserQuery().
		Where(kallax.Eq(model.Schema.User.Email, req.Email)))
	if err != nil {
		return nil, err
	}

	if user.Authenticate(req.PlainPassword) {
		return user, nil
	}

	return nil, CouldNotAuthenticateUserErr
}
