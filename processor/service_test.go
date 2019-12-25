package main

import (
	"net/http"
	"testing"
)

func TestService_Error_MissingText(t *testing.T) {
	rr := makeRequest(t, `{}`, nil)
	assertEqual(t, http.StatusBadRequest, rr.Code)
	assertEqual(t, `{"message":"missing text in request"}`, rr.Body.String())
}

func TestService_Error_MissingBookID(t *testing.T) {
	rr := makeRequest(t, `{"text":"hi"}`, nil)
	assertEqual(t, http.StatusBadRequest, rr.Code)
	assertEqual(t, `{"message":"missing book id in request"}`, rr.Body.String())
}
