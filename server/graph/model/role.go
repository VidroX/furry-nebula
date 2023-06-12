package model

type UserRole struct {
	Name        string `json:"roleName" gorm:"type:varchar(255);primarykey;not null"`
	Description string `json:"roleDescription" gorm:"type:text"`
}

var DefaultUserRole = UserRole{
	Name: RoleUser.String(),
}

func GetUserRoleByRole(role Role) (UserRole, bool) {
	if !role.IsValid() {
		return UserRole{}, false
	}

	return UserRole{
		Name: role.String(),
	}, true
}
