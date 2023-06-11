package general

import (
	"errors"

	nebula_errors "github.com/VidroX/furry-nebula/errors"
	"github.com/VidroX/furry-nebula/services/translator"
)

var (
	mainErrorCode            = "errors.1."
	ErrInternal              = nebula_errors.APIError{Code: mainErrorCode + "1", Error: errors.New(translator.KeysInternalError)}
	ErrNotEnoughPermissions  = nebula_errors.APIError{Code: mainErrorCode + "2", Error: errors.New(translator.KeysNotEnoughPermissions)}
	ErrInvalidOrExpiredToken = nebula_errors.APIError{Code: mainErrorCode + "3", Error: errors.New(translator.KeysInvalidOrExpiredTokenError)}
)
