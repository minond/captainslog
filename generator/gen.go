//go:generate kallax gen --input ../model
//go:generate go run ../generator/httpmount/main.go -routes ../httpmount/routes.json -output ../httpmount/routes.go -package httpmount

// Package generator is an empty package that holds all of the go:generate
// pragmas. In addition, this is where all of the custom project generators
// live as subpackages.
package generator
