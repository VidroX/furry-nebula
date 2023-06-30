package graph

import (
	"context"

	"github.com/99designs/gqlgen/graphql"
	nebulaErrors "github.com/VidroX/furry-nebula/errors"
	"github.com/VidroX/furry-nebula/services/translator"
	"github.com/vektah/gqlparser/v2/gqlerror"
)

func FormatError(localizer *translator.NebulaLocalizer, err *nebulaErrors.APIError) *gqlerror.Error {
	extensions := map[string]interface{}{
		"errCode": err.Code,
	}

	if err.CustomInfo != nil && len(err.CustomInfo) > 0 {
		for key, value := range err.CustomInfo {
			extensions[key] = value
		}
	}

	return &gqlerror.Error{
		Message:    translator.WithKey(err.Error.Error()).Translate(localizer),
		Extensions: extensions,
	}
}

func ProcessErrorsSlice(ctx *context.Context, localizer *translator.NebulaLocalizer, errors []*nebulaErrors.APIError) {
	for _, err := range errors {
		graphql.AddError(*ctx, FormatError(localizer, err))
	}
}
