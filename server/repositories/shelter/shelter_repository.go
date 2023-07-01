package shelter

import (
	"github.com/VidroX/furry-nebula/graph/model"
	"github.com/VidroX/furry-nebula/services/database"
)

type ShelterRepository interface {
	GetShelters(user *model.User, filters *model.ShelterFilters, pagination *model.Pagination) ([]*model.Shelter, int64, error)
	GetShelterAnimals(filters *model.AnimalFilters, pagination *model.Pagination) ([]*model.ShelterAnimal, int64, error)
	GetShelterOwner(shelterId string) (*model.User, error)
	GetShelterOwnerByShelterAnimalId(shelterAnimalId string) (*model.User, error)
	GetShelterById(shelterId string) (*model.Shelter, error)
	GetShelterAnimalById(shelterAnimalId string) (*model.ShelterAnimal, error)
	AddShelter(shelter *model.Shelter) error
	UpdateShelterPhoto(shelterId string, photo *string) error
	AddShelterAnimal(shelterAnimal *model.ShelterAnimal) error
	UpdateShelterAnimalPhoto(shelterAnimalId string, photo *string) error
	DeleteShelter(shelterId string) error
	RemoveShelterAnimal(shelterAnimalId string) error
}

func Get(database *database.NebulaDb) ShelterRepository {
	return &ShelterRepositoryGorm{
		database,
	}
}
