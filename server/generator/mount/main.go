package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"go/format"
	"io/ioutil"
	"log"
	"path"
	"strings"
	"text/template"
)

type Routes struct {
	Routes []Route `json:"routes"`
}

type Route struct {
	Endpoint string   `json:"endpoint"`
	Service  string   `json:"service"`
	Methods  []Method `json:"methods"`
}

type Method struct {
	Method  string `json:"method"`
	Request string `json:"request"`
}

var (
	routesPath = flag.String("routes", "./service/mount/routes.json", "Path to routes definitions file.")
	outputPath = flag.String("output", "./service/mount/", "Path to output directory.")

	funcs = template.FuncMap{
		"stripPackage": stripPackage,
	}

	handlerTmpl = template.Must(template.New("handler").Funcs(funcs).Parse(`
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

{{range .Routes}}
func Mount{{.Service | stripPackage}}(mux *http.ServeMux, service *{{.Service}}) {
	mux.HandleFunc("{{.Endpoint}}", func(w http.ResponseWriter, r *http.Request) {
		switch r.Method {
		{{range .Methods}}
		case "{{.Method}}":
			defer r.Body.Close()
			data, err := ioutil.ReadAll(r.Body)
			if err != nil {
				log.Printf("error reading request body: %v", err)
				return
			}

			req := &{{.Request}}{}
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
		{{end}}
		}
	})
}
{{end}}
`))
)

func init() {
	flag.Parse()
}

func main() {
	data, err := ioutil.ReadFile(*routesPath)
	if err != nil {
		log.Fatalf("error reading routes file: %v", err)
	}

	routes := &Routes{}
	json.Unmarshal(data, routes)

	buff := &bytes.Buffer{}
	if err = handlerTmpl.Execute(buff, routes); err != nil {
		log.Fatalf("error generating template: %v", err)
	}

	file := path.Join(*outputPath, "autogen.go")
	unformatted := buff.Bytes()
	contents, err := format.Source(unformatted)
	if err != nil {
		log.Fatalf("error formatting contents: %v", err)
	}

	if err = ioutil.WriteFile(path.Join(*outputPath, "autogen.go"), contents, 0644); err != nil {
		log.Fatalf("error writing to file: %v", err)
	}
	log.Printf("wrote %d bytes to %s", len(contents), file)
}

func stripPackage(input string) string {
	parts := strings.SplitN(input, ".", 2)
	return parts[1]
}
