package user

import (
	"errors"

	nebula_errors "github.com/VidroX/furry-nebula/errors"
	general_errors "github.com/VidroX/furry-nebula/errors/general"
	user_errors "github.com/VidroX/furry-nebula/errors/user"
	"github.com/VidroX/furry-nebula/errors/validation"
	"github.com/VidroX/furry-nebula/graph/model"
	"github.com/VidroX/furry-nebula/repositories/user"
	"github.com/VidroX/furry-nebula/services/jwx"
	"github.com/VidroX/furry-nebula/services/translator"
	. "github.com/VidroX/furry-nebula/utils"
	"github.com/alexedwards/argon2id"
	"github.com/go-playground/validator/v10"
	"github.com/jackc/pgerrcode"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/lestrrat-go/jwx/v2/jwk"
	"gorm.io/gorm"
)

type UserService interface {
	Login(email string, password string) (*model.UserWithToken, *nebula_errors.APIError)
	Register(userInfo model.UserRegistrationInput) (*model.UserWithToken, []*nebula_errors.APIError)
	ChangeUserApprovalStatus(userId string, isApproved bool) *nebula_errors.APIError
}

type userService struct {
	validate       *validator.Validate
	localizer      *translator.NebulaLocalizer
	userRepository user.UserRepository
	privateJWK     *jwk.ECDSAPrivateKey
}

func (service *userService) Login(email string, password string) (*model.UserWithToken, *nebula_errors.APIError) {
	if UtilString(email).IsEmpty() || UtilString(password).IsEmpty() {
		return nil, &user_errors.ErrUserNotFound
	}

	user, err := service.userRepository.GetUserByEmail(email)

	if err != nil || user == nil {
		return nil, &user_errors.ErrUserNotFound
	}

	match, err := argon2id.ComparePasswordAndHash(password, user.Password)

	if err != nil || !match {
		return nil, &user_errors.ErrUserNotFound
	}

	accessToken := jwx.CreateUserToken(*service.privateJWK, model.TokenTypeAccess, user)
	refreshToken := jwx.CreateUserToken(*service.privateJWK, model.TokenTypeRefresh, user)

	return &model.UserWithToken{
		Message: translator.
			WithKey(translator.KeysUserServiceSuccessfulLogin).
			Translate(service.localizer),
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

func (service *userService) Register(userInfo model.UserRegistrationInput) (*model.UserWithToken, []*nebula_errors.APIError) {
	var properInputRole model.RegistrationRole = model.RegistrationRoleUser
	if userInfo.Role != nil {
		properInputRole = *userInfo.Role
	}

	creationRole, success := model.GetUserRoleByRole(model.Role(properInputRole))

	if !success {
		creationRole = model.DefaultUserRole
	}

	var about string = ""
	if userInfo.About != nil {
		about = *userInfo.About
	}

	user := model.User{
		FirstName: userInfo.FirstName,
		LastName:  userInfo.LastName,
		EMail:     userInfo.Email,
		About:     about,
		Role:      creationRole,
		Password:  userInfo.Password,
	}

	err := service.validate.Struct(&user)

	if errors := validation.ProcessValidatorErrors(err); errors != nil && len(errors) > 0 {
		return nil, errors
	}

	hashedPassword, err := argon2id.CreateHash(user.Password, argon2id.DefaultParams)

	if err != nil {
		return nil, []*nebula_errors.APIError{&general_errors.ErrInternal}
	}

	user.Password = hashedPassword

	err = service.userRepository.CreateUser(&user)

	var pgErr *pgconn.PgError
	if err != nil && (errors.Is(err, gorm.ErrDuplicatedKey) || (errors.As(err, &pgErr) && pgErr.Code == pgerrcode.UniqueViolation)) {
		return nil, []*nebula_errors.APIError{&user_errors.ErrUserAlreadyRegistered}
	} else if err != nil {
		return nil, []*nebula_errors.APIError{&general_errors.ErrInternal}
	}

	accessToken := jwx.CreateUserToken(*service.privateJWK, model.TokenTypeAccess, &user)
	refreshToken := jwx.CreateUserToken(*service.privateJWK, model.TokenTypeRefresh, &user)

	return &model.UserWithToken{
		Message: translator.
			WithKey(translator.KeysUserServiceSuccessfulRegistration).
			Translate(service.localizer),
		User: &user,
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

func (service *userService) ChangeUserApprovalStatus(userId string, isApproved bool) *nebula_errors.APIError {
	err := service.userRepository.ChangeUserApprovalStatus(userId, isApproved)

	if err != nil {
		return &general_errors.ErrInternal
	}

	return nil
}

func RegisterUserService(
	validate *validator.Validate,
	localizer *translator.NebulaLocalizer,
	privateJWK *jwk.ECDSAPrivateKey,
	userRepo user.UserRepository,
) UserService {
	return &userService{
		validate:       validate,
		localizer:      localizer,
		userRepository: userRepo,
		privateJWK:     privateJWK,
	}
}
