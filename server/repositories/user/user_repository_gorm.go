package user

import (
	"strings"

	"github.com/VidroX/furry-nebula/graph/model"
	"github.com/VidroX/furry-nebula/services/database"
)

type UserRepositoryGorm struct {
	database *database.NebulaDb
}

func (repo *UserRepositoryGorm) GetUserById(id string) (*model.User, error) {
	var user model.User
	err := repo.database.First(&user, "id = ?", strings.TrimSpace(id)).Error

	if err != nil {
		return nil, err
	}

	return &user, nil
}

func (repo *UserRepositoryGorm) GetUserByEmail(email string) (*model.User, error) {
	var user model.User
	err := repo.database.First(&user, "email = ?", email).Error

	if err != nil {
		return nil, err
	}

	return &user, nil
}

func (repo *UserRepositoryGorm) CreateUser(user *model.User) error {
	err := repo.database.Create(user).Error

	if err != nil {
		return err
	}

	var defaultApproved bool = false
	if user.HasRole(model.RoleUser) {
		defaultApproved = true
	}

	userApproval := model.UserApproval{
		User:       *user,
		IsApproved: defaultApproved,
	}

	err = repo.database.Create(&userApproval).Error

	return err
}

func (repo *UserRepositoryGorm) IsUserApproved(id string) (bool, error) {
	var userApproval model.UserApproval
	err := repo.database.First(&userApproval, "user_id = ?", strings.TrimSpace(id)).Error

	if err != nil {
		return false, err
	}

	return userApproval.IsApproved, nil
}

func (repo *UserRepositoryGorm) ChangeUserApprovalStatus(id string, isApproved bool) error {
	err := repo.database.Model(&model.UserApproval{}).Where("user_id = ?", id).Update("is_approved", isApproved).Error

	return err
}
