package shelter

import (
	"github.com/VidroX/furry-nebula/graph/model"
	"github.com/VidroX/furry-nebula/services/database"
)

type ShelterRepositoryGorm struct {
	database *database.NebulaDb
}

func (repo *ShelterRepositoryGorm) GetShelters(pagination *model.Pagination) ([]*model.Shelter, int64, error) {
	shelters := []*model.Shelter{}

	err := repo.database.
		Model(&model.Shelter{}).
		Where("deleted = ?", false).
		Preload("RepresentativeUser").
		Scopes(database.PaginationScope(pagination)).
		Find(&shelters).
		Error

	if err != nil {
		return nil, 0, err
	}

	var total int64 = 0
	repo.database.Model(&model.Shelter{}).Where("deleted = ?", false).Count(&total)

	return shelters, total, nil
}

func (repo *ShelterRepositoryGorm) GetShelterAnimals(filters *model.AnimalFilters, pagination *model.Pagination) ([]*model.ShelterAnimal, int64, error) {
	shelterAnimals := []*model.ShelterAnimal{}

	var animal_type *string
	if filters.Animal != nil {
		animal_type = (*string)(filters.Animal)
	}

	filterMap := map[string]interface{}{
		"removed":     false,
		"shelter_id":  filters.ShelterID,
		"animal_type": animal_type,
	}

	err := repo.database.
		Model(&model.ShelterAnimal{}).
		Where(filterMap).
		InnerJoins("Shelter", repo.database.Where(&model.Shelter{Deleted: false})).
		InnerJoins("Animal").
		Preload("Shelter.RepresentativeUser").
		Scopes(database.PaginationScope(pagination)).
		Find(&shelterAnimals).
		Error

	if err != nil {
		return nil, 0, err
	}

	var total int64 = 0
	repo.database.
		Model(&model.ShelterAnimal{}).
		Where(filterMap).
		InnerJoins("Shelter", repo.database.Where(&model.Shelter{Deleted: false})).
		Count(&total)

	return shelterAnimals, total, nil
}

func (repo *ShelterRepositoryGorm) AddShelter(shelter *model.Shelter) error {
	return repo.database.Create(shelter).Error
}

func (repo *ShelterRepositoryGorm) AddShelterAnimal(shelterAnimal *model.ShelterAnimal) error {
	return repo.database.Create(shelterAnimal).Error
}
