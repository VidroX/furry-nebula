package user

import (
	"errors"
	"firebase.google.com/go/v4/messaging"

	nebulaErrors "github.com/VidroX/furry-nebula/errors"
	generalErrors "github.com/VidroX/furry-nebula/errors/general"
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
	Login(email string, password string) (*model.UserWithToken, []*nebulaErrors.APIError)
	Register(userInfo model.UserRegistrationInput) (*model.UserWithToken, []*nebulaErrors.APIError)
	ChangeUserApprovalStatus(userId string, isApproved bool) *nebulaErrors.APIError
	CreateAccessToken(user *model.User) (*model.Token, *nebulaErrors.APIError)
	SetUserFCMToken(userId string, token string) (*model.User, *nebulaErrors.APIError)
}

type userService struct {
	validate        *validator.Validate
	localizer       *translator.NebulaLocalizer
	userRepository  user.UserRepository
	privateJWK      *jwk.ECDSAPrivateKey
	messagingClient *messaging.Client
}

func (service *userService) Login(email string, password string) (*model.UserWithToken, []*nebulaErrors.APIError) {
	if UtilString(email).IsEmpty() || UtilString(password).IsEmpty() {
		return nil, []*nebulaErrors.APIError{
			validation.ConstructValidationError(validation.ErrUserNotFound, "EMail"),
			validation.ConstructValidationError(validation.ErrUserNotFound, "Password"),
		}
	}

	dbUser, err := service.userRepository.GetUserByEmail(email)

	if err != nil || dbUser == nil {
		return nil, []*nebulaErrors.APIError{
			validation.ConstructValidationError(validation.ErrUserNotFound, "EMail"),
			validation.ConstructValidationError(validation.ErrUserNotFound, "Password"),
		}
	}

	match, err := argon2id.ComparePasswordAndHash(password, dbUser.Password)

	if err != nil || !match {
		return nil, []*nebulaErrors.APIError{
			validation.ConstructValidationError(validation.ErrUserNotFound, "EMail"),
			validation.ConstructValidationError(validation.ErrUserNotFound, "Password"),
		}
	}

	accessToken := jwx.CreateUserToken(*service.privateJWK, model.TokenTypeAccess, dbUser)
	refreshToken := jwx.CreateUserToken(*service.privateJWK, model.TokenTypeRefresh, dbUser)

	return &model.UserWithToken{
		Message: translator.
			WithKey(translator.KeysUserServiceSuccessfulLogin).
			Translate(service.localizer),
		User: dbUser,
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

func (service *userService) Register(userInfo model.UserRegistrationInput) (*model.UserWithToken, []*nebulaErrors.APIError) {
	var properInputRole = model.RegistrationRoleUser
	if userInfo.Role != nil {
		properInputRole = *userInfo.Role
	}

	creationRole, success := model.GetUserRoleByRole(model.Role(properInputRole))

	if !success {
		creationRole = model.DefaultUserRole
	}

	var about = ""
	if userInfo.About != nil {
		about = *userInfo.About
	}

	dbUser := model.User{
		FirstName: userInfo.FirstName,
		LastName:  userInfo.LastName,
		EMail:     userInfo.Email,
		Birthday:  userInfo.Birthday,
		About:     about,
		Role:      creationRole,
		Password:  userInfo.Password,
	}

	err := service.validate.Struct(&dbUser)

	if apiErrors := validation.ProcessValidatorErrors(err); apiErrors != nil && len(apiErrors) > 0 {
		return nil, apiErrors
	}

	hashedPassword, err := argon2id.CreateHash(dbUser.Password, argon2id.DefaultParams)

	if err != nil {
		return nil, []*nebulaErrors.APIError{&generalErrors.ErrInternal}
	}

	dbUser.Password = hashedPassword

	err = service.userRepository.CreateUser(&dbUser)

	var pgErr *pgconn.PgError
	if err != nil && (errors.Is(err, gorm.ErrDuplicatedKey) || (errors.As(err, &pgErr) && pgErr.Code == pgerrcode.UniqueViolation)) {
		return nil, []*nebulaErrors.APIError{validation.ConstructValidationError(validation.ErrUserAlreadyRegistered, "EMail")}
	} else if err != nil {
		return nil, []*nebulaErrors.APIError{&generalErrors.ErrInternal}
	}

	accessToken := jwx.CreateUserToken(*service.privateJWK, model.TokenTypeAccess, &dbUser)
	refreshToken := jwx.CreateUserToken(*service.privateJWK, model.TokenTypeRefresh, &dbUser)

	return &model.UserWithToken{
		Message: translator.
			WithKey(translator.KeysUserServiceSuccessfulRegistration).
			Translate(service.localizer),
		User: &dbUser,
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

func (service *userService) CreateAccessToken(user *model.User) (*model.Token, *nebulaErrors.APIError) {
	if user == nil || UtilString(user.ID).IsEmpty() {
		return nil, validation.ConstructValidationError(validation.ErrValidationRequired, "user")
	}

	accessToken := jwx.CreateUserToken(*service.privateJWK, model.TokenTypeAccess, user)

	return &model.Token{
		Type:  model.TokenTypeAccess,
		Token: accessToken,
	}, nil
}

func (service *userService) ChangeUserApprovalStatus(userId string, isApproved bool) *nebulaErrors.APIError {
	if UtilString(userId).IsEmpty() {
		return validation.ConstructValidationError(validation.ErrValidationRequired, "userId")
	}

	err := service.userRepository.ChangeUserApprovalStatus(userId, isApproved)

	if err != nil {
		return &generalErrors.ErrInternal
	}

	return nil
}

func (service *userService) SetUserFCMToken(userId string, token string) (*model.User, *nebulaErrors.APIError) {
	updatedUser, err := service.userRepository.SetUserFCMToken(userId, token)

	if err != nil {
		return nil, &generalErrors.ErrInternal
	}

	return updatedUser, nil
}

func RegisterUserService(
	validate *validator.Validate,
	localizer *translator.NebulaLocalizer,
	privateJWK *jwk.ECDSAPrivateKey,
	userRepo user.UserRepository,
	messagingClient *messaging.Client,
) UserService {
	return &userService{
		validate:        validate,
		localizer:       localizer,
		userRepository:  userRepo,
		privateJWK:      privateJWK,
		messagingClient: messagingClient,
	}
}
