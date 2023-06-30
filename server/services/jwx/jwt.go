package jwx

import (
	"log"
	"os"
	"strings"
	"time"

	"github.com/VidroX/furry-nebula/graph/model"
	"github.com/VidroX/furry-nebula/repositories/user"
	"github.com/VidroX/furry-nebula/services/environment"
	"github.com/lestrrat-go/jwx/v2/jwa"
	"github.com/lestrrat-go/jwx/v2/jwk"
	"github.com/lestrrat-go/jwx/v2/jwt"
)

const (
	UserContextKey string = "user"
)

func CreateUserToken(privateKey jwk.Key, tokenType model.TokenType, user *model.User) string {
	if tokenType != model.TokenTypeAccess && tokenType != model.TokenTypeRefresh {
		tokenType = model.TokenTypeAccess
	}

	issueTime := time.Now()

	builder := jwt.NewBuilder().
		Claim("typ", tokenType).
		Issuer(os.Getenv(environment.KeysTokenIssuer)).
		IssuedAt(issueTime).
		Subject(user.ID)

	if tokenType == model.TokenTypeRefresh {
		builder = builder.Expiration(issueTime.Add(time.Hour * 24 * 7))
	} else {
		builder = builder.Expiration(issueTime.Add(time.Minute * 15))
	}

	tok, err := builder.Build()

	if err != nil {
		log.Printf("Failed to build token for user %s (%s %s): %s\n", user.ID, user.FirstName, user.LastName, err)
		return ""
	}

	var rawPrivateKey interface{}
	_ = privateKey.Raw(&rawPrivateKey)

	signed, err := jwt.Sign(tok, jwt.WithKey(jwa.ES512, rawPrivateKey))

	if err != nil {
		log.Printf("Failed to sign token for user %s (%s %s): %s\n", user.ID, user.FirstName, user.LastName, err)
		return ""
	}

	return string(signed)
}

func GetUserFromToken(token string, publicKey jwk.Key, userRepo *user.UserRepository) *model.TokenizedUser {
	verifiedToken, tokenType := ValidateToken(token, publicKey)
	if verifiedToken == nil || tokenType == nil || verifiedToken.Expiration().Before(time.Now()) {
		return nil
	}

	dbUser, err := (*userRepo).GetUserById(verifiedToken.Subject())

	if err != nil {
		return nil
	}

	return &model.TokenizedUser{
		User:      dbUser,
		TokenType: *tokenType,
	}
}

func ValidateToken(token string, publicKey jwk.Key) (jwt.Token, *model.TokenType) {
	var rawPublicKey interface{}
	_ = publicKey.Raw(&rawPublicKey)

	normalizedToken := strings.TrimSpace(strings.TrimPrefix(token, "Bearer"))

	verifiedToken, err := jwt.Parse([]byte(normalizedToken), jwt.WithKey(jwa.ES512, rawPublicKey))
	if err != nil {
		if strings.EqualFold(os.Getenv(environment.KeysGinMode), "debug") {
			log.Printf("Failed to verify JWS (%s): %s\n", normalizedToken, err)
		}
		return nil, nil
	}

	tokenType, ok := verifiedToken.Get("typ")
	stringTokenType, ok2 := tokenType.(string)

	isValidTokenType := ok2 && (strings.EqualFold(stringTokenType, model.TokenTypeAccess.String()) ||
		strings.EqualFold(stringTokenType, model.TokenTypeRefresh.String()))
	isProperToken := ok && isValidTokenType

	if !isProperToken {
		return nil, nil
	}

	normalizedTokenType := model.TokenType(stringTokenType)

	return verifiedToken, &normalizedTokenType
}
