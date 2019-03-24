package main

import (
	"encoding/json"
	"errors"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"

	"github.com/google/uuid"

	capl "github.com/minond/captainslog/server/log"
)

var memDB map[string]*capl.Book
var memUser = capl.User{Guid: "123"}

func init() {
	extractors := []*capl.Extractor{
		{Label: "exercise", Match: `^(.+),`},
		{Label: "sets", Match: `,\s{0,}(\d+)\s{0,}x`},
		{Label: "reps", Match: `x\s{0,}(\d+)\s{0,}@`},
		{Label: "weight", Match: `@\s{0,}(\d+)$`},
		{Label: "time", Match: `(\d+\s{0,}(s|sec|second|seconds|m|min|minute|minutes|h|hour|hours))`},
	}

	memDB = make(map[string]*capl.Book)
	memDB[memUser.Guid] = &capl.Book{
		Guid:      uuid.New().String(),
		Name:      "Workouts",
		Grouping:  capl.Grouping_DAY,
		Extractor: extractors,
	}
}

func createEntry(buff io.Reader) (*capl.EntryCreateResponse, error) {
	res := &capl.EntryCreateResponse{}
	data, err := ioutil.ReadAll(buff)
	if err != nil {
		return nil, err
	}

	var ll capl.EntryCreateRequest
	err = json.Unmarshal(data, &ll)
	if err != nil {
		return nil, err
	}

	book, ok := memDB[memUser.Guid]
	if !ok {
		return nil, errors.New("unable to find book")
	}

	group := book.CurrentGroup()
	if group == nil {
		return nil, errors.New("unable to find current group")
	}

	entry := capl.NewEntry(ll.Text)
	group.Entry = append(group.Entry, entry)
	res.Guid = ll.Guid
	res.Entry = entry
	return res, nil
}

func main() {
	http.HandleFunc("/api/entry", func(w http.ResponseWriter, r *http.Request) {
		log.Print("processing request")

		if r.Method == http.MethodPost {
			defer r.Body.Close()
			res, err := createEntry(r.Body)
			if err != nil {
				log.Printf("error creating entry: %v", err)
				return
			}

			resdata, err := json.Marshal(res)
			if err != nil {
				log.Printf("error encoding response: %v", err)
				return
			}

			w.Write(resdata)
		}
	})

	listen := os.Getenv("LISTEN")
	if listen == "" {
		listen = ":8001"
	}

	log.Printf("listening on %s", listen)
	log.Fatal(http.ListenAndServe(listen, nil))
}
