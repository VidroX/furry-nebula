// Code generated by github.com/99designs/gqlgen, DO NOT EDIT.

package model

import (
	"fmt"
	"io"
	"strconv"
	"time"
)

// Filters for list of user approvals
type ApprovalFilters struct {
	IsApproved *bool `json:"isApproved,omitempty"`
}

// Page information
type PageInfo struct {
	Page            *int   `json:"page,omitempty"`
	ResultsPerPage  *int   `json:"resultsPerPage,omitempty"`
	TotalResults    *int64 `json:"totalResults,omitempty"`
	HasNextPage     *bool  `json:"hasNextPage,omitempty"`
	HasPreviousPage *bool  `json:"hasPreviousPage,omitempty"`
}

// Pagination filters
type Pagination struct {
	Page           *int `json:"page,omitempty"`
	ResultsPerPage *int `json:"resultsPerPage,omitempty"`
}

// Simple response with message
type ResponseMessage struct {
	Message string `json:"message"`
}

// Auth token
type Token struct {
	Type  TokenType `json:"type"`
	Token string    `json:"token"`
}

// User approvals connection
type UserApprovalsConnection struct {
	Node     []*User   `json:"node"`
	PageInfo *PageInfo `json:"pageInfo"`
}

// Registration input data for User
type UserRegistrationInput struct {
	FirstName string            `json:"firstName"`
	LastName  string            `json:"lastName"`
	Birthday  time.Time         `json:"birthday"`
	Email     string            `json:"email"`
	About     *string           `json:"about,omitempty"`
	Password  string            `json:"password"`
	Role      *RegistrationRole `json:"role,omitempty"`
}

// Messaged response with User and its auth tokens
type UserWithToken struct {
	Message      string `json:"message"`
	User         *User  `json:"user,omitempty"`
	AccessToken  *Token `json:"accessToken,omitempty"`
	RefreshToken *Token `json:"refreshToken,omitempty"`
}

// Users list connection
type UsersConnection struct {
	Node     []*User   `json:"node"`
	PageInfo *PageInfo `json:"pageInfo"`
}

// Animal types
type Animal string

const (
	AnimalCat    Animal = "Cat"
	AnimalDog    Animal = "Dog"
	AnimalRabbit Animal = "Rabbit"
	AnimalBird   Animal = "Bird"
)

var AllAnimal = []Animal{
	AnimalCat,
	AnimalDog,
	AnimalRabbit,
	AnimalBird,
}

func (e Animal) IsValid() bool {
	switch e {
	case AnimalCat, AnimalDog, AnimalRabbit, AnimalBird:
		return true
	}
	return false
}

func (e Animal) String() string {
	return string(e)
}

func (e *Animal) UnmarshalGQL(v interface{}) error {
	str, ok := v.(string)
	if !ok {
		return fmt.Errorf("enums must be strings")
	}

	*e = Animal(str)
	if !e.IsValid() {
		return fmt.Errorf("%s is not a valid Animal", str)
	}
	return nil
}

func (e Animal) MarshalGQL(w io.Writer) {
	fmt.Fprint(w, strconv.Quote(e.String()))
}

// Limited user roles for registration
type RegistrationRole string

const (
	RegistrationRoleShelter RegistrationRole = "Shelter"
	RegistrationRoleUser    RegistrationRole = "User"
)

var AllRegistrationRole = []RegistrationRole{
	RegistrationRoleShelter,
	RegistrationRoleUser,
}

func (e RegistrationRole) IsValid() bool {
	switch e {
	case RegistrationRoleShelter, RegistrationRoleUser:
		return true
	}
	return false
}

func (e RegistrationRole) String() string {
	return string(e)
}

func (e *RegistrationRole) UnmarshalGQL(v interface{}) error {
	str, ok := v.(string)
	if !ok {
		return fmt.Errorf("enums must be strings")
	}

	*e = RegistrationRole(str)
	if !e.IsValid() {
		return fmt.Errorf("%s is not a valid RegistrationRole", str)
	}
	return nil
}

func (e RegistrationRole) MarshalGQL(w io.Writer) {
	fmt.Fprint(w, strconv.Quote(e.String()))
}

// User Roles
type Role string

const (
	RoleAdmin   Role = "Admin"
	RoleShelter Role = "Shelter"
	RoleUser    Role = "User"
)

var AllRole = []Role{
	RoleAdmin,
	RoleShelter,
	RoleUser,
}

func (e Role) IsValid() bool {
	switch e {
	case RoleAdmin, RoleShelter, RoleUser:
		return true
	}
	return false
}

func (e Role) String() string {
	return string(e)
}

func (e *Role) UnmarshalGQL(v interface{}) error {
	str, ok := v.(string)
	if !ok {
		return fmt.Errorf("enums must be strings")
	}

	*e = Role(str)
	if !e.IsValid() {
		return fmt.Errorf("%s is not a valid Role", str)
	}
	return nil
}

func (e Role) MarshalGQL(w io.Writer) {
	fmt.Fprint(w, strconv.Quote(e.String()))
}

// Auth token types
type TokenType string

const (
	TokenTypeAccess  TokenType = "Access"
	TokenTypeRefresh TokenType = "Refresh"
)

var AllTokenType = []TokenType{
	TokenTypeAccess,
	TokenTypeRefresh,
}

func (e TokenType) IsValid() bool {
	switch e {
	case TokenTypeAccess, TokenTypeRefresh:
		return true
	}
	return false
}

func (e TokenType) String() string {
	return string(e)
}

func (e *TokenType) UnmarshalGQL(v interface{}) error {
	str, ok := v.(string)
	if !ok {
		return fmt.Errorf("enums must be strings")
	}

	*e = TokenType(str)
	if !e.IsValid() {
		return fmt.Errorf("%s is not a valid TokenType", str)
	}
	return nil
}

func (e TokenType) MarshalGQL(w io.Writer) {
	fmt.Fprint(w, strconv.Quote(e.String()))
}
