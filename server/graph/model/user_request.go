package model

import "time"

type UserRequest struct {
	ID               string            `json:"id" gorm:"type:uuid;primarykey;default:gen_random_uuid()"`
	AnimalID         string            `json:"-"`
	Animal           ShelterAnimal     `json:"animal" validate:"-" gorm:"foreignKey:AnimalID;references:ID;OnDelete:SET NULL"`
	UserID           string            `json:"-"`
	User             User              `json:"user" validate:"-" gorm:"foreignKey:UserID;references:ID;OnDelete:SET NULL"`
	RequestType      UserRequestType   `json:"requestType"`
	RequestStatus    UserRequestStatus `json:"requestStatus" gorm:"default:Pending"`
	FromDate         *time.Time        `json:"fromDate"`
	ToDate           *time.Time        `json:"toDate"`
	ApprovedByUserID *string           `json:"-"`
	ApprovedBy       *User             `json:"approvedByUser" validate:"-" gorm:"foreignKey:ApprovedByUserID;references:ID;OnDelete:SET NULL;default:null"`
	AddDatetime      time.Time         `json:"addDatetime" gorm:"not null;default:current_timestamp"`
}
