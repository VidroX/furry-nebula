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
