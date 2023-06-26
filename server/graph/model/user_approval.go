package model

type UserApproval struct {
	UserId     string `json:"-"`
	User       User   `json:"user" gorm:"primarykey;foreignKey:UserId;references:ID;OnDelete:CASCADE"`
	IsApproved bool   `json:"isApproved"`
	IsReviewed bool   `json:"isReviewed" gorm:"type:boolean;default:false;not null"`
}
