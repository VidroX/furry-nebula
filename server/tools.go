//go:build tools
// +build tools

package tools

import (
	_ "firebase.google.com/go"
	_ "firebase.google.com/go/messaging"
	_ "github.com/99designs/gqlgen"
	_ "github.com/DATA-DOG/go-sqlmock"
	_ "github.com/alexedwards/argon2id"
	_ "github.com/gin-contrib/cors"
	_ "github.com/gin-gonic/gin"
	_ "github.com/go-playground/validator/v10"
	_ "github.com/google/uuid"
	_ "github.com/jackc/pgerrcode"
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
