package environment

import (
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/joho/godotenv"
)

type EnvironmentParams struct {
	BasePath string
}

func LoadEnvironment(params *EnvironmentParams) {
	environment := os.Getenv(KeysEnvironmentType)

	if params == nil {
		params = &EnvironmentParams{
			BasePath: "",
		}
	}

	var err error = nil
	var envName string

	if len(strings.TrimSpace(environment)) == 0 {
		envName = "data/.env"
		err = godotenv.Load(params.BasePath + envName)
	} else {
		envName = fmt.Sprintf("data/%s.env", strings.TrimSpace(environment))
		err = godotenv.Load(params.BasePath + envName)
	}

	if err != nil {
		log.Printf("Error loading .env file (%s)", envName)
	}

	var path string

	if len(strings.TrimSpace(params.BasePath)) == 0 {
		path, err = filepath.Abs("./")
	} else {
		path, err = filepath.Abs(params.BasePath + "/")
	}

	if err == nil {
		_ = os.Setenv(KeysAppPath, path)
	}
}
