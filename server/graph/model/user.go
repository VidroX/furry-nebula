package model

import (
	"strings"
)

type User struct {
	ID        string   `json:"id" gorm:"type:uuid;primarykey;default:gen_random_uuid()"`
	EMail     string   `json:"email" validate:"required,gt=0,email" gorm:"column:email;uniqueIndex"`
	FirstName string   `json:"firstName" validate:"required,gt=0"`
	LastName  string   `json:"lastName" validate:"required,gt=0"`
	About     string   `json:"about"`
	RoleName  string   `json:"-"`
	Role      UserRole `json:"role" gorm:"foreignKey:RoleName;references:Name;OnDelete:SET NULL"`
	Password  string   `json:"-" validate:"required,gte=6"`
}

type TokenizedUser struct {
	User      *User     `json:"user"`
	TokenType TokenType `json:"tokenType"`
}

func (user *User) HasRole(userRole Role) bool {
	return Role(user.RoleName).IsValid() &&
		userRole.IsValid() &&
		strings.EqualFold(user.RoleName, userRole.String())
}
