package main

import (
	"bytes"
	"net/http"
	"net/http/httptest"
	"testing"
)

func makeRequest(t *testing.T, rawBody string) *httptest.ResponseRecorder {
	body := bytes.NewBufferString(rawBody)
	req, err := http.NewRequest(http.MethodPost, "/", body)
	if err != nil {
		t.Fatalf("unexpected error from http.NewRequest: %v", err)
	}

	rr := httptest.NewRecorder()
	service := NewService(nil)
	service.ServeHTTP(rr, req)

	return rr
}

func TestService_Error_MissingText(t *testing.T) {
	rr := makeRequest(t, `{}`)
	assertEqual(t, http.StatusBadRequest, rr.Code)
	assertEqual(t, `{"message":"missing text in request"}`, rr.Body.String())
}

func TestService_Error_MissingBookID(t *testing.T) {
	rr := makeRequest(t, `{"text":"hi"}`)
	assertEqual(t, http.StatusBadRequest, rr.Code)
	assertEqual(t, `{"message":"missing book id in request"}`, rr.Body.String())
}
