package model

import "time"

type AnimalAccommodationRequest struct {
	AnimalID       string        `json:"-"`
	Animal         ShelterAnimal `json:"animal" gorm:"primaryKey;foreignKey:AnimalID;references:ID;OnDelete:SET NULL"`
	UserID         string        `json:"-"`
	User           User          `json:"user" gorm:"foreignKey:UserID;references:ID;OnDelete:SET NULL"`
	IsApproved     bool          `json:"isApproved" gorm:"type:boolean;not null;default:false"`
	IsReviewed     bool          `json:"isReviewed" gorm:"type:boolean;default:false;not null"`
	FromDate       time.Time     `json:"fromDate" gorm:"not null;default:current_timestamp"`
	ToDate         time.Time     `json:"toDate" gorm:"not null;default:current_timestamp"`
	ApprovedBy     string        `json:"-"`
	ApprovedByUser User          `json:"approvedByUser" gorm:"foreignKey:ApprovedBy;references:ID;OnDelete:SET NULL"`
	AddDatetime    time.Time     `json:"addDatetime" gorm:"not null;default:current_timestamp"`
}
