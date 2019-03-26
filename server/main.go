package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
	"os"

	"github.com/minond/captainslog/server/proto"
	"github.com/minond/captainslog/server/service"
)

func main() {
	db, err := sql.Open(os.Getenv("DATABASE_DRIVER"), os.Getenv("DATABASE_CONN"))
	if err != nil {
		log.Fatalf("error opening database connection: %v", err)
	}
	defer db.Close()

	entryService := service.NewEntryService(db)

	http.HandleFunc("/api/entry", func(w http.ResponseWriter, r *http.Request) {
		switch r.Method {
		case http.MethodPost:
			log.Print("POST /api/entry")
			defer r.Body.Close()
			data, err := ioutil.ReadAll(r.Body)
			if err != nil {
				log.Printf("error reading request body: %v", err)
				return
			}

			req := &proto.EntryCreateRequest{}
			if err = json.Unmarshal(data, req); err != nil {
				log.Printf("error unmarshaling request: %v", err)
				return
			}

			res, err := entryService.Create(context.Background(), req)
			if err != nil {
				log.Printf("error handling request: %v", err)
				return
			}

			out, err := json.Marshal(res)
			if err != nil {
				log.Printf("error marshaling response: %v", err)
				return
			}

			w.Write(out)
		}
	})

	log.Fatal(http.ListenAndServe(os.Getenv("LISTEN"), nil))
}
