package validation

import (
	"errors"
	"strings"

	nebulaErrors "github.com/VidroX/furry-nebula/errors"
	"github.com/VidroX/furry-nebula/services/translator"
	"github.com/go-playground/validator/v10"
)

var (
	mainErrorCode            = "errors.validation."
	ErrValidationUnknown     = nebulaErrors.APIError{Code: mainErrorCode + "0", Error: errors.New(translator.KeysValidationUnknownError)}
	ErrValidationRequired    = nebulaErrors.APIError{Code: mainErrorCode + "1", Error: errors.New(translator.KeysValidationRequiredError)}
	ErrIncorrectEmail        = nebulaErrors.APIError{Code: mainErrorCode + "2", Error: errors.New(translator.KeysValidationIncorrectEmailError)}
	ErrUserNotFound          = nebulaErrors.APIError{Code: mainErrorCode + "3", Error: errors.New(translator.KeysUserServiceErrorsNotFound)}
	ErrUserAlreadyRegistered = nebulaErrors.APIError{Code: mainErrorCode + "4", Error: errors.New(translator.KeysUserServiceErrorsAlreadyRegistered)}
	ErrChangeOwnStatus       = nebulaErrors.APIError{Code: mainErrorCode + "5", Error: errors.New(translator.KeysUserServiceErrorsChangeOwnStatus)}
	ErrInvalidFileFormat     = nebulaErrors.APIError{Code: mainErrorCode + "6", Error: errors.New(translator.KeysInvalidFileFormat)}
	ErrCorruptedFile         = nebulaErrors.APIError{Code: mainErrorCode + "7", Error: errors.New(translator.KeysCorruptedFile)}
	ErrShelterAlreadyExists  = nebulaErrors.APIError{Code: mainErrorCode + "8", Error: errors.New(translator.KeysShelterServiceShelterAlreadyExists)}
	ErrShelterNotFound       = nebulaErrors.APIError{Code: mainErrorCode + "9", Error: errors.New(translator.KeysShelterServiceShelterNotFound)}
	ErrShelterAnimalNotFound = nebulaErrors.APIError{Code: mainErrorCode + "10", Error: errors.New(translator.KeysShelterServiceShelterAnimalNotFound)}
)

func ConstructValidationError(err nebulaErrors.APIError, field string) *nebulaErrors.APIError {
	if err.CustomInfo == nil {
		err.CustomInfo = make(map[string]interface{})
	}

	err.CustomInfo["field"] = strings.ToLower(field)

	return &err
}

func ProcessValidatorErrors(validatorError error) []*nebulaErrors.APIError {
	var apiErrors []*nebulaErrors.APIError

	if validatorError == nil {
		return apiErrors
	}

	for _, err := range validatorError.(validator.ValidationErrors) {
		switch err.ActualTag() {
		case "email":
			apiErrors = append(apiErrors, ConstructValidationError(ErrIncorrectEmail, err.Field()))
		case "required":
			apiErrors = append(apiErrors, ConstructValidationError(ErrValidationRequired, err.Field()))
		default:
			apiErrors = append(apiErrors, ConstructValidationError(ErrValidationUnknown, err.Field()))
		}
	}

	return apiErrors
}
