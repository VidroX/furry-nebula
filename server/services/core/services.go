package core

import (
	"github.com/VidroX/furry-nebula/repositories"
	"github.com/VidroX/furry-nebula/services/core/user"
)

const ServicesKey = "Services"

type Services struct {
	UserService user.UserService
}

type ServiceDependencies struct {
	Repositories repositories.Repositories
}

func Init(deps *ServiceDependencies) *Services {
	return &Services{
		UserService: user.RegisterUserService(deps.Repositories.UserRepository),
	}
}
