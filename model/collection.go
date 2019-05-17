package model

import (
	"time"

	"gopkg.in/src-d/go-kallax.v1"
)

type Collection struct {
	kallax.Model `table:"collections" pk:"guid"`

	GUID      kallax.ULID
	Open      bool
	CreatedAt time.Time `sqltype:"timestamp"`

	Book *Book `fk:"book_guid,inverse"`
}

func newCollection(book *Book) (*Collection, error) {
	collection := &Collection{
		GUID:      kallax.NewULID(),
		Open:      true,
		CreatedAt: time.Now(),
	}

	if book != nil {
		collection.AddVirtualColumn("book_guid", (*kallax.ULID)(&book.GUID))
	}

	return collection, nil
}

func (c *Collection) Entries(entryStore *EntryStore) ([]*Entry, error) {
	return entryStore.FindAll(NewEntryQuery().
		Where(kallax.Eq(Schema.Entry.CollectionFK, c.GUID)))
}
