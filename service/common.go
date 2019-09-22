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
func clientTime(t time.Time, offset int) time.Time {
	if t.IsZero() {
		t = time.Now()
	}

	// NOTE Let's see how this works out for me. In order to show logs for the
	// actual date/time that the _client_ is on, the time zone offset is
	// optionally passed into this request along with the timestamp. The
	// combination of the two are then used to generate a UTC date/time value,
	// which is what is stored in the database.
	return t.In(time.UTC).Add(time.Duration(offset) * time.Minute)
}

func getUserGUID(ctx context.Context) (string, error) {
	val := ctx.Value("uid")
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
