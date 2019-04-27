package service

import (
	"context"
	"database/sql"
	"errors"
	"net/url"
	"strconv"
	"time"

	"gopkg.in/src-d/go-kallax.v1"

	"github.com/minond/captainslog/model"
	"github.com/minond/captainslog/processing"
)

type EntryService struct {
	bookStore       *model.BookStore
	collectionStore *model.CollectionStore
	entryStore      *model.EntryStore
	extractorStore  *model.ExtractorStore
	shorthandStore  *model.ShorthandStore
}

func NewEntryService(db *sql.DB) *EntryService {
	return &EntryService{
		bookStore:       model.NewBookStore(db),
		collectionStore: model.NewCollectionStore(db),
		entryStore:      model.NewEntryStore(db),
		extractorStore:  model.NewExtractorStore(db),
		shorthandStore:  model.NewShorthandStore(db),
	}
}

type EntryCreateRequest struct {
	GUID      string    `json:"guid"`
	Text      string    `json:"text"`
	CreatedAt time.Time `json:"createdAt"`
	BookGUID  string    `json:"bookGuid"`
}

type EntryCreateResponse struct {
	GUID  string       `json:"guid"`
	Entry *model.Entry `json:"entry"`
}

func (s EntryService) Create(ctx context.Context, req *EntryCreateRequest) (*EntryCreateResponse, error) {
	userGUID, err := getUserGUID(ctx)
	if err != nil {
		return nil, err
	}

	book, err := s.bookStore.FindOne(model.NewBookQuery().
		Where(kallax.Eq(model.Schema.Book.GUID, req.BookGUID)).
		Where(kallax.Eq(model.Schema.Book.UserGUID, userGUID)))
	if err != nil {
		return nil, err
	}

	at := clientTime(req.CreatedAt)
	collection, err := book.Collection(s.collectionStore, at, true)
	if err != nil {
		return nil, err
	}

	shorthands, err := book.Shorthands(s.shorthandStore)
	if err != nil {
		return nil, err
	}

	text, err := processing.Expand(req.Text, shorthands)
	if err != nil {
		return nil, err
	}

	extractors, err := book.Extractors(s.extractorStore)
	if err != nil {
		return nil, err
	}

	data, err := processing.Extract(text, extractors)
	if err != nil {
		return nil, err
	}

	entry, err := model.NewEntry(req.Text, text, data, collection)
	if err != nil {
		return nil, err
	}

	entry.CreatedAt = at
	entry.UpdatedAt = at

	if err = s.entryStore.Insert(entry); err != nil {
		return nil, err
	}

	return &EntryCreateResponse{GUID: req.GUID, Entry: entry}, nil
}

type EntryRetrieveResponse struct {
	Entries []*model.Entry `json:"entries"`
}

func (s EntryService) Retrieve(ctx context.Context, req url.Values) (*EntryRetrieveResponse, error) {
	var bookGUID string
	var at time.Time

	if bookGUIDs, ok := req["book"]; ok && len(bookGUIDs) == 1 {
		bookGUID = bookGUIDs[0]
	} else {
		return nil, errors.New("missing required book_guid parameter")
	}

	userGUID, err := getUserGUID(ctx)
	if err != nil {
		return nil, err
	}

	if atDate, ok := req["at"]; ok {
		if len(atDate) == 1 {
			i, err := strconv.ParseInt(atDate[0], 10, 64)
			if err != nil {
				return nil, errors.New("invalid date format, expecting a unix timestamp")
			}
			at = time.Unix(i, 0)
		} else {
			return nil, errors.New("multiple dates passed but only a single is allowed")
		}
	} else {
		at = time.Now()
	}
	at = at.In(time.UTC)

	book, err := s.bookStore.FindOne(model.NewBookQuery().
		Where(kallax.Eq(model.Schema.Book.GUID, bookGUID)).
		Where(kallax.Eq(model.Schema.Book.UserGUID, userGUID)))
	if err != nil {
		return nil, err
	}

	collection, err := book.Collection(s.collectionStore, at, false)
	if err != nil {
		return nil, err
	}

	if collection == nil {
		return &EntryRetrieveResponse{Entries: []*model.Entry{}}, nil
	}

	entries, err := collection.Entries(s.entryStore)
	if err != nil {
		return nil, err
	}

	return &EntryRetrieveResponse{Entries: entries}, nil
}
