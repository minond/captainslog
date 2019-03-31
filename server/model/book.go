package model

import (
	"errors"
	"fmt"
	"time"

	"gopkg.in/src-d/go-kallax.v1"
)

type Grouping int32

const (
	GroupingNone Grouping = iota
	GroupingDay
)

type Book struct {
	kallax.Model `table:"books" pk:"guid"`

	GUID     kallax.ULID
	UserGUID kallax.ULID
	Name     string
	Grouping int32
}

func newBook(name string, grouping int32, user *User) (*Book, error) {
	book := &Book{
		GUID:     kallax.NewULID(),
		Name:     name,
		Grouping: grouping,
	}

	if user != nil {
		book.UserGUID = user.GUID
	}

	return book, nil
}

// ActiveCollection returns this Book's active collection by either retrieving
// an available collection that falls within the Book's grouping range or
// creating a new collection.
func (b *Book) ActiveCollection(collectionStore *CollectionStore) (*Collection, error) {
	query, err := activeCollectionQuery(b)
	if err != nil {
		return nil, err
	}

	colls, err := collectionStore.FindAll(query)
	if err != nil {
		return nil, err
	}

	if len(colls) == 0 {
		coll, _ := NewCollection(b)
		err := collectionStore.Insert(coll)
		return coll, err
	}

	return colls[0], nil
}

// activeCollectionQuery returns a query that will search for a book's current,
// active collection.
func activeCollectionQuery(b *Book) (*CollectionQuery, error) {
	query := NewCollectionQuery().
		Where(kallax.Eq(Schema.Collection.BookGUID, b.GUID)).
		Where(kallax.Eq(Schema.Collection.Open, true))

	if grouping := Grouping(b.Grouping); grouping != GroupingNone {
		start, end, err := timeRange(grouping)
		if err != nil {
			return nil, err
		}

		query.Where(BetweenTimes(Schema.Collection.CreatedAt, start, end))
	}

	return query, nil
}

// timeRange returns a start and end time that corresponds to the time range a
// group starts and ends.
func timeRange(grouping Grouping) (start time.Time, end time.Time, err error) {
	switch Grouping(grouping) {
	case GroupingNone:
		return start, end, errors.New("no possible timerange for nil grouping")

	case GroupingDay:
		now := time.Now().In(time.UTC)
		year, month, day := now.Date()

		start = time.Date(year, month, day, 0, 0, 0, 0, time.UTC)
		end = time.Date(year, month, day+1, 0, 0, 0, -1, time.UTC)

		return

	default:
		return start, end, fmt.Errorf("invalid grouping: %v", grouping)
	}
}
