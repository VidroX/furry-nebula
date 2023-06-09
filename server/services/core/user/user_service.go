package user

import (
	"errors"

	"github.com/VidroX/furry-nebula/graph/model"
	"github.com/VidroX/furry-nebula/repositories/user"
	"github.com/VidroX/furry-nebula/services/jwx"
	"github.com/VidroX/furry-nebula/services/translator"
	stringutils "github.com/VidroX/furry-nebula/utils/string_utils"
	"github.com/alexedwards/argon2id"
	"github.com/lestrrat-go/jwx/v2/jwk"
)

type UserService interface {
	Login(email string, password string) (*model.UserWithToken, error)
}

type userService struct {
	localizer      *translator.NebulaLocalizer
	userRepository user.UserRepository
	privateJWK     *jwk.ECDSAPrivateKey
}

func (service *userService) Login(email string, password string) (*model.UserWithToken, error) {
	if stringutils.IsEmpty(email) || stringutils.IsEmpty(password) {
		return nil, errors.New(
			translator.
				WithKey(translator.KeysUserServiceErrorsNotFound).
				Translate(service.localizer),
		)
	}

	user, err := service.userRepository.GetUserByEmail(email)

	if err != nil || user == nil {
		return nil, errors.New(
			translator.
				WithKey(translator.KeysUserServiceErrorsNotFound).
				Translate(service.localizer),
		)
	}

	match, err := argon2id.ComparePasswordAndHash(password, user.Password)

	if err != nil || !match {
		return nil, errors.New(
			translator.
				WithKey(translator.KeysUserServiceErrorsNotFound).
				Translate(service.localizer),
		)
	}

	accessToken := jwx.CreateUserToken(*service.privateJWK, model.TokenTypeAccess, user)
	refreshToken := jwx.CreateUserToken(*service.privateJWK, model.TokenTypeRefresh, user)

	return &model.UserWithToken{
		User: user,
		AccessToken: &model.Token{
			Type:  model.TokenTypeAccess,
			Token: accessToken,
		},
		RefreshToken: &model.Token{
			Type:  model.TokenTypeRefresh,
			Token: refreshToken,
		},
	}, nil
}

func RegisterUserService(
	localizer *translator.NebulaLocalizer,
	privateJWK *jwk.ECDSAPrivateKey,
	userRepo user.UserRepository,
) UserService {
	return &userService{
		localizer:      localizer,
		userRepository: userRepo,
		privateJWK:     privateJWK,
	}
}
