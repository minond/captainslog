package log

import (
	"time"

	"github.com/google/uuid"
)

func newGroup() *LogGroup {
	now := time.Now().Unix()
	guid := uuid.New().String()
	return &LogGroup{
		Guid:      guid,
		CreatedOn: now,
		UpdatedOn: now,
	}
}

// CurrentGroup returns a Log Book's current, active Log Group. It will create
// one if no group is found.
func (lb *LogBook) CurrentGroup() *LogGroup {
	if len(lb.Group) == 0 {
		group := newGroup()
		lb.Group = append(lb.Group, group)
		return group
	}

	// switch lb.Grouping {
	// case Grouping_NONE:
	// case Grouping_HOUR:
	// case Grouping_DAY:
	// case Grouping_WEEK:
	// case Grouping_MONTH:
	// case Grouping_YEAR:
	// }

	// group := newGroup()
	// lb.Group = append(lb.Group, group)
	// return group
	return lb.Group[0]
}
