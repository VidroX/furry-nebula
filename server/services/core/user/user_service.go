package user

import (
	"github.com/VidroX/furry-nebula/graph/model"
	"github.com/VidroX/furry-nebula/repositories/user"
	"github.com/lestrrat-go/jwx/v2/jwk"
)

type UserService interface {
	Login(email string, password string) (model.User, error)
}

type userService struct {
	userRepository user.UserRepository
	keySet         *jwk.Set
}

func (service *userService) Login(email string, password string) (model.User, error) {
	return model.User{}, nil
}

func RegisterUserService(keySet *jwk.Set, userRepo user.UserRepository) UserService {
	return &userService{
		userRepository: userRepo,
		keySet:         keySet,
	}
}
