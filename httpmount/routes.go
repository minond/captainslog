// Code generated by generator/httpmount/main.go. DO NOT EDIT.
package httpmount

import (
	"context"
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
	"net/url"
	"os"

	"github.com/gorilla/mux"
	"github.com/gorilla/schema"
	"github.com/gorilla/sessions"

	"github.com/minond/captainslog/model"
	"github.com/minond/captainslog/service"
)

var _ = schema.NewDecoder
var store = sessions.NewCookieStore([]byte(os.Getenv("SESSION_KEY")))

// BookServiceContract defines what an implementation of service.BookService
// should look like. This interface is derived from the routes.json file
// provided as input to this generator, and it is a combination of the handler,
// the request, and the response.
type BookServiceContract interface {
	// Create runs when a POST /api/books request comes in.
	Create(ctx context.Context, req *service.BookCreateRequest) (*model.Book, error)

	// Retrieve runs when a GET /api/books request comes in.
	Retrieve(ctx context.Context, req *service.BookRetrieveRequest) (*service.BookRetrieveResponse, error)
}

// SavedQueryServiceContract defines what an implementation of service.SavedQueryService
// should look like. This interface is derived from the routes.json file
// provided as input to this generator, and it is a combination of the handler,
// the request, and the response.
type SavedQueryServiceContract interface {
	// Create runs when a POST /api/saved_query request comes in.
	Create(ctx context.Context, req *service.SavedQueryCreateRequest) (*model.SavedQuery, error)

	// Update runs when a PUT /api/saved_query request comes in.
	Update(ctx context.Context, req *model.SavedQuery) (*model.SavedQuery, error)

	// Retrieve runs when a GET /api/saved_query request comes in.
	Retrieve(ctx context.Context, req url.Values) (*service.SavedQueriesRetrieveResponse, error)
}

// ExtractorServiceContract defines what an implementation of service.ExtractorService
// should look like. This interface is derived from the routes.json file
// provided as input to this generator, and it is a combination of the handler,
// the request, and the response.
type ExtractorServiceContract interface {
	// Create runs when a POST /api/extractors request comes in.
	Create(ctx context.Context, req *service.ExtractorCreateRequest) (*model.Extractor, error)
}

// EntryServiceContract defines what an implementation of service.EntryService
// should look like. This interface is derived from the routes.json file
// provided as input to this generator, and it is a combination of the handler,
// the request, and the response.
type EntryServiceContract interface {
	// Create runs when a POST /api/entries request comes in.
	Create(ctx context.Context, req *service.EntryCreateRequest) (*service.EntryCreateResponse, error)

	// Retrieve runs when a GET /api/entries request comes in.
	Retrieve(ctx context.Context, req *service.EntryRetrieveRequest) (*service.EntryRetrieveResponse, error)
}

// QueryServiceContract defines what an implementation of service.QueryService
// should look like. This interface is derived from the routes.json file
// provided as input to this generator, and it is a combination of the handler,
// the request, and the response.
type QueryServiceContract interface {
	// Schema runs when a GET /api/query request comes in.
	Schema(ctx context.Context, req url.Values) (*service.Schema, error)

	// Query runs when a POST /api/query request comes in.
	Query(ctx context.Context, req *service.QueryExecuteRequest) (*service.QueryResults, error)
}

// ShorthandServiceContract defines what an implementation of service.ShorthandService
// should look like. This interface is derived from the routes.json file
// provided as input to this generator, and it is a combination of the handler,
// the request, and the response.
type ShorthandServiceContract interface {
	// Create runs when a POST /api/shorthands request comes in.
	Create(ctx context.Context, req *service.ShorthandCreateRequest) (*model.Shorthand, error)
}

