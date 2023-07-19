package model

import (
	"time"
)

type User struct {
	ID               string    `json:"id" gorm:"type:uuid;primarykey;default:gen_random_uuid()"`
	EMail            string    `json:"email" validate:"required,gt=0,email" gorm:"column:email;uniqueIndex"`
	FirstName        string    `json:"firstName" validate:"required,gt=0"`
	LastName         string    `json:"lastName" validate:"required,gt=0"`
	About            string    `json:"about"`
	Birthday         time.Time `json:"birthday" validate:"required"`
	RoleName         string    `json:"-"`
	Role             UserRole  `json:"role" gorm:"foreignKey:RoleName;references:Name;OnDelete:SET NULL"`
	Password         string    `json:"-" validate:"required,gte=6"`
	RegistrationDate time.Time `json:"registrationDate" gorm:"not null;default:current_timestamp"`
	FCMToken         *string   `json:"fcmToken" gorm:"default:NULL"`
}

type TokenizedUser struct {
	User      *User     `json:"user"`
	TokenType TokenType `json:"tokenType"`
}

var rolePower = map[Role]int{
	RoleUser:    1,
	RoleShelter: 2,
	RoleAdmin:   100,
}

func (user *User) HasRole(userRole Role) bool {
	dbRole := Role(user.RoleName)
	isValidRole := dbRole.IsValid() &&
		userRole.IsValid() &&
		rolePower[dbRole] >= rolePower[userRole]

	return isValidRole
}
