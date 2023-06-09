package database

import (
	"log"
	"os"
	"strings"

	"github.com/VidroX/furry-nebula/graph/model"
	"github.com/VidroX/furry-nebula/services/environment"
	sUtils "github.com/VidroX/furry-nebula/utils/string_utils"
	"github.com/alexedwards/argon2id"
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

	log.Println("Successfully populated user roles!")
}

func (db *NebulaDb) CreateAdminUser() {
	email := os.Getenv(environment.KeysAdminEmail)
	password := os.Getenv(environment.KeysAdminPassword)
	if sUtils.IsEmpty(email) || sUtils.IsEmpty(password) {
		return
	}

	var count int64 = 0
	db.Model(&model.User{}).Count(&count)

	if count > 0 {
		return
	}

	hashed_password, _ := argon2id.CreateHash(password, argon2id.DefaultParams)

	adminUser := model.User{
		EMail:     strings.TrimSpace(email),
		FirstName: "Admin",
		LastName:  "User",
		Password:  hashed_password,
		Role: model.UserRole{
			Name: "Admin",
		},
	}

	db.Create(&adminUser)

	log.Println("Successfully created default admin user!")
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
