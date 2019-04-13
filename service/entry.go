package service

import (
	"context"
	"database/sql"
	"errors"
	"net/url"
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
	Timestamp time.Time `json:"timestamp"`
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

	at := req.Timestamp
	if at.IsZero() {
		at = time.Now().In(time.UTC)
	}

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

	err = s.entryStore.Insert(entry)
	return &EntryCreateResponse{GUID: req.GUID, Entry: entry}, err
}

type EntryRetrieveResponse struct {
	Entries []*model.Entry `json:"entries"`
}

func (s EntryService) Retrieve(ctx context.Context, req url.Values) (*EntryRetrieveResponse, error) {
	var bookGUID string

	if bookGUIDs, ok := req["book"]; ok && len(bookGUIDs) == 1 {
		bookGUID = bookGUIDs[0]
	} else {
		return nil, errors.New("missing required book_guid parameter")
	}

	userGUID, err := getUserGUID(ctx)
	if err != nil {
		return nil, err
	}

	book, err := s.bookStore.FindOne(model.NewBookQuery().
		Where(kallax.Eq(model.Schema.Book.GUID, bookGUID)).
		Where(kallax.Eq(model.Schema.Book.UserGUID, userGUID)))
	if err != nil {
		return nil, err
	}

	now := time.Now().In(time.UTC)
	collection, err := book.Collection(s.collectionStore, now, false)
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
