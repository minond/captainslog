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

// CurrentGroup returns a Book's current, active Group. It will create one if
// no group is found.
func (b *Book) CurrentGroup() *Group {
	if len(b.Group) == 0 {
		group := newGroup()
		b.Group = append(b.Group, group)
		return group
	}

	// switch b.Grouping {
	// case Grouping_NONE:
	// case Grouping_HOUR:
	// case Grouping_DAY:
	// case Grouping_WEEK:
	// case Grouping_MONTH:
	// case Grouping_YEAR:
	// }

	// group := newGroup()
	// b.Group = append(b.Group, group)
	// return group
	return b.Group[0]
}
