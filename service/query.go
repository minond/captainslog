package service

import (
	"context"
	"database/sql"
	"errors"
	"log"

	"gopkg.in/src-d/go-kallax.v1"

	"github.com/minond/captainslog/model"
	"github.com/minond/captainslog/query"
)

type QueryService struct {
	bookStore      *model.BookStore
	entryStore     *model.EntryStore
	extractorStore *model.ExtractorStore
}

func NewQueryService(db *sql.DB) *QueryService {
	return &QueryService{
		bookStore:      model.NewBookStore(db),
		entryStore:     model.NewEntryStore(db),
		extractorStore: model.NewExtractorStore(db),
	}
}

type QueryExecuteRequest struct {
	Query string `json:"query"`
}

type QueryResults struct {
	Cols []string        `json:"cols"`
	Data [][]interface{} `json:"data"`
}

func (s QueryService) Query(ctx context.Context, req *QueryExecuteRequest) (*QueryResults, error) {
	userGUID, err := getUserGUID(ctx)
	if err != nil {
		return nil, err
	}

	sql, cols, data, err := query.Exec(s.entryStore, req.Query, userGUID)
	log.Printf("sql: %s", sql)
	if err != nil {
		log.Printf("err: %s", err)
		return nil, err
	}

	return &QueryResults{cols, data}, nil
}

type FieldSchema struct {
	Name string         `json:"name"`
	Type model.DataType `json:"type"`
}

type BookSchema struct {
	Name   string        `json:"name"`
	Fields []FieldSchema `json:"fields"`
}

type Schema struct {
	Books []BookSchema `json:"books"`
}

type SchemaIR struct {
	book       *model.Book
	extractors []*model.Extractor
}

type SchemaT map[kallax.ULID]*SchemaIR

func generateSchema(ir SchemaT) *Schema {
	schema := &Schema{}
	for _, item := range ir {
		fields := make([]FieldSchema, len(item.extractors))
		for i, extractor := range item.extractors {
			fields[i] = FieldSchema{
				Name: extractor.Label,
				Type: extractor.Type,
			}
		}
		schema.Books = append(schema.Books, BookSchema{
			Name:   item.book.Name,
			Fields: fields,
		})
	}
	return schema
}

func generateSchemaIR(books []*model.Book, extractors []*model.Extractor) (SchemaT, error) {
	ir := make(SchemaT)
	for _, book := range books {
		ir[book.GUID] = &SchemaIR{book: book}
	}
	for _, extractor := range extractors {
		bookGUIDinterface, err := extractor.Value("book_guid")
		if err != nil {
			return nil, errors.New("missing identifer")
		}
		bookGUIDid, ok := bookGUIDinterface.(kallax.Identifier)
		if !ok {
			return nil, errors.New("invalid identifier")
		}
		bookGUID, ok := bookGUIDid.Raw().(kallax.ULID)
		if !ok {
			return nil, errors.New("invalid identifier")
		}
		ir[bookGUID].extractors = append(ir[bookGUID].extractors, extractor)
	}
	return ir, nil
}

func getExtractorsForSchema(bookGUIDs []interface{}, extractorStore *model.ExtractorStore) ([]*model.Extractor, error) {
	extractorsQuery := model.NewExtractorQuery().
		Select(model.Schema.Extractor.BookFK,
			model.Schema.Extractor.Label,
			model.Schema.Extractor.Type).
		Where(kallax.In(model.Schema.Extractor.BookFK, bookGUIDs...))
	return extractorStore.FindAll(extractorsQuery)
}

func getBooksForSchema(userGUID string, bookStore *model.BookStore) ([]*model.Book, []interface{}, error) {
	booksQuery := model.NewBookQuery().
		Select(model.Schema.Book.GUID,
			model.Schema.Book.Name).
		Where(kallax.Eq(model.Schema.Book.UserFK, userGUID)).
		Order(kallax.Asc(model.Schema.Book.Name))
	books, err := bookStore.FindAll(booksQuery)
	if err != nil {
		return nil, nil, err
	}

	bookGUIDs := make([]interface{}, len(books))
	for i, book := range books {
		bookGUIDs[i] = book.GUID
	}

	return books, bookGUIDs, nil
}

func (s QueryService) Schema(ctx context.Context) (*Schema, error) {
	userGUID, err := getUserGUID(ctx)
	if err != nil {
		return nil, err
	}

	books, bookGUIDs, err := getBooksForSchema(userGUID, s.bookStore)
	if err != nil {
		return nil, err
	}

	extractors, err := getExtractorsForSchema(bookGUIDs, s.extractorStore)
	if err != nil {
		return nil, err
	}

	ir, err := generateSchemaIR(books, extractors)
	if err != nil {
		return nil, err
	}

	return generateSchema(ir), nil
}