// MountBookService add a handler to a Gorilla Mux Router that will route
// an incoming request through the service.BookService service.
func MountBookService(router *mux.Router, serv BookServiceContract) {
	log.Print("[INFO] mounting service.BookService on /api/books endpoint")
	router.HandleFunc("/api/books", func(w http.ResponseWriter, r *http.Request) {
		session, err := store.Get(r, "main")
		if err != nil {
			http.Error(w, "unable to read request data", http.StatusInternalServerError)
			log.Printf("[ERROR] error getting session: %v", err)
			return
		}

		switch r.Method {

		case "POST":
			req := &service.BookCreateRequest{}
			defer r.Body.Close()
			data, err := ioutil.ReadAll(r.Body)
			if err != nil {
				http.Error(w, "unable to read request body", http.StatusBadRequest)
				log.Printf("[ERROR] error reading request body: %v", err)
				return
			}

			if err = json.Unmarshal(data, req); err != nil {
				http.Error(w, "unable to decode request", http.StatusBadRequest)
				log.Printf("[ERROR] error unmarshaling request: %v", err)
				return
			}

			ctx := context.Background()
			for key, val := range session.Values {
				ctx = context.WithValue(ctx, key, val)
			}

			res, err := serv.Create(ctx, req)
			if err != nil {
				http.Error(w, "unable to handle request", http.StatusInternalServerError)
				log.Printf("[ERROR] error handling request: %v", err)
				return
			}

			out, err := json.Marshal(res)
			if err != nil {
				http.Error(w, "unable to encode response", http.StatusInternalServerError)
				log.Printf("[ERROR] error marshaling response: %v", err)
				return
			}

			w.Write(out)

		case "GET":
			req := &service.BookRetrieveRequest{}
			dec := schema.NewDecoder()
			if err = dec.Decode(req, r.URL.Query()); err != nil {
				http.Error(w, "unable to decode request", http.StatusBadRequest)
				log.Printf("[ERROR] error unmarshaling request: %v", err)
				return
			}

			ctx := context.Background()
			for key, val := range session.Values {
				ctx = context.WithValue(ctx, key, val)
			}

			res, err := serv.Retrieve(ctx, req)
			if err != nil {
				http.Error(w, "unable to handle request", http.StatusInternalServerError)
				log.Printf("[ERROR] error handling request: %v", err)
				return
			}

			out, err := json.Marshal(res)
			if err != nil {
				http.Error(w, "unable to encode response", http.StatusInternalServerError)
				log.Printf("[ERROR] error marshaling response: %v", err)
				return
			}

			w.Write(out)

		default:
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		}
	})
}

// MountSavedQueryService add a handler to a Gorilla Mux Router that will route
// an incoming request through the service.SavedQueryService service.
func MountSavedQueryService(router *mux.Router, serv SavedQueryServiceContract) {
	log.Print("[INFO] mounting service.SavedQueryService on /api/saved_query endpoint")
	router.HandleFunc("/api/saved_query", func(w http.ResponseWriter, r *http.Request) {
		session, err := store.Get(r, "main")
		if err != nil {
			http.Error(w, "unable to read request data", http.StatusInternalServerError)
			log.Printf("[ERROR] error getting session: %v", err)
			return
		}

		switch r.Method {

		case "POST":
			req := &service.SavedQueryCreateRequest{}
			defer r.Body.Close()
			data, err := ioutil.ReadAll(r.Body)
			if err != nil {
				http.Error(w, "unable to read request body", http.StatusBadRequest)
				log.Printf("[ERROR] error reading request body: %v", err)
				return
			}

			if err = json.Unmarshal(data, req); err != nil {
				http.Error(w, "unable to decode request", http.StatusBadRequest)
				log.Printf("[ERROR] error unmarshaling request: %v", err)
				return
			}

			ctx := context.Background()
			for key, val := range session.Values {
				ctx = context.WithValue(ctx, key, val)
			}

			res, err := serv.Create(ctx, req)
			if err != nil {
				http.Error(w, "unable to handle request", http.StatusInternalServerError)
				log.Printf("[ERROR] error handling request: %v", err)
				return
			}

			out, err := json.Marshal(res)
			if err != nil {
				http.Error(w, "unable to encode response", http.StatusInternalServerError)
				log.Printf("[ERROR] error marshaling response: %v", err)
				return
			}

			w.Write(out)

		case "PUT":
			req := &model.SavedQuery{}
			defer r.Body.Close()
			data, err := ioutil.ReadAll(r.Body)
			if err != nil {
				http.Error(w, "unable to read request body", http.StatusBadRequest)
				log.Printf("[ERROR] error reading request body: %v", err)
				return
			}

			if err = json.Unmarshal(data, req); err != nil {
				http.Error(w, "unable to decode request", http.StatusBadRequest)
				log.Printf("[ERROR] error unmarshaling request: %v", err)
				return
			}

			ctx := context.Background()
			for key, val := range session.Values {
				ctx = context.WithValue(ctx, key, val)
			}

			res, err := serv.Update(ctx, req)
			if err != nil {
				http.Error(w, "unable to handle request", http.StatusInternalServerError)
				log.Printf("[ERROR] error handling request: %v", err)
				return
			}

			out, err := json.Marshal(res)
			if err != nil {
				http.Error(w, "unable to encode response", http.StatusInternalServerError)
				log.Printf("[ERROR] error marshaling response: %v", err)
				return
			}

			w.Write(out)

		case "GET":
			req := r.URL.Query()

			ctx := context.Background()
			for key, val := range session.Values {
				ctx = context.WithValue(ctx, key, val)
			}

			res, err := serv.Retrieve(ctx, req)
			if err != nil {
				http.Error(w, "unable to handle request", http.StatusInternalServerError)
				log.Printf("[ERROR] error handling request: %v", err)
				return
			}

			out, err := json.Marshal(res)
			if err != nil {
				http.Error(w, "unable to encode response", http.StatusInternalServerError)
				log.Printf("[ERROR] error marshaling response: %v", err)
				return
			}

			w.Write(out)

		default:
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		}
	})
}

