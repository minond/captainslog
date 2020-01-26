package main

import "os"

type Config struct {
	dbConn     string
	dbDriver   string
	httpListen string
}

func ConfigFromEnv() Config {
	return Config{
		dbConn:     os.Getenv("QUERIER_DB_CONN"),
		httpListen: os.Getenv("QUERIER_HTTP_LISTEN"),
	}
}
