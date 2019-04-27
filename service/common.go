package service

import (
	"context"
	"errors"
	"time"

	"gopkg.in/src-d/go-kallax.v1"

	"github.com/minond/captainslog/model"
)

// clientTime should be used when accepting time values from a user and when a
// standard, never-zero time value is required.
func clientTime(t time.Time) time.Time {
	if t.IsZero() {
		t = time.Now()
	}
	return t.In(time.UTC)
}

func getUserGUID(ctx context.Context) (string, error) {
	val := ctx.Value("userguid")
	if val == nil {
		return "", errors.New("noguid")
	}

	guid, ok := val.(string)
	if !ok {
		return "", errors.New("badguid")
	}

	return guid, nil
}

func getUser(ctx context.Context, store *model.UserStore) (*model.User, error) {
	userGUIDRaw, err := getUserGUID(ctx)
	if err != nil {
		return nil, err
	}

	userGUID, err := kallax.NewULIDFromText(userGUIDRaw)
	if err != nil {
		return nil, err
	}

	return store.FindOne(model.NewUserQuery().FindByGUID(userGUID))
}