// MountExtractorService add a handler to a Gorilla Mux Router that will route
// an incoming request through the service.ExtractorService service.
func MountExtractorService(router *mux.Router, serv ExtractorServiceContract) {
	log.Print("[INFO] mounting service.ExtractorService on /api/extractors endpoint")
	router.HandleFunc("/api/extractors", func(w http.ResponseWriter, r *http.Request) {
		session, err := store.Get(r, "main")
		if err != nil {
			http.Error(w, "unable to read request data", http.StatusInternalServerError)
			log.Printf("[ERROR] error getting session: %v", err)
			return
		}

		switch r.Method {

		case "POST":
			req := &service.ExtractorCreateRequest{}
			defer r.Body.Close()
			data, err := ioutil.ReadAll(r.Body)
			if err != nil {
				http.Error(w, "unable to read request body", http.StatusBadRequest)
				log.Printf("[ERROR] error reading request body: %v", err)
				return
			}

			if err = json.Unmarshal(data, req); err != nil {
				http.Error(w, "unable to decode request", http.StatusBadRequest)
				log.Printf("[ERROR] error unmarshaling request: %v", err)
				return
			}

			ctx := context.Background()
			for key, val := range session.Values {
				ctx = context.WithValue(ctx, key, val)
			}

			res, err := serv.Create(ctx, req)
			if err != nil {
				http.Error(w, "unable to handle request", http.StatusInternalServerError)
				log.Printf("[ERROR] error handling request: %v", err)
				return
			}

			out, err := json.Marshal(res)
			if err != nil {
				http.Error(w, "unable to encode response", http.StatusInternalServerError)
				log.Printf("[ERROR] error marshaling response: %v", err)
				return
			}

			w.Write(out)

		default:
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		}
	})
}

// MountEntryService add a handler to a Gorilla Mux Router that will route
// an incoming request through the service.EntryService service.
func MountEntryService(router *mux.Router, serv EntryServiceContract) {
	log.Print("[INFO] mounting service.EntryService on /api/entries endpoint")
	router.HandleFunc("/api/entries", func(w http.ResponseWriter, r *http.Request) {
		session, err := store.Get(r, "main")
		if err != nil {
			http.Error(w, "unable to read request data", http.StatusInternalServerError)
			log.Printf("[ERROR] error getting session: %v", err)
			return
		}

		switch r.Method {

		case "POST":
			req := &service.EntryCreateRequest{}
			defer r.Body.Close()
			data, err := ioutil.ReadAll(r.Body)
			if err != nil {
				http.Error(w, "unable to read request body", http.StatusBadRequest)
				log.Printf("[ERROR] error reading request body: %v", err)
				return
			}

			if err = json.Unmarshal(data, req); err != nil {
				http.Error(w, "unable to decode request", http.StatusBadRequest)
				log.Printf("[ERROR] error unmarshaling request: %v", err)
				return
			}

			ctx := context.Background()
			for key, val := range session.Values {
				ctx = context.WithValue(ctx, key, val)
			}

			res, err := serv.Create(ctx, req)
			if err != nil {
				http.Error(w, "unable to handle request", http.StatusInternalServerError)
				log.Printf("[ERROR] error handling request: %v", err)
				return
			}

			out, err := json.Marshal(res)
			if err != nil {
				http.Error(w, "unable to encode response", http.StatusInternalServerError)
				log.Printf("[ERROR] error marshaling response: %v", err)
				return
			}

			w.Write(out)

		case "GET":
			req := &service.EntryRetrieveRequest{}
			dec := schema.NewDecoder()
			if err = dec.Decode(req, r.URL.Query()); err != nil {
				http.Error(w, "unable to decode request", http.StatusBadRequest)
				log.Printf("[ERROR] error unmarshaling request: %v", err)
				return
			}

			ctx := context.Background()
			for key, val := range session.Values {
				ctx = context.WithValue(ctx, key, val)
			}

			res, err := serv.Retrieve(ctx, req)
			if err != nil {
				http.Error(w, "unable to handle request", http.StatusInternalServerError)
				log.Printf("[ERROR] error handling request: %v", err)
				return
			}

			out, err := json.Marshal(res)
			if err != nil {
				http.Error(w, "unable to encode response", http.StatusInternalServerError)
				log.Printf("[ERROR] error marshaling response: %v", err)
				return
			}

			w.Write(out)

		default:
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		}
	})
}

