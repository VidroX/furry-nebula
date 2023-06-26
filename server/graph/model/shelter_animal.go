package model

type ShelterAnimal struct {
	ID          string     `json:"id" gorm:"type:uuid;primarykey;default:gen_random_uuid()"`
	ShelterID   string     `json:"-"`
	Shelter     Shelter    `json:"shelter" gorm:"foreignKey:ShelterID;references:ID;OnDelete:SET NULL"`
	AnimalType  string     `json:"-"`
	Animal      AnimalType `json:"animalType" gorm:"foreignKey:AnimalType;references:Name;OnDelete:SET NULL"`
	Name        string     `json:"name" gorm:"type:text;not null"`
	Description string     `json:"description" gorm:"type:text"`
	Photo       string     `json:"photo" gorm:"type:text"`
	Rating      float32    `json:"rating" validate:"gt=0,lte=5" gorm:"type:real"`
}
