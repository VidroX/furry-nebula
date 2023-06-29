package shelter

import (
	"github.com/VidroX/furry-nebula/graph/model"
	"github.com/VidroX/furry-nebula/services/database"
)

type ShelterRepository interface {
	GetShelters(pagination *model.Pagination) ([]*model.Shelter, int64, error)
	GetShelterAnimals(filters *model.AnimalFilters, pagination *model.Pagination) ([]*model.ShelterAnimal, int64, error)
	AddShelter(shelter *model.Shelter) error
	AddShelterAnimal(shelterAnimal *model.ShelterAnimal) error
}

func Get(database *database.NebulaDb) ShelterRepository {
	return &ShelterRepositoryGorm{
		database,
	}
}
