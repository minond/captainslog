package main

import (
	"bytes"
	"context"
	"html/template"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"time"

	"github.com/gorilla/mux"
	"github.com/spf13/cobra"

	"github.com/minond/captainslog/assets"
	"github.com/minond/captainslog/httpmount"
	"github.com/minond/captainslog/service"
)

var dist = assets.Dir("./client/web/dist/")

type PageConfig struct {
	Token string
}

func serve(w http.ResponseWriter, r *http.Request, page string, config PageConfig) {
	handle, err := dist.Open(page)
	if err != nil || handle == nil {
		w.WriteHeader(http.StatusNotFound)
		return
	}

	stat, _ := handle.Stat()
	w.Header().Set("Content-Type", "text/html")
	w.Header().Set("Last-Modified", stat.ModTime().UTC().Format(http.TimeFormat))
	w.WriteHeader(http.StatusOK)

	if strings.HasSuffix(page, ".tmpl") {
		buff := &bytes.Buffer{}
		content, _ := ioutil.ReadAll(handle)
		tmpl, _ := template.New(page).Parse(string(content))
		tmpl.Execute(buff, config)
		w.Write(buff.Bytes())
	} else {
		io.CopyN(w, handle, stat.Size())
	}
}

func tokenFromRequest(userService *service.UserService, r *http.Request) (string, error) {
	email := r.FormValue("email")
	password := r.FormValue("password")
	req := &service.UserLoginRequest{
		Email:         email,
		PlainPassword: password,
	}

	session, err := userService.GenerateToken(context.Background(), req)
	if err != nil {
		return "", err
	}
	return session.Token, nil
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
	serve(w, r, "index.tmpl", PageConfig{})
}

func loginHandler(userService *service.UserService) func(http.ResponseWriter, *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			return
		}

		token, err := tokenFromRequest(userService, r)
		if err != nil {
			http.Redirect(w, r, "/", http.StatusTemporaryRedirect)
			return
		}

		serve(w, r, "index.tmpl", PageConfig{Token: token})
	}
}

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
		router.Use(func(next http.Handler) http.Handler {
			return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				log.Printf("[INFO] %s %s", r.Method, r.URL.String())

				session, err := userService.ExtractSessionFromRequest(r)
				if err == nil {
					uid := context.WithValue(r.Context(), "uid", session.UID)
					next.ServeHTTP(w, r.WithContext(uid))
					return
				}

				next.ServeHTTP(w, r)
			})
		})

		httpmount.MountBookService(router, bookService)
		httpmount.MountEntryService(router, entryService)
		httpmount.MountExtractorService(router, extractorService)
		httpmount.MountQueryService(router, queryService)
		httpmount.MountReportService(router, reportService)
		httpmount.MountSavedQueryService(router, savedQueryService)
		httpmount.MountShorthandService(router, shorthandService)

		router.PathPrefix("/static").
			Methods(http.MethodGet).
			Handler(http.StripPrefix("/static/", http.FileServer(dist)))
		router.PathPrefix("/").
			Methods(http.MethodPost).
			HandlerFunc(loginHandler(userService))
		router.PathPrefix("/").
			Methods(http.MethodGet).
			HandlerFunc(indexHandler)

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
