package repositories

import (
	"github.com/VidroX/furry-nebula/repositories/shelter"
	"github.com/VidroX/furry-nebula/repositories/user"
	"github.com/VidroX/furry-nebula/services/database"
)

const Key = "Controller"

type Repositories struct {
	UserRepository    user.UserRepository
	ShelterRepository shelter.ShelterRepository
}

func Init() *Repositories {
	return &Repositories{
		UserRepository:    user.Get(database.Instance),
		ShelterRepository: shelter.Get(database.Instance),
	}
}
