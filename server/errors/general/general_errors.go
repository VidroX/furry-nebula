package general

import (
	"errors"

	nebulaErrors "github.com/VidroX/furry-nebula/errors"
	"github.com/VidroX/furry-nebula/services/translator"
)

var (
	mainErrorCode               = "errors.1."
	ErrInternal                 = nebulaErrors.APIError{Code: mainErrorCode + "1", Error: errors.New(translator.KeysInternalError)}
	ErrNotEnoughPermissions     = nebulaErrors.APIError{Code: mainErrorCode + "2", Error: errors.New(translator.KeysNotEnoughPermissions)}
	ErrInvalidOrExpiredToken    = nebulaErrors.APIError{Code: mainErrorCode + "3", Error: errors.New(translator.KeysInvalidOrExpiredTokenError)}
	ErrAccommodationNeededFirst = nebulaErrors.APIError{Code: mainErrorCode + "4", Error: errors.New(translator.KeysShelterServiceAccommodationNeededToRate)}
)
