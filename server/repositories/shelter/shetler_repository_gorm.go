package shelter

import (
	"github.com/VidroX/furry-nebula/graph/model"
	"github.com/VidroX/furry-nebula/services/database"
)

type ShelterRepositoryGorm struct {
	database *database.NebulaDb
}

func (repo *ShelterRepositoryGorm) GetShelterOwner(shelterId string) (*model.User, error) {
	var shelter *model.Shelter

	err := repo.database.Model(&model.Shelter{}).
		Preload("RepresentativeUser").
		First(&shelter, "id = ?", shelterId).
		Error

	if err != nil {
		return nil, err
	}

	return &shelter.RepresentativeUser, nil
}

func (repo *ShelterRepositoryGorm) GetShelterOwnerByShelterAnimalId(shelterAnimalId string) (*model.User, error) {
	var shelterAnimal *model.ShelterAnimal

	err := repo.database.Model(&model.ShelterAnimal{}).
		InnerJoins("Shelter").
		Preload("Shelter.RepresentativeUser").
		First(&shelterAnimal, "shelter_animals.id = ?", shelterAnimalId).
		Error

	if err != nil {
		return nil, err
	}

	return &shelterAnimal.Shelter.RepresentativeUser, nil
}

func (repo *ShelterRepositoryGorm) GetShelterById(shelterId string) (*model.Shelter, error) {
	var shelter *model.Shelter

	err := repo.database.
		Model(&model.Shelter{}).
		Preload("RepresentativeUser").
		First(&shelter, "id = ?", shelterId).
		Error

	if err != nil {
		return nil, err
	}

	return shelter, nil
}

func (repo *ShelterRepositoryGorm) GetShelterAnimalById(shelterAnimalId string) (*model.ShelterAnimal, error) {
	var shelterAnimal *model.ShelterAnimal

	err := repo.database.
		Model(&model.ShelterAnimal{}).
		InnerJoins("Shelter").
		Preload("Shelter.RepresentativeUser").
		First(&shelterAnimal, "shelter_animals.id = ?", shelterAnimalId).
		Error

	if err != nil {
		return nil, err
	}

	return shelterAnimal, nil
}

func (repo *ShelterRepositoryGorm) GetShelters(user *model.User, filters *model.ShelterFilters, pagination *model.Pagination) ([]*model.Shelter, int64, error) {
	var shelters []*model.Shelter

	var shelterFilters = map[string]interface{}{
		"deleted": false,
	}

	if filters != nil && filters.ShowOnlyOwnShelters != nil && user != nil && *filters.ShowOnlyOwnShelters {
		shelterFilters["representative_id"] = user.ID
	}

	err := repo.database.
		Model(&model.Shelter{}).
		Where(shelterFilters).
		Preload("RepresentativeUser").
		Order("add_datetime desc").
		Scopes(database.PaginationScope(pagination)).
		Find(&shelters).
		Error

	if err != nil {
		return nil, 0, err
	}

	var total int64 = 0
	repo.database.
		Model(&model.Shelter{}).
		Where(shelterFilters).
		Order("add_datetime desc").
		Count(&total)

	return shelters, total, nil
}

func (repo *ShelterRepositoryGorm) GetShelterAnimals(filters *model.AnimalFilters, pagination *model.Pagination) ([]*model.ShelterAnimal, int64, error) {
	var shelterAnimals []*model.ShelterAnimal

	filterMap := map[string]interface{}{
		"removed": false,
	}

	if filters.Animal != nil {
		filterMap["animal_type"] = (*filters.Animal).String()
	}

	if filters.ShelterID != nil {
		filterMap["shelter_id"] = *filters.ShelterID
	}

	if filters.ShelterIds != nil {
		filterMap["shelter_id"] = filters.ShelterIds
	}

	err := repo.database.
		Model(&model.ShelterAnimal{}).
		Where(filterMap).
		InnerJoins("Shelter", repo.database.Where(map[string]interface{}{"deleted": false})).
		InnerJoins("Animal").
		Preload("Shelter.RepresentativeUser").
		Order("add_datetime desc").
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
		InnerJoins("Shelter", repo.database.Where(map[string]interface{}{"deleted": false})).
		Order("add_datetime desc").
		Count(&total)

	return shelterAnimals, total, nil
}

func (repo *ShelterRepositoryGorm) AddShelter(shelter *model.Shelter) error {
	return repo.database.Create(shelter).Error
}

func (repo *ShelterRepositoryGorm) AddShelterAnimal(shelterAnimal *model.ShelterAnimal) error {
	return repo.database.Create(shelterAnimal).Error
}

func (repo *ShelterRepositoryGorm) UpdateShelterPhoto(shelterId string, photo *string) error {
	return repo.database.Model(&model.Shelter{}).
		Where("id = ?", shelterId).
		Update("photo", photo).
		Error
}

func (repo *ShelterRepositoryGorm) UpdateShelterAnimalPhoto(shelterAnimalId string, photo *string) error {
	return repo.database.Model(&model.ShelterAnimal{}).
		Where("id = ?", shelterAnimalId).
		Update("photo", photo).
		Error
}

func (repo *ShelterRepositoryGorm) DeleteShelter(shelterId string) error {
	return repo.database.Model(&model.Shelter{}).
		Where("id = ?", shelterId).
		Update("deleted", true).
		Error
}

func (repo *ShelterRepositoryGorm) RemoveShelterAnimal(shelterAnimalId string) error {
	return repo.database.Model(&model.ShelterAnimal{}).
		Where("id = ?", shelterAnimalId).
		Update("removed", true).
		Error
}
