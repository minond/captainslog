package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"time"

	"github.com/gorilla/mux"
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

		bookService := service.NewBookService(db)
		entryService := service.NewEntryService(db)
		extractorService := service.NewExtractorService(db)
		queryService := service.NewQueryService(db)
		reportService := service.NewReportService(db)
		savedQueryService := service.NewSavedQueryService(db)
		shorthandService := service.NewShorthandService(db)
		userService := service.NewUserService(db)

		router := mux.NewRouter()
		router.HandleFunc("/login", func(w http.ResponseWriter, r *http.Request) {
			if r.Method != http.MethodPost {
				return
			}

			log.Printf("[INFO] %s %s", r.Method, r.URL.String())

			email := r.FormValue("email")
			password := r.FormValue("password")
			req := &service.UserLoginRequest{
				Email:         email,
				PlainPassword: password,
			}

			if req.Valid() {
				user, err := userService.Login(context.Background(), req)
				if err == nil && user != nil {
					println("ok!")
				}
			}
		})

		httpmount.MountBookService(router, bookService)
		httpmount.MountEntryService(router, entryService)
		httpmount.MountExtractorService(router, extractorService)
		httpmount.MountQueryService(router, queryService)
		httpmount.MountReportService(router, reportService)
		httpmount.MountSavedQueryService(router, savedQueryService)
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
		server := http.Server{
			Addr:    listen,
			Handler: router,
		}

		log.Printf("[INFO] listening on `%s`", listen)

		go func() {
			if err := server.ListenAndServe(); err != nil {
				log.Fatal(err)
			}
		}()

		stopper := make(chan os.Signal, 1)
		signal.Notify(stopper, os.Interrupt)

		<-stopper
		log.Print("[INFO] shutting server down")
		ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
		defer cancel()
		_ = server.Shutdown(ctx)
		log.Print("[INFO] server shut down")
	},
}
