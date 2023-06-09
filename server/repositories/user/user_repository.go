package user

import (
	"github.com/VidroX/furry-nebula/graph/model"
	"github.com/VidroX/furry-nebula/services/database"
)

type UserRepository interface {
	GetUserById(id string) (*model.User, error)
	GetUserByEmail(email string) (*model.User, error)
}

func Get(database *database.NebulaDb) UserRepository {
	return &UserRepositoryGorm{
		database,
	}
}
