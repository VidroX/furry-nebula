package shelter

import (
	"errors"
	nebulaErrors "github.com/VidroX/furry-nebula/errors"
	generalErrors "github.com/VidroX/furry-nebula/errors/general"
	"github.com/VidroX/furry-nebula/errors/validation"
	"github.com/VidroX/furry-nebula/graph/model"
	"github.com/VidroX/furry-nebula/repositories/shelter"
	"github.com/VidroX/furry-nebula/services/translator"
	. "github.com/VidroX/furry-nebula/utils"
	"github.com/go-playground/validator/v10"
	"github.com/jackc/pgerrcode"
	"github.com/jackc/pgx/v5/pgconn"
	"gorm.io/gorm"
)

type ShelterService interface {
	AddShelter(userId string, shelterInfo model.ShelterInput) (*model.Shelter, []*nebulaErrors.APIError)
	UpdateShelterPhoto(userId string, shelterId string, photo *string) *nebulaErrors.APIError
	AddShelterAnimal(userId string, shelterAnimalInfo model.ShelterAnimalInput) (*model.ShelterAnimal, []*nebulaErrors.APIError)
	UpdateShelterAnimalPhoto(userId string, shelterAnimalId string, photo *string) *nebulaErrors.APIError
	DeleteShelter(userId string, shelterId string) *nebulaErrors.APIError
	RemoveShelterAnimal(userId string, shelterAnimalId string) *nebulaErrors.APIError
	CreateUserRequest(userId string, userRequestInput model.UserRequestInput) (*model.UserRequest, []*nebulaErrors.APIError)
	ChangeUserRequestStatus(userId string, requestId string, status model.UserRequestStatus) *nebulaErrors.APIError
}

type shelterService struct {
	validate          *validator.Validate
	localizer         *translator.NebulaLocalizer
	shelterRepository shelter.ShelterRepository
}

func (service *shelterService) AddShelter(userId string, shelterInfo model.ShelterInput) (*model.Shelter, []*nebulaErrors.APIError) {
	var shelterDesc = ""
	if shelterInfo.Info != nil {
		shelterDesc = *shelterInfo.Info
	}

	shelterModel := model.Shelter{
		RepresentativeID: userId,
		Info:             shelterDesc,
		Name:             shelterInfo.Name,
		Address:          shelterInfo.Address,
	}

	err := service.validate.Struct(&shelterModel)

	if apiErrors := validation.ProcessValidatorErrors(err); apiErrors != nil && len(apiErrors) > 0 {
		return nil, apiErrors
	}

	err = service.shelterRepository.AddShelter(&shelterModel)

	var pgErr *pgconn.PgError
	if err != nil && (errors.Is(err, gorm.ErrDuplicatedKey) || (errors.As(err, &pgErr) && pgErr.Code == pgerrcode.UniqueViolation)) {
		return nil, []*nebulaErrors.APIError{validation.ConstructValidationError(validation.ErrShelterAlreadyExists, "name")}
	} else if err != nil {
		return nil, []*nebulaErrors.APIError{&generalErrors.ErrInternal}
	}

	dbShelter, err := service.shelterRepository.GetShelterById(shelterModel.ID)

	if err != nil {
		return nil, []*nebulaErrors.APIError{&generalErrors.ErrInternal}
	}

	return dbShelter, nil
}

func (service *shelterService) UpdateShelterPhoto(userId string, shelterId string, photo *string) *nebulaErrors.APIError {
	shelterRep, err := service.shelterRepository.GetShelterOwner(shelterId)

	if err != nil || shelterRep.ID != userId {
		return &generalErrors.ErrNotEnoughPermissions
	}

	err = service.shelterRepository.UpdateShelterPhoto(shelterId, photo)

	if err != nil {
		return &generalErrors.ErrInternal
	}

	return nil
}

func (service *shelterService) AddShelterAnimal(userId string, shelterAnimalInfo model.ShelterAnimalInput) (*model.ShelterAnimal, []*nebulaErrors.APIError) {
	shelterRep, err := service.shelterRepository.GetShelterOwner(shelterAnimalInfo.ShelterID)

	if err != nil || shelterRep.ID != userId {
		return nil, []*nebulaErrors.APIError{&generalErrors.ErrNotEnoughPermissions}
	}

	var shelterAnimalDesc = ""
	if shelterAnimalInfo.Description != nil {
		shelterAnimalDesc = *shelterAnimalInfo.Description
	}

	shelterAnimalModel := model.ShelterAnimal{
		ShelterID:   shelterAnimalInfo.ShelterID,
		AnimalType:  shelterAnimalInfo.Animal.String(),
		Name:        shelterAnimalInfo.Name,
		Description: shelterAnimalDesc,
	}

	err = service.validate.Struct(&shelterAnimalModel)

	if apiErrors := validation.ProcessValidatorErrors(err); apiErrors != nil && len(apiErrors) > 0 {
		return nil, apiErrors
	}

	err = service.shelterRepository.AddShelterAnimal(&shelterAnimalModel)

	if err != nil {
		return nil, []*nebulaErrors.APIError{&generalErrors.ErrInternal}
	}

	dbShelterAnimal, err := service.shelterRepository.GetShelterAnimalById(shelterAnimalModel.ID)

	if err != nil {
		return nil, []*nebulaErrors.APIError{&generalErrors.ErrInternal}
	}

	return dbShelterAnimal, nil
}

