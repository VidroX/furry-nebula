//go:build tools
// +build tools

package tools

import (
	_ "github.com/99designs/gqlgen"
	_ "github.com/DATA-DOG/go-sqlmock"
	_ "github.com/alexedwards/argon2id"
	_ "github.com/gin-gonic/gin"
	_ "github.com/joho/godotenv"
	_ "github.com/lestrrat-go/jwx/v2/jwa"
	_ "github.com/lestrrat-go/jwx/v2/jwk"
	_ "github.com/lestrrat-go/jwx/v2/jwt"
	_ "github.com/nicksnyder/go-i18n/v2/i18n"
	_ "github.com/stretchr/testify"
	_ "golang.org/x/exp/slices"
	_ "gorm.io/driver/postgres"
	_ "gorm.io/gorm"
)
