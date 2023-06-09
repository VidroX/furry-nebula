package errors

var UnknownErrorCode = "errors.unknown"

type APIError struct {
	Code  string
	Error error
}
