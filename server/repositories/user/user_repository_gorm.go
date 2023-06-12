package user

import (
	"strings"

	. "github.com/VidroX/furry-nebula/graph/model"
	"github.com/VidroX/furry-nebula/services/database"
	"gorm.io/gorm"
)

type UserRepositoryGorm struct {
	database *database.NebulaDb
}

func (repo *UserRepositoryGorm) GetUserById(id string) (*User, error) {
	var user User
	err := repo.database.Preload("Role").First(&user, "id = ?", strings.TrimSpace(id)).Error

	if err != nil {
		return nil, err
	}

	return &user, nil
}

func (repo *UserRepositoryGorm) GetUserByEmail(email string) (*User, error) {
	var user User
	err := repo.database.Preload("Role").First(&user, "email = ?", email).Error

	if err != nil {
		return nil, err
	}

	return &user, nil
}

func (repo *UserRepositoryGorm) CreateUser(user *User) error {
	err := repo.database.Transaction(func(tx *gorm.DB) error {
		if err := tx.Create(user).Error; err != nil {
			return err
		}

		var defaultApproved bool = false
		if user.HasRole(RoleUser) {
			defaultApproved = true
		}

		userApproval := UserApproval{
			User:       *user,
			IsApproved: defaultApproved,
		}

		if err := tx.Create(&userApproval).Error; err != nil {
			return err
		}

		return nil
	})

	return err
}

func (repo *UserRepositoryGorm) IsUserApproved(id string) (bool, error) {
	var userApproval UserApproval
	err := repo.database.First(&userApproval, "user_id = ?", strings.TrimSpace(id)).Error

	if err != nil {
		return false, err
	}

	return userApproval.IsApproved, nil
}

func (repo *UserRepositoryGorm) ChangeUserApprovalStatus(id string, isApproved bool) error {
	err := repo.database.Model(&UserApproval{}).Where("user_id = ?", id).Update("is_approved", isApproved).Error

	return err
}

func (repo *UserRepositoryGorm) GetUserApprovals(isApproved *bool, pagination *Pagination) ([]*UserApproval, int64, error) {
	model := repo.database.Model(&UserApproval{}).Preload("User")

	results := []*UserApproval{}
	var total int64 = 0

	if isApproved != nil {
		model.Where("is_approved = ?", *isApproved).Count(&total)

		model = model.Where("is_approved = ?", *isApproved).
			Scopes(database.PaginationScope(pagination)).
			Find(&results)
	} else {
		model.Count(&total)

		model = model.Scopes(database.PaginationScope(pagination)).Find(&results)
	}

	if err := model.Error; err != nil {
		return nil, 0, err
	}

	return results, total, nil
}

func (repo *UserRepositoryGorm) GetUsers(pagination *Pagination) ([]*User, int64, error) {
	users := []*User{}
	err := repo.database.
		Model(&User{}).
		Preload("Role").
		Scopes(database.PaginationScope(pagination)).
		Find(&users).
		Error

	if err != nil {
		return nil, 0, err
	}

	var total int64 = 0
	repo.database.Model(&User{}).Count(&total)

	return users, total, nil
}
