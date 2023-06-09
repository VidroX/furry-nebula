package model

import (
	"strings"
)

type User struct {
	ID        string   `json:"id" gorm:"type:uuid;primarykey;default:gen_random_uuid()"`
	EMail     string   `json:"email" gorm:"column:email"`
	FirstName string   `json:"firstName"`
	LastName  string   `json:"lastName"`
	RoleName  string   `json:"-"`
	Role      UserRole `json:"role" gorm:"foreignKey:RoleName;references:Name;OnDelete:SET NULL"`
	Password  string   `json:"-"`
}

func (user *User) HasRole(userRole Role) bool {
	return Role(user.Role.Name).IsValid() &&
		userRole.IsValid() &&
		strings.EqualFold(user.Role.Name, userRole.String())
}
