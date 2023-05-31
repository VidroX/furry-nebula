package database

import (
	"log"
	"os"

	"github.com/VidroX/furry-nebula/graph/model"
	"github.com/VidroX/furry-nebula/services/environment"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type NebulaDb struct {
	*gorm.DB
}

func (db *NebulaDb) AutoMigrateAll() {
	db.AutoMigrate(
		&model.UserRole{},
		&model.User{},
	)
}

func (db *NebulaDb) PopulateRoles() {
	for _, userRole := range model.AllRole {
		dbRole := model.UserRole{}
		db.First(&dbRole, "name = ?", userRole.String())

		if len(dbRole.Name) > 0 {
			continue
		}

		dbRole.Name = userRole.String()

		db.Create(&dbRole)
	}
}

var Instance *NebulaDb

func Init() *NebulaDb {
	gormDB, err := gorm.Open(postgres.Open(os.Getenv(environment.KeysDSN)), &gorm.Config{})

	if err != nil {
		log.Fatalf("Unable to connect to the Database: %v", err)
	}

	Instance = &NebulaDb{gormDB}

	log.Println("Successfully connected to the Database!")

	return Instance
}
