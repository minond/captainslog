//go:generate kallax gen --input ../model
//go:generate go run ../generator/service/main.go -routes ../service/routes.json -output ../service/routes.go -package service
package generator
