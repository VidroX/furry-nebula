package main

import (
	"context"
	"encoding/base64"
	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
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
	"google.golang.org/api/option"
	"log"
	"net/http"
	"os"
	"path/filepath"
)

type Environment struct {
	validate        *validator.Validate
	controller      *repositories.Repositories
	firebaseContext *context.Context
	messagingClient *messaging.Client
	jwkPrivateKey   *jwk.ECDSAPrivateKey
	jwkPublicKey    *jwk.ECDSAPublicKey
	jwkSet          *jwk.Set
}

func main() {
	environment.LoadEnvironment(nil)

	private, public := jwx.InitKeySet()

	ctx := context.Background()
	firebaseApp := setupFirebase(&ctx)
	client, err := firebaseApp.Messaging(ctx)

	if err != nil {
		log.Printf("Unable to setup Firebase Messaging: %s", err.Error())
	}

	loadDatabase()

	controller := repositories.Init()

	keySet := jwk.NewSet()
	_ = keySet.AddKey(public)

	validate := validator.New()

	env := Environment{
		validate:        validate,
		controller:      controller,
		jwkPrivateKey:   &private,
		jwkPublicKey:    &public,
		jwkSet:          &keySet,
		messagingClient: client,
		firebaseContext: &ctx,
	}

	r := gin.Default()
	r.Use(GinContextToContextMiddleware())
	r.Use(env.authMiddleware())
	r.Use(env.environmentMiddleware())
	r.Any("/gql", env.graphqlHandler())
	r.GET("/certs", env.certsHandler())

	uploadsPath, _ := filepath.Abs(filepath.Join(os.Getenv(environment.KeysAppPath), os.Getenv(environment.KeysUploadsLocation)))
	r.StaticFS("/uploads", gin.Dir(uploadsPath, false))

	if os.Getenv(environment.KeysGinMode) != "release" {
		r.GET("/", env.playgroundHandler())
	}

	_ = r.Run()
}

func setupFirebase(ctx *context.Context) *firebase.App {
	sdk, _ := base64.StdEncoding.DecodeString(os.Getenv(environment.KeysFirebaseSecret))
	opt := option.WithCredentialsJSON(sdk)
	app, err := firebase.NewApp(*ctx, nil, opt)

	if err != nil {
		log.Fatalf("Unable to setup Firebase: %s", err.Error())
		return nil
	}

	return app
}

func loadDatabase() {
	gormDB := database.Init()

	gormDB.AutoMigrateAll()
	gormDB.PopulateRoles()
	gormDB.PopulateAnimalTypes()
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
				Validate:        env.validate,
				Localizer:       &nebulaLocalizer,
				Repositories:    *env.controller,
				PrivateJWK:      env.jwkPrivateKey,
				MessagingClient: env.messagingClient,
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
