package internal

import (
	"context"
	"net/http"
	"testing"
)

func parseRequestHandler(ctx context.Context, req *Request) (interface{}, error) {
	if err := req.Unmarshal(&struct {
		Count int `json:"count"`
	}{}); err != nil {
		return nil, err
	}
	return nil, nil
}

func TestServer_Error_BadJSON(t *testing.T) {
	rr := makeRequest(t, ``, parseRequestHandler)
	assertEqual(t, http.StatusBadRequest, rr.Code)
	assertEqual(t, `{"error":"unable to parse request body"}`, rr.Body.String())
}

func TestServer_Error_GoodJSON(t *testing.T) {
	rr := makeRequest(t, `{"count":1}`, parseRequestHandler)
	assertEqual(t, http.StatusOK, rr.Code)
	assertEqual(t, `{}`, rr.Body.String())
}

func TestServer_AddGetterSetter(t *testing.T) {
	server, _ := NewServer(nil)
	server.SetAddr("xs")
	assertEqual(t, "xs", server.Addr())
}
