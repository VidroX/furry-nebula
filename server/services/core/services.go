package core

import (
	"github.com/VidroX/furry-nebula/repositories"
	"github.com/VidroX/furry-nebula/services/core/user"
	"github.com/lestrrat-go/jwx/v2/jwk"
)

const ServicesKey = "Services"

type Services struct {
	UserService user.UserService
}

type ServiceDependencies struct {
	JWKSet       *jwk.Set
	Repositories repositories.Repositories
}

func Init(deps *ServiceDependencies) *Services {
	return &Services{
		UserService: user.RegisterUserService(deps.JWKSet, deps.Repositories.UserRepository),
	}
}
