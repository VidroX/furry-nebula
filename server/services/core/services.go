package core

import (
	"github.com/VidroX/furry-nebula/repositories"
	"github.com/VidroX/furry-nebula/services/core/user"
	"github.com/VidroX/furry-nebula/services/translator"
	"github.com/go-playground/validator/v10"
	"github.com/lestrrat-go/jwx/v2/jwk"
)

const ServicesKey = "Services"

type Services struct {
	UserService user.UserService
}

type ServiceDependencies struct {
	Validate     *validator.Validate
	Localizer    *translator.NebulaLocalizer
	PrivateJWK   *jwk.ECDSAPrivateKey
	Repositories repositories.Repositories
}

func Init(deps *ServiceDependencies) *Services {
	return &Services{
		UserService: user.RegisterUserService(
			deps.Validate,
			deps.Localizer,
			deps.PrivateJWK,
			deps.Repositories.UserRepository,
		),
	}
}
