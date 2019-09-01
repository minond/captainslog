package service

import (
	"context"
	"database/sql"
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
	userStore       *model.UserStore
}

func NewEntryService(db *sql.DB) *EntryService {
	return &EntryService{
		bookStore:       model.NewBookStore(db),
		collectionStore: model.NewCollectionStore(db),
		entryStore:      model.NewEntryStore(db),
		extractorStore:  model.NewExtractorStore(db),
		shorthandStore:  model.NewShorthandStore(db),
		userStore:       model.NewUserStore(db),
	}
}

type EntriesCreateRequest struct {
	Entries []struct {
		Text      string    `json:"text"`
		CreatedAt time.Time `json:"createdAt"`
	} `json:"entries"`
	Offset   int    `json:"offset"`
	BookGUID string `json:"bookGuid"`
}

type EntriesCreateResponse struct {
	Entries []*model.Entry `json:"entries"`
}

func (s EntryService) Create(ctx context.Context, req *EntriesCreateRequest) (*EntriesCreateResponse, error) {
	user, err := getUser(ctx, s.userStore)
	if err != nil {
		return nil, err
	}

	book, err := model.FindBook(s.bookStore, user, req.BookGUID)
	if err != nil {
		return nil, err
	}

	shorthands, err := book.Shorthands(s.shorthandStore)
	if err != nil {
		return nil, err
	}

	extractors, err := book.Extractors(s.extractorStore)
	if err != nil {
		return nil, err
	}

	entries := make([]*model.Entry, len(req.Entries))
	for i, entry := range req.Entries {
		text, data, err := processing.Process(entry.Text, shorthands, extractors)
		if err != nil {
			return nil, err
		}

		at := clientTime(entry.CreatedAt, req.Offset)
		collection, err := book.Collection(s.collectionStore, at, true)
		if err != nil {
			return nil, err
		}

		entry, err := model.NewEntry(entry.Text, text, data, collection)
		if err != nil {
			return nil, err
		}

		entry.CreatedAt = at
		entry.UpdatedAt = at

		processing.System(entry, extractors)

		if err = s.entryStore.Insert(entry); err != nil {
			return nil, err
		}

		entries[i] = entry
	}

	return &EntriesCreateResponse{Entries: entries}, nil
}

type EntryUpdateRequest struct {
	GUID string `json:"guid"`
	Text string `json:"text"`
}

func (s EntryService) Update(ctx context.Context, req *EntryUpdateRequest) (*model.Entry, error) {
	userGUID, err := getUserGUID(ctx)
	if err != nil {
		return nil, err
	}

	query := model.NewEntryQuery().
		WithBook().
		Where(kallax.Eq(model.Schema.Book.GUID, req.GUID)).
		Where(kallax.Eq(model.Schema.Book.UserFK, userGUID))
	entry, err := s.entryStore.FindOne(query)
	if err != nil {
		return nil, err
	}

	shorthands, err := entry.Book.Shorthands(s.shorthandStore)
	if err != nil {
		return nil, err
	}

	extractors, err := entry.Book.Extractors(s.extractorStore)
	if err != nil {
		return nil, err
	}

	text, data, err := processing.Process(req.Text, shorthands, extractors)
	if err != nil {
		return nil, err
	}

	entry.Original = req.Text
	entry.Text = text
	entry.Data = data
	entry.UpdatedAt = time.Now()

	if _, err := s.entryStore.Update(entry); err != nil {
		return nil, err
	}

	return entry, nil
}

type EntryDeleteRequest struct {
	GUID string `json:"guid"`
}

type EntryDeleteResponse struct {
	Ok bool `json:"ok"`
}

func (s EntryService) Delete(ctx context.Context, req *EntryDeleteRequest) (*EntryDeleteResponse, error) {
	userGUID, err := getUserGUID(ctx)
	if err != nil {
		return nil, err
	}

	query := model.NewEntryQuery().
		Where(kallax.Eq(model.Schema.Book.GUID, req.GUID)).
		Where(kallax.Eq(model.Schema.Book.UserFK, userGUID))
	entry, err := s.entryStore.FindOne(query)
	if err != nil {
		return nil, err
	}

	if err := s.entryStore.Delete(entry); err != nil {
		return nil, err
	}

	return &EntryDeleteResponse{Ok: true}, nil
}

type EntryRetrieveRequest struct {
	BookGUID string `schema:"book"`
	At       int    `schema:"at"`
	Offset   int    `schema:"offset"`
}

type EntryRetrieveResponse struct {
	Entries []*model.Entry `json:"entries"`
}

func (s EntryService) Retrieve(ctx context.Context, req *EntryRetrieveRequest) (*EntryRetrieveResponse, error) {
	userGUID, err := getUserGUID(ctx)
	if err != nil {
		return nil, err
	}

	at := time.Now()
	if req.At != 0 {
		at = clientTime(time.Unix(int64(req.At), 0), req.Offset)
	}

	book, err := s.bookStore.FindOne(model.NewBookQuery().
		Where(kallax.Eq(model.Schema.Book.GUID, req.BookGUID)).
		Where(kallax.Eq(model.Schema.Book.UserFK, userGUID)))
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
