package main

import (
	"errors"
	"net/http"
	"testing"
)

func TestService_Error_BadJSON(t *testing.T) {
	rr := makeRequest(t, ``, nil)
	assertEqual(t, http.StatusBadRequest, rr.Code)
	assertEqual(t, `{"message":"unable to parse request body"}`, rr.Body.String())
}

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

func TestService_Error_ExtractorLookup(t *testing.T) {
	rr := makeRequest(t, `{"text":"hi","book_id":2}`, &testRepository{
		extractorLookupError: errors.New("bad"),
	})
	assertEqual(t, http.StatusInternalServerError, rr.Code)
	assertEqual(t, `{"message":"unable to find extractors"}`, rr.Body.String())
}

func TestService_Error_ShorhandLookup(t *testing.T) {
	rr := makeRequest(t, `{"text":"hi","book_id":2}`, &testRepository{
		shorthandLookupError: errors.New("bad"),
	})
	assertEqual(t, http.StatusInternalServerError, rr.Code)
	assertEqual(t, `{"message":"unable to find shorthands"}`, rr.Body.String())
}

func TestService_HappyPath_ServeHTTP(t *testing.T) {
	rr := makeRequest(t, `{"text":"hi","book_id":2}`, &testRepository{})
	assertEqual(t, http.StatusOK, rr.Code)
	assertEqual(t, `{"text":"hi"}`, rr.Body.String())
}
