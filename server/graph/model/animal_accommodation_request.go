package model

type AnimalAccommodationRequest struct {
	AnimalID       string        `json:"-"`
	Animal         ShelterAnimal `json:"animal" gorm:"primaryKey;foreignKey:AnimalID;references:ID;OnDelete:SET NULL"`
	UserID         string        `json:"-"`
	User           User          `json:"user" gorm:"foreignKey:UserID;references:ID;OnDelete:SET NULL"`
	IsApproved     bool          `json:"is_approved" gorm:"type:boolean;not null;default:false"`
	ApprovedBy     string        `json:"-"`
	ApprovedByUser User          `json:"approved_by_user" gorm:"foreignKey:ApprovedBy;references:ID;OnDelete:SET NULL"`
}