// MountQueryService add a handler to a Gorilla Mux Router that will route
// an incoming request through the service.QueryService service.
func MountQueryService(router *mux.Router, serv QueryServiceContract) {
	log.Print("[INFO] mounting service.QueryService on /api/query endpoint")
	router.HandleFunc("/api/query", func(w http.ResponseWriter, r *http.Request) {
		session, err := store.Get(r, "main")
		if err != nil {
			http.Error(w, "unable to read request data", http.StatusInternalServerError)
			log.Printf("[ERROR] error getting session: %v", err)
			return
		}

		switch r.Method {

		case "GET":
			req := r.URL.Query()

			ctx := context.Background()
			for key, val := range session.Values {
				ctx = context.WithValue(ctx, key, val)
			}

			res, err := serv.Schema(ctx, req)
			if err != nil {
				http.Error(w, "unable to handle request", http.StatusInternalServerError)
				log.Printf("[ERROR] error handling request: %v", err)
				return
			}

			out, err := json.Marshal(res)
			if err != nil {
				http.Error(w, "unable to encode response", http.StatusInternalServerError)
				log.Printf("[ERROR] error marshaling response: %v", err)
				return
			}

			w.Write(out)

		case "POST":
			req := &service.QueryExecuteRequest{}
			defer r.Body.Close()
			data, err := ioutil.ReadAll(r.Body)
			if err != nil {
				http.Error(w, "unable to read request body", http.StatusBadRequest)
				log.Printf("[ERROR] error reading request body: %v", err)
				return
			}

			if err = json.Unmarshal(data, req); err != nil {
				http.Error(w, "unable to decode request", http.StatusBadRequest)
				log.Printf("[ERROR] error unmarshaling request: %v", err)
				return
			}

			ctx := context.Background()
			for key, val := range session.Values {
				ctx = context.WithValue(ctx, key, val)
			}

			res, err := serv.Query(ctx, req)
			if err != nil {
				http.Error(w, "unable to handle request", http.StatusInternalServerError)
				log.Printf("[ERROR] error handling request: %v", err)
				return
			}

			out, err := json.Marshal(res)
			if err != nil {
				http.Error(w, "unable to encode response", http.StatusInternalServerError)
				log.Printf("[ERROR] error marshaling response: %v", err)
				return
			}

			w.Write(out)

		default:
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		}
	})
}

// MountShorthandService add a handler to a Gorilla Mux Router that will route
// an incoming request through the service.ShorthandService service.
func MountShorthandService(router *mux.Router, serv ShorthandServiceContract) {
	log.Print("[INFO] mounting service.ShorthandService on /api/shorthands endpoint")
	router.HandleFunc("/api/shorthands", func(w http.ResponseWriter, r *http.Request) {
		session, err := store.Get(r, "main")
		if err != nil {
			http.Error(w, "unable to read request data", http.StatusInternalServerError)
			log.Printf("[ERROR] error getting session: %v", err)
			return
		}

		switch r.Method {

		case "POST":
			req := &service.ShorthandCreateRequest{}
			defer r.Body.Close()
			data, err := ioutil.ReadAll(r.Body)
			if err != nil {
				http.Error(w, "unable to read request body", http.StatusBadRequest)
				log.Printf("[ERROR] error reading request body: %v", err)
				return
			}

			if err = json.Unmarshal(data, req); err != nil {
				http.Error(w, "unable to decode request", http.StatusBadRequest)
				log.Printf("[ERROR] error unmarshaling request: %v", err)
				return
			}

			ctx := context.Background()
			for key, val := range session.Values {
				ctx = context.WithValue(ctx, key, val)
			}

			res, err := serv.Create(ctx, req)
			if err != nil {
				http.Error(w, "unable to handle request", http.StatusInternalServerError)
				log.Printf("[ERROR] error handling request: %v", err)
				return
			}

			out, err := json.Marshal(res)
			if err != nil {
				http.Error(w, "unable to encode response", http.StatusInternalServerError)
				log.Printf("[ERROR] error marshaling response: %v", err)
				return
			}

			w.Write(out)

		default:
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		}
	})
}
