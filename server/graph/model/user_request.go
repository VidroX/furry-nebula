package model

import "time"

type UserRequest struct {
	ID               string          `json:"id" gorm:"type:uuid;primarykey;default:gen_random_uuid()"`
	AnimalID         string          `json:"-"`
	Animal           ShelterAnimal   `json:"animal" validate:"-" gorm:"foreignKey:AnimalID;references:ID;OnDelete:SET NULL"`
	UserID           string          `json:"-"`
	User             User            `json:"user" validate:"-" gorm:"foreignKey:UserID;references:ID;OnDelete:SET NULL"`
	RequestType      UserRequestType `json:"requestType"`
	IsApproved       bool            `json:"isApproved" gorm:"type:boolean;not null;default:false"`
	IsReviewed       bool            `json:"isReviewed" gorm:"type:boolean;default:false;not null"`
	FromDate         *time.Time      `json:"fromDate"`
	ToDate           *time.Time      `json:"toDate"`
	ApprovedByUserID *string         `json:"-"`
	ApprovedBy       *User           `json:"approvedByUser" validate:"-" gorm:"foreignKey:ApprovedByUserID;references:ID;OnDelete:SET NULL;default:null"`
	IsFulfilled      bool            `json:"isFulfilled" gorm:"type:boolean;default:false;not null"`
	AddDatetime      time.Time       `json:"addDatetime" gorm:"not null;default:current_timestamp"`
}
