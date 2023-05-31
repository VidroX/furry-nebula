package repositories

import (
	"github.com/VidroX/furry-nebula/repositories/user"
	"github.com/VidroX/furry-nebula/services/database"
)

const Key = "Controller"

type Repositories struct {
	UserRepository user.UserRepository
}

func Init() *Repositories {
	return &Repositories{
		UserRepository: user.Get(database.Instance),
	}
}
