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

	"github.com/dgrijalva/jwt-go"
	"github.com/dgrijalva/jwt-go/request"
	"github.com/gorilla/mux"
	"github.com/gorilla/sessions"
	"github.com/spf13/cobra"

	"github.com/minond/captainslog/assets"
	"github.com/minond/captainslog/httpmount"
	"github.com/minond/captainslog/model"
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

func indexHandler(w http.ResponseWriter, r *http.Request) {
	serve(w, r, "index.tmpl", PageConfig{})
}

func loginHandler(sessionTokenSecret []byte, userService *service.UserService) func(http.ResponseWriter, *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			return
		}

		log.Printf("[INFO] %s %s", r.Method, r.URL.String())

		buildSessionToken := func(user *model.User) (string, error) {
			claims := jwt.MapClaims{"uid": user.GUID}
			token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
			return token.SignedString(sessionTokenSecret)
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

		sessionToken, err := buildSessionToken(user)
		if err != nil {
			http.Redirect(w, r, "/", http.StatusTemporaryRedirect)
			return
		}

		serve(w, r, "index.tmpl", PageConfig{Token: sessionToken})
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
		router.Use(func(next http.Handler) http.Handler {
			return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				log.Printf("[INFO] %s %s", r.Method, r.URL.String())
				next.ServeHTTP(w, r)
			})
		})

		router.PathPrefix("/static").
			Methods(http.MethodGet).
			Handler(http.StripPrefix("/static/", http.FileServer(dist)))
		router.PathPrefix("/").
			Methods(http.MethodPost).
			HandlerFunc(loginHandler(sessionTokenSecret, userService))
		router.PathPrefix("/").
			Methods(http.MethodGet).
			HandlerFunc(indexHandler)

		authenticated := router.NewRoute().Subrouter()
		authenticated.Use(func(next http.Handler) http.Handler {
			return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				token, err := request.ParseFromRequest(
					r,
					request.AuthorizationHeaderExtractor,
					func(t *jwt.Token) (interface{}, error) {
						return sessionTokenSecret, nil
					})
				if err == nil && token != nil {
					claims, ok := token.Claims.(jwt.MapClaims)
					if ok {
						session, _ := store.Get(r, "main")
						session.Values["uid"] = claims["uid"]
						_ = session.Save(r, w)
					}
				}

				next.ServeHTTP(w, r)
			})
		})

		httpmount.MountBookService(authenticated, bookService)
		httpmount.MountEntryService(authenticated, entryService)
		httpmount.MountExtractorService(authenticated, extractorService)
		httpmount.MountQueryService(authenticated, queryService)
		httpmount.MountReportService(authenticated, reportService)
		httpmount.MountSavedQueryService(authenticated, savedQueryService)
		httpmount.MountShorthandService(authenticated, shorthandService)

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
