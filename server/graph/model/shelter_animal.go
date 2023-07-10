package model

import "time"

type ShelterAnimal struct {
	ID          string     `json:"id" gorm:"type:uuid;primarykey;default:gen_random_uuid()"`
	ShelterID   string     `json:"-"`
	Shelter     Shelter    `json:"shelter" validate:"-" gorm:"foreignKey:ShelterID;references:ID;OnDelete:SET NULL"`
	AnimalType  string     `json:"-"`
	Animal      AnimalType `json:"animalType" validate:"-" gorm:"foreignKey:AnimalType;references:Name;OnDelete:SET NULL"`
	Name        string     `json:"name" gorm:"type:text;not null"`
	Description string     `json:"description" gorm:"type:text"`
	Photo       *string    `json:"photo" gorm:"type:text"`
	AddDatetime time.Time  `json:"addDatetime" gorm:"not null;default:current_timestamp"`
	Removed     bool       `json:"removed" gorm:"type:boolean;default:false;not null"`
}
