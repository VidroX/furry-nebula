package user

import (
	"github.com/VidroX/furry-nebula/graph/model"
	"github.com/VidroX/furry-nebula/repositories/user"
)

type UserService interface {
	Login(email string, password string) (model.User, error)
}

type userService struct {
	userRepository user.UserRepository
}

func (service *userService) Login(email string, password string) (model.User, error) {
	return model.User{}, nil
}

func RegisterUserService(userRepo user.UserRepository) UserService {
	return &userService{
		userRepository: userRepo,
	}
}
