package model

type AnimalType struct {
	Name        string `json:"animalName" gorm:"type:varchar(255);primarykey;not null"`
	Description string `json:"animalDescription" gorm:"type:text"`
	PhotoUrl    string `json:"photo_url" gorm:"type:text"`
}

func GetAnimalTypeByGraphQLAnimal(animal Animal) (AnimalType, bool) {
	if !animal.IsValid() {
		return AnimalType{}, false
	}

	return AnimalType{
		Name: animal.String(),
	}, true
}
