package shelter

import (
	"errors"
	nebulaErrors "github.com/VidroX/furry-nebula/errors"
	generalErrors "github.com/VidroX/furry-nebula/errors/general"
	"github.com/VidroX/furry-nebula/errors/validation"
	"github.com/VidroX/furry-nebula/graph/model"
	"github.com/VidroX/furry-nebula/repositories/shelter"
	"github.com/VidroX/furry-nebula/services/translator"
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

	println(shelterAnimalInfo.ShelterID)
	println(shelterRep.FirstName)
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
