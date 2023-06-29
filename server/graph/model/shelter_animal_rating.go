package model

type ShelterAnimalRating struct {
	ShelterAnimalID string        `json:"-"`
	ShelterAnimal   ShelterAnimal `json:"shelterAnimal" gorm:"primarykey;foreignKey:ShelterAnimalID;references:ID;OnDelete:SET NULL"`
	UserID          string        `json:"-"`
	User            User          `json:"user" gorm:"foreignKey:UserID;references:ID;OnDelete:SET NULL"`
	Rating          float32       `json:"rating" validate:"gt=0,lte=5" gorm:"type:real"`
}
