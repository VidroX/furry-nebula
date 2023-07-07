package model

import "time"

type Shelter struct {
	ID                 string    `json:"id" gorm:"type:uuid;primarykey;default:gen_random_uuid()"`
	RepresentativeID   string    `json:"-"`
	RepresentativeUser User      `json:"representativeUser" validate:"-" gorm:"foreignKey:RepresentativeID;references:ID;OnDelete:SET NULL"`
	Name               string    `json:"name" gorm:"type:text;uniqueIndex;not null"`
	Address            string    `json:"address" gorm:"type:text;not null"`
	Info               string    `json:"info" gorm:"type:text"`
	Photo              *string   `json:"photo" gorm:"type:text"`
	AddDatetime        time.Time `json:"addDatetime" gorm:"not null;default:current_timestamp"`
	Deleted            bool      `json:"deleted" gorm:"type:boolean;default:false;not null"`
}
