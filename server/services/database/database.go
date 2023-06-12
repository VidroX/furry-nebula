package database

import (
	"log"
	"os"
	"strings"

	"github.com/VidroX/furry-nebula/graph/model"
	"github.com/VidroX/furry-nebula/services/environment"
	. "github.com/VidroX/furry-nebula/utils"
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
		&model.UserApproval{},
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

		err := db.Create(&dbRole).Error

		if err != nil {
			log.Fatalf("Unable to populate user roles. Error: %v", err)
			return
		}
	}

	log.Println("Successfully populated user roles!")
}

func (db *NebulaDb) CreateAdminUser() {
	email := os.Getenv(environment.KeysAdminEmail)
	password := os.Getenv(environment.KeysAdminPassword)
	if UtilString(email).IsEmpty() || UtilString(password).IsEmpty() {
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

	err := db.Create(&adminUser).Error

	if err != nil {
		log.Fatalf("Unable to create default admin user. Error: %v", err)
		return
	}

	adminUserApproval := model.UserApproval{
		User:       adminUser,
		IsApproved: true,
	}

	err = db.Create(&adminUserApproval).Error

	if err != nil {
		log.Fatalf("Unable to approve default admin user. Error: %v", err)
		return
	}

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
