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

var memDB map[string]*capl.LogBook
var memUser = capl.User{Guid: "123"}

func init() {
	extractors := []*capl.Extractor{
		{Label: "exercise", Match: `^(.+),`},
		{Label: "sets", Match: `,\s{0,}(\d+)\s{0,}x`},
		{Label: "reps", Match: `x\s{0,}(\d+)\s{0,}@`},
		{Label: "weight", Match: `@\s{0,}(\d+)$`},
		{Label: "time", Match: `(\d+\s{0,}(s|sec|second|seconds|m|min|minute|minutes|h|hour|hours))`},
	}

	memDB = make(map[string]*capl.LogBook)
	memDB[memUser.Guid] = &capl.LogBook{
		Guid:      uuid.New().String(),
		Name:      "Workouts",
		Grouping:  capl.Grouping_DAY,
		Extractor: extractors,
	}
}

func createLog(buff io.Reader) (*capl.LogCreateResponse, error) {
	res := &capl.LogCreateResponse{}
	data, err := ioutil.ReadAll(buff)
	if err != nil {
		return nil, err
	}

	var ll capl.LogCreateRequest
	err = json.Unmarshal(data, &ll)
	if err != nil {
		return nil, err
	}

	book, ok := memDB[memUser.Guid]
	if !ok {
		return nil, errors.New("unable to find log book")
	}

	group := book.CurrentGroup()
	if group == nil {
		return nil, errors.New("unable to find current group")
	}

	newLog := capl.NewLog(ll.Text)
	group.Log = append(group.Log, newLog)
	res.Guid = ll.Guid
	res.Log = newLog
	return res, nil
}

func main() {
	http.HandleFunc("/api/log", func(w http.ResponseWriter, r *http.Request) {
		log.Print("processing request")

		if r.Method == http.MethodPost {
			defer r.Body.Close()
			res, err := createLog(r.Body)
			if err != nil {
				log.Printf("error creating log: %v", err)
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
