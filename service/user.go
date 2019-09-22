package service

import (
	"context"
	"database/sql"
	"errors"
	"net/http"
	"os"

	"gopkg.in/src-d/go-kallax.v1"

	"github.com/dgrijalva/jwt-go"
	"github.com/dgrijalva/jwt-go/request"

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

type UserToken struct {
	Token string `json:"token"`
}

func (s UserService) GenerateToken(ctx context.Context, req *UserLoginRequest) (*UserToken, error) {
	sessionTokenSecret := []byte(os.Getenv("SESSION_TOKEN_SECRET"))
	if len(sessionTokenSecret) == 0 {
		return nil, errors.New("unable to load session environment information")
	}

	if !req.Valid() {
		return nil, errors.New("invalid request")
	}

	user, err := s.Login(context.Background(), req)
	if err != nil {
		return nil, err
	}

	claims := jwt.MapClaims{"uid": user.GUID}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signed, err := token.SignedString(sessionTokenSecret)
	if err != nil {
		return nil, err
	}

	return &UserToken{Token: signed}, nil
}

type UserSession struct {
	UID string
}

func (s UserService) ExtractSessionFromRequest(r *http.Request) (*UserSession, error) {
	sessionTokenSecret := []byte(os.Getenv("SESSION_TOKEN_SECRET"))
	if len(sessionTokenSecret) == 0 {
		return nil, errors.New("unable to load session environment information")
	}

	token, err := request.ParseFromRequest(
		r,
		request.AuthorizationHeaderExtractor,
		func(t *jwt.Token) (interface{}, error) {
			return sessionTokenSecret, nil
		})
	if err != nil {
		return nil, err
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok || claims["uid"] == "" {
		return nil, errors.New("unable to extract token data")
	}

	return &UserSession{UID: claims["uid"].(string)}, nil
}
