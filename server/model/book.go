package model

import (
	"errors"
	"fmt"
	"time"

	"gopkg.in/src-d/go-kallax.v1"
)

// Grouping represents a Book's grouping method
type Grouping int32

const (
	// GroupingNone says that a book has a single main collection that never
	// ends and holds every entry.
	GroupingNone Grouping = iota

	// GroupingDay says that a book has a collection for every day it is used.
	GroupingDay
)

type Book struct {
	kallax.Model `table:"books" pk:"guid"`

	GUID     kallax.ULID `json:"guid"`
	UserGUID kallax.ULID `json:"-"`
	Name     string      `json:"name"`
	Grouping int32       `json:"grouping"`
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

// Extractors retrieves all of this Book's extractors.
func (b *Book) Extractors(extractorStore *ExtractorStore) ([]*Extractor, error) {
	query := NewExtractorQuery().
		Where(kallax.Eq(Schema.Extractor.BookGUID, b.GUID))

	return extractorStore.FindAll(query)
}

// ActiveCollection retrieves a Book's active collection by analyzing its
// grouping. If no collection is found, a collection may be created.
func (b *Book) ActiveCollection(collectionStore *CollectionStore, create bool) (*Collection, error) {
	query, err := activeCollectionQuery(b)
	if err != nil {
		return nil, err
	}

	colls, err := collectionStore.FindAll(query)
	if err != nil {
		return nil, err
	}

	if len(colls) != 0 {
		return colls[0], nil
	}

	if create {
		coll, _ := NewCollection(b)
		err := collectionStore.Insert(coll)
		return coll, err
	}

	return nil, nil
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
