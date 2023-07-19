package shelter

import (
	"errors"
	"github.com/VidroX/furry-nebula/graph/model"
	"github.com/VidroX/furry-nebula/services/database"
	"gorm.io/gorm"
	"time"
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
	var total int64 = 0
	var shelterAnimals []*model.ShelterAnimal

	filterMap := map[string]interface{}{
		"shelter_animals.removed": false,
	}

	if filters.Animal != nil {
		filterMap["shelter_animals.animal_type"] = (*filters.Animal).String()
	}

	if filters.ShelterID != nil {
		filterMap["shelter_animals.shelter_id"] = *filters.ShelterID
	}

	if filters.ShelterIds != nil {
		filterMap["shelter_animals.shelter_id"] = filters.ShelterIds
	}

	results := repo.database.
		Model(&model.ShelterAnimal{}).
		Where(filterMap).
		InnerJoins("Shelter", repo.database.Where(map[string]interface{}{"deleted": false})).
		InnerJoins("Animal").
		Preload("Shelter.RepresentativeUser")

	if filters.ShowUnavailable == nil || !(*filters.ShowUnavailable) {
		filterQuery := `
			shelter_animals.id = ANY (
				SELECT SA.id FROM user_requests AS UR
				RIGHT JOIN shelter_animals AS SA ON SA.id = UR.animal_id
				WHERE (
					(UR.is_reviewed is null OR UR.is_reviewed = ?)
					OR (UR.is_approved is null OR UR.is_approved = ?)
					OR (UR.request_type is null OR UR.request_type <> ?)
				)
				AND (UR.to_date is null OR UR.to_date::date >= ?::date)
			)
		`
		results = results.
			Where(filterQuery, false, false, model.UserRequestTypeAdoption.String(), time.Now())
	}

	results = results.
		Order("shelter_animals.add_datetime desc").
		Scopes(database.PaginationScope(pagination)).
		Find(&shelterAnimals).
		Count(&total)

	if results.Error != nil {
		return nil, 0, results.Error
	}

	return shelterAnimals, total, nil
}

