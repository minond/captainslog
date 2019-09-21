package main

import (
	"context"
	"io"
	"log"
	"net/http"
	"os"
	"os/signal"
	"time"

	jwt "github.com/dgrijalva/jwt-go"
	"github.com/gorilla/mux"
	"github.com/gorilla/sessions"
	"github.com/spf13/cobra"

	"github.com/minond/captainslog/assets"
	"github.com/minond/captainslog/httpmount"
	"github.com/minond/captainslog/model"
	"github.com/minond/captainslog/service"
)

var dist = assets.Dir("./client/web/dist/")

func serve(w http.ResponseWriter, r *http.Request, page string) {
	content, err := dist.Open(page)
	if err != nil || content == nil {
		w.WriteHeader(http.StatusNotFound)
		return
	}

	stat, _ := content.Stat()
	w.Header().Set("Content-Type", "text/html")
	w.Header().Set("Last-Modified", stat.ModTime().UTC().Format(http.TimeFormat))
	w.WriteHeader(http.StatusOK)
	io.CopyN(w, content, stat.Size())
}

func loginHandler(sessionTokenSecret []byte, userService *service.UserService) func(http.ResponseWriter, *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			return
		}

		log.Printf("[INFO] %s %s", r.Method, r.URL.String())

		buildSessionCookie := func(user *model.User) (*http.Cookie, error) {
			claims := jwt.MapClaims{"uid": user.GUID}
			token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
			signed, err := token.SignedString(sessionTokenSecret)
			if err != nil {
				return nil, err
			}
			return &http.Cookie{
				Name:     "sess",
				Value:    signed,
				HttpOnly: true,
			}, nil
		}

		email := r.FormValue("email")
		password := r.FormValue("password")
		req := &service.UserLoginRequest{
			Email:         email,
			PlainPassword: password,
		}

		if !req.Valid() {
			http.Redirect(w, r, "/", http.StatusTemporaryRedirect)
			return
		}

		user, err := userService.Login(context.Background(), req)
		if err != nil || user == nil {
			http.Redirect(w, r, "/", http.StatusTemporaryRedirect)
			return
		}

		_, err = buildSessionCookie(user)
		if err != nil {
			http.Redirect(w, r, "/", http.StatusTemporaryRedirect)
			return
		}

		http.Redirect(w, r, "/", http.StatusTemporaryRedirect)
		serve(w, r, "index.html")
	}
}

var cmdServer = &cobra.Command{
	Use:   "server",
	Short: "Run application server",
	Run: func(cmd *cobra.Command, args []string) {
		sessionTokenSecret := []byte(os.Getenv("SESSION_TOKEN_SECRET"))
		if len(sessionTokenSecret) == 0 {
			panic("SESSION_TOKEN_SECRET is required")
		}

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

		store := sessions.NewCookieStore([]byte(os.Getenv("SESSION_KEY")))
		router := mux.NewRouter()

		// TODO Once authentication is complete remove this
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
		httpmount.MountReportService(router, reportService)
		httpmount.MountSavedQueryService(router, savedQueryService)
		httpmount.MountShorthandService(router, shorthandService)

		router.HandleFunc("/login", loginHandler(sessionTokenSecret, userService))
		router.PathPrefix("/static").Handler(http.StripPrefix("/static/", http.FileServer(dist)))
		router.PathPrefix("/").HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			serve(w, r, "index.html")
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