func (service *shelterService) UpdateShelterAnimalPhoto(userId string, shelterAnimalId string, photo *string) *nebulaErrors.APIError {
	shelterRep, err := service.shelterRepository.GetShelterOwnerByShelterAnimalId(shelterAnimalId)

	if err != nil || shelterRep.ID != userId {
		return &generalErrors.ErrNotEnoughPermissions
	}

	err = service.shelterRepository.UpdateShelterAnimalPhoto(shelterAnimalId, photo)

	if err != nil {
		return &generalErrors.ErrInternal
	}

	return nil
}

func (service *shelterService) DeleteShelter(userId string, shelterId string) *nebulaErrors.APIError {
	shelterRep, err := service.shelterRepository.GetShelterOwner(shelterId)

	if err != nil || shelterRep.ID != userId {
		return &generalErrors.ErrNotEnoughPermissions
	}

	err = service.shelterRepository.DeleteShelter(shelterId)

	if err != nil {
		return &generalErrors.ErrInternal
	}

	return nil
}

func (service *shelterService) RemoveShelterAnimal(userId string, shelterAnimalId string) *nebulaErrors.APIError {
	shelterRep, err := service.shelterRepository.GetShelterOwnerByShelterAnimalId(shelterAnimalId)

	if err != nil || shelterRep.ID != userId {
		return &generalErrors.ErrNotEnoughPermissions
	}

	err = service.shelterRepository.RemoveShelterAnimal(shelterAnimalId)

	if err != nil {
		return &generalErrors.ErrInternal
	}

	return nil
}

func (service *shelterService) CreateUserRequest(userId string, userRequestInput model.UserRequestInput) (*model.UserRequest, []*nebulaErrors.APIError) {
	userRequestModel := model.UserRequest{
		UserID:      userId,
		AnimalID:    userRequestInput.AnimalID,
		RequestType: userRequestInput.RequestType,
	}

	if userRequestInput.FromDate != nil {
		userRequestModel.FromDate = userRequestInput.FromDate
	}

	if userRequestInput.ToDate != nil {
		userRequestModel.ToDate = userRequestInput.ToDate
	}

	err := service.validate.Struct(&userRequestModel)

	if apiErrors := validation.ProcessValidatorErrors(err); apiErrors != nil && len(apiErrors) > 0 {
		return nil, apiErrors
	}

	err = service.shelterRepository.CreateUserRequest(&userRequestModel)

	if err != nil {
		var normalizedErrors []*nebulaErrors.APIError

		switch {
		case errors.Is(err, shelter.IncorrectDateRange):
			normalizedErrors = []*nebulaErrors.APIError{
				validation.ConstructValidationError(validation.ErrIncorrectDateRange, "fromDate"),
				validation.ConstructValidationError(validation.ErrIncorrectDateRange, "toDate"),
			}
		case errors.Is(err, shelter.AnimalAlreadyAdopted):
			normalizedErrors = []*nebulaErrors.APIError{
				validation.ConstructValidationError(validation.ErrAnimalAlreadyAdopted, "animalId"),
			}
		case errors.Is(err, shelter.AnimalNotAvailable):
			normalizedErrors = []*nebulaErrors.APIError{
				validation.ConstructValidationError(validation.ErrAnimalNotAvailable, "fromDate"),
				validation.ConstructValidationError(validation.ErrAnimalNotAvailable, "toDate"),
			}
		case errors.Is(err, shelter.DateRangeEmpty):
			normalizedErrors = []*nebulaErrors.APIError{
				validation.ConstructValidationError(validation.ErrDateRangeEmpty, "fromDate"),
				validation.ConstructValidationError(validation.ErrDateRangeEmpty, "toDate"),
			}
		case errors.Is(err, shelter.PastDate):
			normalizedErrors = []*nebulaErrors.APIError{
				validation.ConstructValidationError(validation.ErrPastDate, "fromDate"),
			}
		default:
			normalizedErrors = []*nebulaErrors.APIError{&generalErrors.ErrInternal}
		}

		return nil, normalizedErrors
	}

	dbUserRequest, err := service.shelterRepository.GetUserRequestById(userRequestModel.ID)

	if err != nil {
		return nil, []*nebulaErrors.APIError{&generalErrors.ErrInternal}
	}

	return dbUserRequest, nil
}

func (service *shelterService) ChangeUserRequestStatus(userId string, requestId string, status model.UserRequestStatus) *nebulaErrors.APIError {
	if UtilString(requestId).IsEmpty() {
		return validation.ConstructValidationError(validation.ErrValidationRequired, "id")
	}

	userRequest, err := service.shelterRepository.GetUserRequestById(requestId)

	var pgErr *pgconn.PgError
	if err != nil && (errors.Is(err, gorm.ErrRecordNotFound) || (errors.As(err, &pgErr) && pgErr.Code == pgerrcode.NoDataFound)) {
		return validation.ConstructValidationError(validation.ErrRequestNotFound, "id")
	} else if err != nil {
		return &generalErrors.ErrInternal
	}

	notEnoughPermissions := (status != model.UserRequestStatusCancelled && userRequest.Animal.Shelter.RepresentativeID != userId) ||
		(status == model.UserRequestStatusCancelled && userRequest.UserID != userId)

	if notEnoughPermissions {
		return &generalErrors.ErrNotEnoughPermissions
	}

	err = service.shelterRepository.ChangeUserRequestStatus(requestId, status, &userId)

	if err != nil {
		return &generalErrors.ErrInternal
	}

	return nil
}

func RegisterShelterService(
	validate *validator.Validate,
	localizer *translator.NebulaLocalizer,
	shelterRepo shelter.ShelterRepository,
) ShelterService {
	return &shelterService{
		validate:          validate,
		localizer:         localizer,
		shelterRepository: shelterRepo,
	}
}
