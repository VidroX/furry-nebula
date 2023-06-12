package model

type UserApproval struct {
	UserId     string `json:"-"`
	User       User   `json:"user" gorm:"primarykey;foreignKey:UserId;references:ID;OnDelete:CASCADE"`
	IsApproved bool   `json:"isApproved"`
}
