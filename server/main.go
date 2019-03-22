package main

import (
	"encoding/json"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"

	l "github.com/minond/captainslog/server/log"
)

var logs []l.Log

type Response struct {
	Ok  bool   `json:"ok"`
	Msg string `json:"msg"`
}

func saveLog(buff io.Reader) error {
	data, err := ioutil.ReadAll(buff)
	if err != nil {
		return err
	}

	var ll l.LogCreateRequest
	err = json.Unmarshal(data, &ll)
	if err != nil {
		return err
	}

	logs = append(logs, l.NewLog(ll.Text))
	return nil
}

func main() {
	http.HandleFunc("/api/log", func(w http.ResponseWriter, r *http.Request) {
		var res Response
		log.Print("processing request")

		switch r.Method {
		case http.MethodPost:
			defer r.Body.Close()
			err := saveLog(r.Body)
			if err != nil {
				res.Ok = false
				res.Msg = err.Error()
			} else {
				res.Ok = true
			}

		default:
			res.Ok = false
		}

		resdata, err := json.Marshal(res)
		if err != nil {
			log.Printf("error encoding response: %v", err)
		}
		w.Write(resdata)
	})

	listen := os.Getenv("LISTEN")
	if listen == "" {
		listen = ":8001"
	}

	log.Printf("listening on %s", listen)
	log.Fatal(http.ListenAndServe(listen, nil))
}
