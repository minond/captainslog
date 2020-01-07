package main

import (
	"context"
	"errors"
	"testing"
)

func TestService_Error_MissingUserID(t *testing.T) {
	service := NewService(nil)
	req := &QueryRequest{}
	_, err := service.Handle(context.TODO(), req)
	assertEqual(t, ErrReqMissingUserID, err)
}

func TestService_Error_MissingQuery(t *testing.T) {
	service := NewService(nil)
	req := &QueryRequest{UserID: 1}
	_, err := service.Handle(context.TODO(), req)
	assertEqual(t, ErrReqMissingQuery, err)
}

func TestService_Error_SyntaxError(t *testing.T) {
	service := NewService(nil)
	req := &QueryRequest{UserID: 1, Query: "selec"}
	_, err := service.Handle(context.TODO(), req)
	assertEqual(t, ErrQuerySyntax, err)
}

func TestService_Error_QueryExecution(t *testing.T) {
	repo := testRepository{err: errors.New("bad")}
	req := &QueryRequest{UserID: 2, Query: "select 1"}
	service := NewService(repo)
	_, err := service.Handle(context.TODO(), req)

	assertEqual(t, &QueryExecutionError{
		Query: "select 1",
		Err:   errors.New("bad"),
	}, err)
}

var (
	columns = []string{"one", "two"}
	results = [][]interface{}{
		{"1", "2"},
		{"3", "4"},
	}
)

func TestService_HappyPath(t *testing.T) {
	repo := testRepository{
		cols: columns,
		rows: results,
	}

	req := &QueryRequest{UserID: 2, Query: "select 1"}
	service := NewService(repo)
	res, err := service.Handle(context.TODO(), req)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	assertEqual(t, res, &QueryResponse{
		Columns: columns,
		Results: results,
	})
}
