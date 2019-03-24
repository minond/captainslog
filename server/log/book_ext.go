package log

import (
	"time"

	"github.com/google/uuid"
)

func newGroup() *Group {
	now := time.Now().Unix()
	guid := uuid.New().String()
	return &Group{
		Guid:      guid,
		CreatedOn: now,
		UpdatedOn: now,
	}
}

// Group returns a Book's current, active Group. It will create one if no group
// is found.
func (b *Book) Group() *Group {
	return newGroup()
}
