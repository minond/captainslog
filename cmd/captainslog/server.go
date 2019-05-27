package main

import (
	"log"
	"net/http"
	"os"

	"github.com/gorilla/mux"
	"github.com/gorilla/sessions"
	"github.com/spf13/cobra"

	"github.com/minond/captainslog/assets"
	"github.com/minond/captainslog/httpmount"
	"github.com/minond/captainslog/service"
)

var dist = assets.Dir("./client/web/dist/")

var cmdServer = &cobra.Command{
	Use:   "server",
	Short: "Run application server",
	Run: func(cmd *cobra.Command, args []string) {
		log.Print("[INFO] initializing server")
		db, err := database()
		if err != nil {
			log.Fatalf("[ERROR] error opening database connection: %v", err)
		}
		defer db.Close()

		router := mux.NewRouter()

		bookService := service.NewBookService(db)
		entryService := service.NewEntryService(db)
		extractorService := service.NewExtractorService(db)
		queryService := service.NewQueryService(db)
		shorthandService := service.NewShorthandService(db)

		// TODO add real sessions with real auth
		store := sessions.NewCookieStore([]byte(os.Getenv("SESSION_KEY")))
		router.Use(func(next http.Handler) http.Handler {
			return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				log.Printf("[INFO] %s %s", r.Method, r.URL.String())
				session, _ := store.Get(r, "main")
				session.Values["userguid"] = "e26e269c-0587-4094-bf01-108c61b0fa8a"
				_ = session.Save(r, w)
				next.ServeHTTP(w, r)
			})
		})

		httpmount.MountBookService(router, bookService)
		httpmount.MountEntryService(router, entryService)
		httpmount.MountExtractorService(router, extractorService)
		httpmount.MountQueryService(router, queryService)
		httpmount.MountShorthandService(router, shorthandService)

		router.PathPrefix("/static").Handler(http.StripPrefix("/static/", http.FileServer(dist)))
		router.PathPrefix("/").HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			index, err := dist.Open("index.html")
			if err != nil || index == nil {
				w.WriteHeader(http.StatusNotFound)
				return
			}
			stat, _ := index.Stat()
			http.ServeContent(w, r, "index.html", stat.ModTime(), index)
		})

		listen := os.Getenv("LISTEN")
		log.Printf("[INFO] listening on `%s`", listen)
		log.Fatal(http.ListenAndServe(listen, router))
	},
}
