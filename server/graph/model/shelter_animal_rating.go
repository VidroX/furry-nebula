package model

import "time"

type ShelterAnimalRating struct {
	ShelterAnimalID string        `json:"-"`
	ShelterAnimal   ShelterAnimal `json:"shelterAnimal" gorm:"primaryKey;foreignKey:ShelterAnimalID;references:ID;OnDelete:SET NULL"`
	UserID          string        `json:"-"`
	User            User          `json:"user" gorm:"primaryKey;foreignKey:UserID;references:ID;OnDelete:SET NULL"`
	Rating          float64       `json:"rating" validate:"gt=0,lte=5" gorm:"type:real"`
	AddDatetime     time.Time     `json:"addDatetime" gorm:"not null;default:current_timestamp"`
}
