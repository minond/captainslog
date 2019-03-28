//go:generate kallax gen --input model -e entry_ext.go
//go:generate go run generator/mount/main.go -routes service/mount/routes.json -output service/mount/autogen.go
package main

import (
	"database/sql"
	"log"
	"net/http"
	"os"

	"github.com/gorilla/mux"

	"github.com/minond/captainslog/server/service"
	"github.com/minond/captainslog/server/service/mount"
)

func main() {
	db, err := sql.Open(os.Getenv("DATABASE_DRIVER"), os.Getenv("DATABASE_CONN"))
	if err != nil {
		log.Fatalf("error opening database connection: %v", err)
	}
	defer db.Close()

	router := mux.NewRouter()
	entryService := service.NewEntryService(db)

	mount.MountEntryService(router, entryService)

	http.Handle("/", router)
	log.Fatal(http.ListenAndServe(os.Getenv("LISTEN"), nil))
}
