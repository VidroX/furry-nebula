package model

type Shelter struct {
	ID                 string  `json:"id" gorm:"type:uuid;primarykey;default:gen_random_uuid()"`
	RepresentativeID   string  `json:"-"`
	RepresentativeUser User    `json:"representativeUser" validate:"-" gorm:"foreignKey:RepresentativeID;references:ID;OnDelete:SET NULL"`
	Name               string  `json:"name" gorm:"type:text;uniqueIndex;not null"`
	Address            string  `json:"address" gorm:"type:text;not null"`
	Info               string  `json:"info" gorm:"type:text"`
	Photo              *string `json:"photo" gorm:"type:text"`
	Deleted            bool    `json:"deleted" gorm:"type:boolean;default:false;not null"`
}
