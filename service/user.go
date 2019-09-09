package service

import (
	"context"
	"database/sql"

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
