package graph

import (
	"context"
	"log"

	nebula_errors "github.com/VidroX/furry-nebula/errors"
	general_errors "github.com/VidroX/furry-nebula/errors/general"
	"github.com/VidroX/furry-nebula/graph/model"
	"github.com/VidroX/furry-nebula/repositories"
	"github.com/VidroX/furry-nebula/services/core"
	"github.com/VidroX/furry-nebula/services/jwx"
	"github.com/VidroX/furry-nebula/services/translator"
	"github.com/gin-gonic/gin"
)

type ExtendedContext struct {
	*gin.Context
}

func (ctx *ExtendedContext) RequireUser() (*model.User, *nebula_errors.APIError) {
	user, ok := ctx.Get(jwx.UserContextKey)

	if user == nil || !ok {
		return nil, &general_errors.ErrNotEnoughPermissions
	}

	if _, ok := user.(*model.User); !ok {
		return nil, &general_errors.ErrNotEnoughPermissions
	}

	return user.(*model.User), nil
}

func (ctx *ExtendedContext) GetRepositories() *repositories.Repositories {
	controller, ok := ctx.Get(repositories.Key)

	if controller == nil || !ok {
		log.Panic("Could not retrieve repository")
		return nil
	}

	if _, ok := controller.(*repositories.Repositories); !ok {
		log.Panicf("Expected repositories.Repositories, got %T\n", controller)
		return nil
	}

	return controller.(*repositories.Repositories)
}

func (ctx *ExtendedContext) GetServices() *core.Services {
	services, ok := ctx.Get(core.ServicesKey)

	if services == nil || !ok {
		log.Panic("Could not retrieve services")
		return nil
	}

	if _, ok := services.(*core.Services); !ok {
		log.Panicf("Expected core.Services, got %T\n", services)
		return nil
	}

	return services.(*core.Services)
}

func (ctx *ExtendedContext) GetLocalizer() *translator.NebulaLocalizer {
	contextTranslator, ok := ctx.Get(translator.Key)

	if contextTranslator == nil || !ok {
		log.Panic("Could not retrieve translator")
		return nil
	}

	return contextTranslator.(*translator.NebulaLocalizer)
}

func GetGinContext(ctx context.Context) *ExtendedContext {
	ginContext := ctx.Value("GinContextKey")
	if ginContext == nil {
		log.Panic("Could not retrieve gin.Context")
		return nil
	}

	gc, ok := ginContext.(*gin.Context)
	if !ok {
		log.Panic("gin.Context has wrong type")
		return nil
	}

	return &ExtendedContext{gc}
}
