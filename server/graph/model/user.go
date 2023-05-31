package model

import (
	"strings"
)

type User struct {
	ID        string `json:"id" gorm:"type:uuid;primarykey;default:gen_random_uuid()"`
	FirstName string `json:"firstName"`
	LastName  string `json:"lastName"`
	RoleName  string
	Role      UserRole `json:"role" gorm:"foreignKey:RoleName;references:Name;OnDelete:SET NULL"`
}

func (user *User) HasRole(userRole Role) bool {
	return Role(user.Role.Name).IsValid() &&
		userRole.IsValid() &&
		strings.EqualFold(user.Role.Name, userRole.String())
}
