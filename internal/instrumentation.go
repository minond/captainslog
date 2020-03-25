package internal

import (
	"fmt"
	"log"
	"net/http"
	"os"

	opentracing "github.com/opentracing/opentracing-go"
	jaegerConfig "github.com/uber/jaeger-client-go/config"
)

func InitGlobalTracer(appName string) {
	config, err := jaegerConfig.FromEnv()
	if err != nil {
		log.Printf("jaeger setup error: %v", err)
		return
	}

	host := os.Getenv("JAEGER_HOST")
	port := os.Getenv("JAEGER_PORT")
	if host != "" && port != "" {
		config.Reporter.LocalAgentHostPort = fmt.Sprintf("%s:%d", host, port)
	}

	config.InitGlobalTracer(appName)
}

func extractSpanContextFromRequest(r *http.Request) opentracing.SpanContext {
	textMap := make(map[string]string)
	for header := range r.Header {
		textMap[header] = r.Header.Get(header)
	}

	tracer := opentracing.GlobalTracer()
	carrier := opentracing.TextMapCarrier(textMap)
	spanContext, _ := tracer.Extract(opentracing.TextMap, carrier)

	return spanContext
}
