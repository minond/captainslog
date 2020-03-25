package internal

import (
	"log"
	"net/http"

	opentracing "github.com/opentracing/opentracing-go"
	jaegerConfig "github.com/uber/jaeger-client-go/config"
)

func InitGlobalTracer(appName string) {
	config, err := jaegerConfig.FromEnv()
	if err != nil {
		log.Printf("jaeger setup error: %v", err)
		return
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
