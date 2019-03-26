package mount

import (
	"context"
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"

	"github.com/minond/captainslog/server/proto"
	"github.com/minond/captainslog/server/service"
)

func MountEntryService(mux *http.ServeMux, service *service.EntryService) {
	mux.HandleFunc("/api/entry", func(w http.ResponseWriter, r *http.Request) {
		switch r.Method {

		case "POST":
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

			res, err := service.Create(context.Background(), req)
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
}