func (repo *ShelterRepositoryGorm) AddShelter(shelter *model.Shelter) error {
	var total int64 = 0
	repo.database.
		Model(&model.Shelter{}).
		Where(map[string]interface{}{
			"name":    shelter.Name,
			"deleted": false,
		}).
		Count(&total)

	if total > 0 {
		return gorm.ErrDuplicatedKey
	}

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

func (repo *ShelterRepositoryGorm) GetUserRequestsByShelterRepresentativeId(shelterRepId string, filters *model.UserRequestFilters, pagination *model.Pagination) ([]*model.UserRequest, int64, error) {
	var userRequests []*model.UserRequest
	var total int64 = 0

	filterMap := map[string]interface{}{}

	if filters.IsApproved != nil {
		filterMap["is_approved"] = *filters.IsApproved
	}

	if filters.IsReviewed != nil {
		filterMap["is_reviewed"] = *filters.IsReviewed
	}

	if filters.RequestType != nil {
		filterMap["request_type"] = (*filters.RequestType).String()
	}

	shelterJoin := repo.database.Where(
		map[string]interface{}{
			"deleted": false,
		},
	)

	animalJoin := repo.database.Where(
		map[string]interface{}{
			"removed": false,
		},
	)

	shelterRepJoin := repo.database.Where(
		map[string]interface{}{
			"Animal__Shelter__RepresentativeUser.id": shelterRepId,
		},
	)

	err := repo.database.
		Model(&model.UserRequest{}).
		Where(filterMap).
		InnerJoins("Animal", animalJoin).
		InnerJoins("Animal.Shelter", shelterJoin).
		InnerJoins("Animal.Shelter.RepresentativeUser", shelterRepJoin).
		Preload("User").
		Order("add_datetime desc").
		Scopes(database.PaginationScope(pagination)).
		Find(&userRequests).
		Count(&total).
		Error

	if err != nil {
		return nil, 0, err
	}

	return userRequests, total, nil
}

func (repo *ShelterRepositoryGorm) GetUserRequestsByUserId(userId string, filters *model.UserRequestFilters, pagination *model.Pagination) ([]*model.UserRequest, int64, error) {
	var userRequests []*model.UserRequest
	var total int64 = 0

	filterMap := map[string]interface{}{}

	if filters.IsApproved != nil {
		filterMap["is_approved"] = *filters.IsApproved
	}

	if filters.IsReviewed != nil {
		filterMap["is_reviewed"] = *filters.IsReviewed
	}

	if filters.RequestType != nil {
		filterMap["request_type"] = (*filters.RequestType).String()
	}

	shelterJoin := repo.database.Where(
		map[string]interface{}{
			"deleted": false,
		},
	)

	animalJoin := repo.database.Where(
		map[string]interface{}{
			"removed": false,
		},
	)

	userJoin := repo.database.Where(
		map[string]interface{}{
			"User.id": userId,
		},
	)

	err := repo.database.
		Model(&model.UserRequest{}).
		Where(filterMap).
		InnerJoins("User", userJoin).
		InnerJoins("Animal", animalJoin).
		InnerJoins("Animal.Shelter", shelterJoin).
		Preload("Animal.Shelter.RepresentativeUser").
		Order("add_datetime desc").
		Scopes(database.PaginationScope(pagination)).
		Find(&userRequests).
		Count(&total).
		Error

	if err != nil {
		return nil, 0, err
	}

	return userRequests, total, nil
}

func (repo *ShelterRepositoryGorm) CreateUserRequest(request *model.UserRequest) error {
	if request.FromDate != nil && request.ToDate != nil && (*request.FromDate).UTC().After((*request.ToDate).UTC()) {
		return IncorrectDateRange
	}

	if (request.FromDate == nil || request.ToDate == nil) && request.RequestType == model.UserRequestTypeAccommodation {
		return DateRangeEmpty
	}

	if request.FromDate != nil && request.FromDate.UTC().Before(truncateToDay(time.Now()).UTC().Add(-24*time.Hour)) {
		return PastDate
	}

	var total int64 = 0
	repo.database.
		Model(&model.UserRequest{}).
		Where(map[string]interface{}{
			"animal_id":    request.AnimalID,
			"request_type": model.UserRequestTypeAdoption.String(),
			"is_reviewed":  true,
			"is_approved":  true,
		}).
		Count(&total)

	if total > 0 {
		return AnimalAlreadyAdopted
	}

	query := repo.database.Model(&model.UserRequest{})

	if request.RequestType == model.UserRequestTypeAccommodation {
		query = query.
			Where("?::date >= from_date::date AND ?::date <= to_date::date", request.FromDate, request.ToDate)
	} else {
		currentTime := time.Now()
		query = query.
			Where("?::date >= from_date::date AND ?::date <= to_date::date", currentTime, currentTime)
	}

	query = query.Count(&total)

	if total > 0 {
		return AnimalNotAvailable
	}

	err := repo.database.Create(request).Error

	return err
}

func (repo *ShelterRepositoryGorm) GetUserRequestById(id string) (*model.UserRequest, error) {
	var userRequest *model.UserRequest

	err := repo.database.
		InnerJoins("Animal").
		InnerJoins("Animal.Shelter").
		InnerJoins("Animal.Shelter.RepresentativeUser").
		Preload("User").
		Preload("ApprovedBy").
		First(&userRequest, "user_requests.id = ?", id).
		Error

	if err != nil {
		return nil, err
	}

	return userRequest, nil
}

func truncateToDay(t time.Time) time.Time {
	return time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, t.Location())
}

var IncorrectDateRange = errors.New("from date cannot be after to date")
var DateRangeEmpty = errors.New("date range is required")
var AnimalAlreadyAdopted = errors.New("animal has been already adopted by someone else")
var AnimalNotAvailable = errors.New("animal cannot be adopted/accommodated in the given date range")
var PastDate = errors.New("date cannot be in the past")
