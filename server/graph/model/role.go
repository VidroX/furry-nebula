package model

type UserRole struct {
	Name        string `json:"roleName" gorm:"type:varchar(255);primarykey;not null"`
	Description string `json:"roleDescription" gorm:"type:text"`
}
