package main

import (
	"context"
	"net/http"
	"os"

	"github.com/99designs/gqlgen/graphql/handler"
	"github.com/99designs/gqlgen/graphql/handler/transport"
	"github.com/99designs/gqlgen/graphql/playground"
	"github.com/VidroX/furry-nebula/graph"
	resolvers "github.com/VidroX/furry-nebula/graph/resolvers"
	"github.com/VidroX/furry-nebula/repositories"
	"github.com/VidroX/furry-nebula/services/core"
	"github.com/VidroX/furry-nebula/services/database"
	"github.com/VidroX/furry-nebula/services/environment"
	"github.com/VidroX/furry-nebula/services/jwx"
	"github.com/VidroX/furry-nebula/services/translator"
	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"github.com/lestrrat-go/jwx/v2/jwk"
)

type Environment struct {
	validate      *validator.Validate
	controller    *repositories.Repositories
	jwkPrivateKey *jwk.ECDSAPrivateKey
	jwkPublicKey  *jwk.ECDSAPublicKey
	jwkSet        *jwk.Set
}

func main() {
	environment.LoadEnvironment(nil)

	private, public := jwx.InitKeySet()

	loadDatabase()

	controller := repositories.Init()

	keySet := jwk.NewSet()
	keySet.AddKey(public)

	validate := validator.New()

	env := Environment{
		validate:      validate,
		controller:    controller,
		jwkPrivateKey: &private,
		jwkPublicKey:  &public,
		jwkSet:        &keySet,
	}

	r := gin.Default()
	r.Use(GinContextToContextMiddleware())
	r.Use(env.authMiddleware())
	r.Use(env.environmentMiddleware())
	r.Any("/gql", env.graphqlHandler())
	r.GET("/certs", env.certsHandler())

	if os.Getenv(environment.KeysGinMode) != "release" {
		r.GET("/", env.playgroundHandler())
	}

	r.Run()
}

func loadDatabase() {
	gormDB := database.Init()

	gormDB.AutoMigrateAll()
	gormDB.PopulateRoles()
	gormDB.CreateAdminUser()
}

func (env *Environment) graphqlHandler() gin.HandlerFunc {
	c := graph.Config{
		Resolvers:  &resolvers.Resolver{},
		Directives: AppDirectives,
	}

	h := handler.NewDefaultServer(graph.NewExecutableSchema(c))
	h.AddTransport(&transport.Websocket{})

	return func(c *gin.Context) {
		if c.Request.Method != "POST" && c.Request.Method != "GET" {
			return
		}

		h.ServeHTTP(c.Writer, c.Request)
	}
}

func (env *Environment) playgroundHandler() gin.HandlerFunc {
	h := playground.Handler("GraphQL", "/gql")

	return func(c *gin.Context) {
		h.ServeHTTP(c.Writer, c.Request)
	}
}

func (env *Environment) certsHandler() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.JSON(http.StatusOK, env.jwkSet)
	}
}

func (env *Environment) authMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		user := jwx.GetUserFromToken(
			c.Request.Header.Get("Authorization"),
			*env.jwkPublicKey,
			&env.controller.UserRepository,
		)

		if user != nil {
			c.Set(jwx.UserContextKey, user)
		}

		c.Next()
	}
}

func (env *Environment) environmentMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		nebulaLocalizer := translator.Init(c.Request.Header.Get("Accept-Language"))

		c.Set(repositories.Key, env.controller)

		c.Set(core.ServicesKey, core.Init(
			&core.ServiceDependencies{
				Validate:     env.validate,
				Localizer:    &nebulaLocalizer,
				Repositories: *env.controller,
				PrivateJWK:   env.jwkPrivateKey,
			},
		))

		c.Set(translator.Key, &nebulaLocalizer)

		c.Next()
	}
}

func GinContextToContextMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx := context.WithValue(c.Request.Context(), "GinContextKey", c)
		c.Request = c.Request.WithContext(ctx)
		c.Next()
	}
}
