package shelter

import (
	nebulaErrors "github.com/VidroX/furry-nebula/errors"
	"github.com/VidroX/furry-nebula/graph/model"
	"github.com/VidroX/furry-nebula/repositories/shelter"
	"github.com/VidroX/furry-nebula/services/translator"
	"github.com/go-playground/validator/v10"
)

type ShelterService interface {
	AddShelter(shelterInfo model.ShelterInput, photo *string) (*model.Shelter, []*nebulaErrors.APIError)
	AddShelterAnimal(shelterAnimalInfo model.ShelterAnimalInput, photo *string) (*model.ShelterAnimal, []*nebulaErrors.APIError)
}

type shelterService struct {
	validate          *validator.Validate
	localizer         *translator.NebulaLocalizer
	shelterRepository shelter.ShelterRepository
}

func (service *shelterService) AddShelter(shelterInfo model.ShelterInput, photo *string) (*model.Shelter, []*nebulaErrors.APIError) {
	return &model.Shelter{}, nil
}

func (service *shelterService) AddShelterAnimal(shelterAnimalInfo model.ShelterAnimalInput, photo *string) (*model.ShelterAnimal, []*nebulaErrors.APIError) {
	return &model.ShelterAnimal{}, nil
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
