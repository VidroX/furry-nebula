package translator

import (
	"os"
	"testing"

	"github.com/VidroX/furry-nebula/services/environment"
	"github.com/stretchr/testify/assert"
)

func TestMain(m *testing.M) {
	if len(os.Getenv("ENVIRONMENT_TYPE")) <= 0 {
		_ = os.Setenv("ENVIRONMENT_TYPE", "dev")
	}
	environment.LoadEnvironment(&environment.EnvironmentParams{BasePath: "../../"})

	os.Exit(m.Run())
}

func TestTranslatorTranslation(t *testing.T) {
	localizer := Init("en")

	assert.NotNil(t, localizer)

	translation := WithKey(KeysTest).Translate(&localizer)

	assert.Equal(t, "Test", translation)

	localizer = Init("uk")

	assert.NotNil(t, localizer)

	translation = WithKey(KeysTest).Translate(&localizer)

	assert.Equal(t, "Тест", translation)
}
