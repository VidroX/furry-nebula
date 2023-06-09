package user

import (
	"errors"

	nebula_errors "github.com/VidroX/furry-nebula/errors"
	"github.com/VidroX/furry-nebula/services/translator"
)

var (
	mainErrorCode            = "errors.2."
	ErrUserNotFound          = nebula_errors.APIError{Code: mainErrorCode + "1", Error: errors.New(translator.KeysUserServiceErrorsNotFound)}
	ErrUserAlreadyRegistered = nebula_errors.APIError{Code: mainErrorCode + "2", Error: errors.New(translator.KeysUserServiceErrorsAlreadyRegistered)}
)
