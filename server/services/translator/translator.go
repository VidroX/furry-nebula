package translator

import (
	"encoding/json"
	"os"

	"github.com/VidroX/furry-nebula/services/environment"
	"github.com/nicksnyder/go-i18n/v2/i18n"
	"golang.org/x/text/language"
)

type Translation struct {
	Key    string
	Params map[string]string
}

type NebulaLocalizer struct {
	*i18n.Localizer
}

const Key string = "i18n"

func Init(langs ...string) NebulaLocalizer {
	bundle := i18n.NewBundle(language.English)
	bundle.RegisterUnmarshalFunc("json", json.Unmarshal)
	bundle.MustLoadMessageFile(os.Getenv(environment.KeysAppPath) + "/resources/i18n/en.json")
	bundle.MustLoadMessageFile(os.Getenv(environment.KeysAppPath) + "/resources/i18n/uk.json")

	return NebulaLocalizer{i18n.NewLocalizer(bundle, langs...)}
}

func WithKey(key string) *Translation {
	return &Translation{Key: key}
}

func WithParams(params map[string]string) *Translation {
	return &Translation{
		Params: params,
	}
}

func (translation *Translation) WithKey(key string) *Translation {
	return &Translation{
		Key:    key,
		Params: translation.Params,
	}
}

func (translation *Translation) WithParams(params map[string]string) *Translation {
	return &Translation{
		Key:    translation.Key,
		Params: params,
	}
}

func (translation *Translation) Translate(localizer *NebulaLocalizer) string {
	message, err := localizer.Localize(&i18n.LocalizeConfig{
		MessageID:    translation.Key,
		TemplateData: translation.Params,
	})

	if err != nil {
		return translation.Key
	}

	return message
}
