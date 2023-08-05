package database

import (
	"log"
	"os"
	"strings"
	"time"

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
	err := db.AutoMigrate(
		&model.UserRole{},
		&model.User{},
		&model.UserApproval{},
		&model.AnimalType{},
		&model.Shelter{},
		&model.ShelterAnimal{},
		&model.ShelterAnimalRating{},
		&model.UserRequest{},
	)

	if err != nil {
		log.Fatalf("Unable to migrate database models: %s", err.Error())
	}
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

func (db *NebulaDb) PopulateAnimalTypes() {
	for _, animalType := range model.AllAnimal {
		dbAnimalType := model.AnimalType{}
		db.First(&dbAnimalType, "name = ?", animalType.String())

		if len(dbAnimalType.Name) > 0 {
			continue
		}

		dbAnimalType.Name = animalType.String()

		err := db.Create(&dbAnimalType).Error

		if err != nil {
			log.Fatalf("Unable to populate animal types. Error: %v", err)
			return
		}
	}

	log.Println("Successfully populated animal types!")
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

	hashedPassword, _ := argon2id.CreateHash(password, argon2id.DefaultParams)

	adminUser := model.User{
		EMail:     strings.TrimSpace(email),
		FirstName: "Admin",
		LastName:  "User",
		Birthday:  time.Now(),
		Password:  hashedPassword,
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
		IsReviewed: true,
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
