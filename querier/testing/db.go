package testing

import (
	txdb "github.com/DATA-DOG/go-txdb"
)

func init() {
	txdb.Register("txdb", "postgres", "testconn")
}
