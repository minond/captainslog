package main

import (
	"context"
	"errors"
	"testing"

	internaltesting "github.com/minond/captainslog/querier/testing"
)

func TestService_Error_MissingUserID(t *testing.T) {
	service := NewService(nil)
	req := &QueryRequest{}
	_, err := service.Handle(context.TODO(), req)
	internaltesting.AssertEqual(t, ErrReqMissingUserID, err)
}

func TestService_Error_MissingQuery(t *testing.T) {
	service := NewService(nil)
	req := &QueryRequest{UserID: 1}
	_, err := service.Handle(context.TODO(), req)
	internaltesting.AssertEqual(t, ErrReqMissingQuery, err)
}

func TestService_Error_SyntaxError(t *testing.T) {
	service := NewService(nil)
	req := &QueryRequest{UserID: 1, Query: "selec"}
	_, err := service.Handle(context.TODO(), req)
	internaltesting.AssertEqual(t, ErrQuerySyntax, err)
}

func TestService_Error_QueryExecution(t *testing.T) {
	repo := internaltesting.TestRepository{Err: errors.New("bad")}
	req := &QueryRequest{UserID: 2, Query: "select 1"}
	service := NewService(repo)
	_, err := service.Handle(context.TODO(), req)

	internaltesting.AssertEqual(t, &QueryExecutionError{
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
	repo := internaltesting.TestRepository{
		Cols: columns,
		Rows: results,
	}

	req := &QueryRequest{UserID: 2, Query: "select 1"}
	service := NewService(repo)
	res, err := service.Handle(context.TODO(), req)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	internaltesting.AssertEqual(t, res, &QueryResponse{
		Columns: columns,
		Results: results,
	})
}
