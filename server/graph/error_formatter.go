package graph

import (
	nebula_errors "github.com/VidroX/furry-nebula/errors"
	"github.com/VidroX/furry-nebula/services/translator"
	"github.com/vektah/gqlparser/v2/gqlerror"
)

func FormatError(localizer *translator.NebulaLocalizer, err *nebula_errors.APIError) *gqlerror.Error {
	return &gqlerror.Error{
		Message: translator.WithKey(err.Error.Error()).Translate(localizer),
		Extensions: map[string]interface{}{
			"errCode": err.Code,
		},
	}
}
