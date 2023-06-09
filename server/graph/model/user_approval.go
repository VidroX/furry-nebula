package model

type UserApproval struct {
	UserId     string `json:"-"`
	User       User   `json:"user" gorm:"foreignKey:UserId;references:ID;uniqueIndex;OnDelete:CASCADE"`
	IsApproved bool   `json:"isApproved"`
}
