package main

import (
	"database/sql"
	"os"
)

func database() (*sql.DB, error) {
	return sql.Open(os.Getenv("DATABASE_DRIVER"), os.Getenv("DATABASE_CONN"))
}
