package validation

import (
	"errors"

	nebula_errors "github.com/VidroX/furry-nebula/errors"
	"github.com/VidroX/furry-nebula/services/translator"
	"github.com/go-playground/validator/v10"
)

var (
	mainErrorCode            = "errors.validation."
	ErrValidationUnknown     = nebula_errors.APIError{Code: mainErrorCode + "0", Error: errors.New(translator.KeysValidationUnknownError)}
	ErrValidationRequired    = nebula_errors.APIError{Code: mainErrorCode + "1", Error: errors.New(translator.KeysValidationRequiredError)}
	ErrIncorrectEmail        = nebula_errors.APIError{Code: mainErrorCode + "2", Error: errors.New(translator.KeysValidationIncorrectEmailError)}
	ErrUserNotFound          = nebula_errors.APIError{Code: mainErrorCode + "3", Error: errors.New(translator.KeysUserServiceErrorsNotFound)}
	ErrUserAlreadyRegistered = nebula_errors.APIError{Code: mainErrorCode + "4", Error: errors.New(translator.KeysUserServiceErrorsAlreadyRegistered)}
)

func ConstructValidationError(err nebula_errors.APIError, field string) *nebula_errors.APIError {
	if err.CustomInfo == nil {
		err.CustomInfo = make(map[string]interface{})
	}

	err.CustomInfo["field"] = field

	return &err
}

func ProcessValidatorErrors(validatorError error) []*nebula_errors.APIError {
	errors := []*nebula_errors.APIError{}

	if validatorError == nil {
		return errors
	}

	for _, err := range validatorError.(validator.ValidationErrors) {
		switch err.ActualTag() {
		case "email":
			errors = append(errors, ConstructValidationError(ErrIncorrectEmail, err.Field()))
		case "required":
			errors = append(errors, ConstructValidationError(ErrValidationRequired, err.Field()))
		default:
			errors = append(errors, ConstructValidationError(ErrValidationUnknown, err.Field()))
		}
	}

	return errors
}
