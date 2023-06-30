package graph

import (
	"fmt"
	"github.com/99designs/gqlgen/graphql"
	nebulaErrors "github.com/VidroX/furry-nebula/errors"
	"github.com/VidroX/furry-nebula/errors/general"
	"github.com/VidroX/furry-nebula/errors/validation"
	"github.com/VidroX/furry-nebula/graph/model"
	"github.com/VidroX/furry-nebula/services/environment"
	"github.com/google/uuid"
	"io"
	"os"
	"path/filepath"
)

func ProcessGraphPhotoUpload(ctx *ExtendedContext, user *model.User, upload *graphql.Upload) (fileLocation *string, error *nebulaErrors.APIError) {
	if upload == nil {
		return nil, nil
	}

	if !IsImageTypeSupported(upload.ContentType) {
		return nil, validation.ConstructValidationError(validation.ErrInvalidFileFormat, "photo")
	}

	file := upload.File
	extension := filepath.Ext(upload.Filename)
	newFileName := uuid.New().String() + extension

	fileContent, err := io.ReadAll(file)

	if err != nil {
		return nil, validation.ConstructValidationError(validation.ErrCorruptedFile, "photo")
	}

	uploadsPath, err := filepath.Abs(filepath.Join(os.Getenv(environment.KeysAppPath), os.Getenv(environment.KeysUploadsLocation)))

	if err != nil {
		return nil, &general.ErrInternal
	}

	var userFolder = uploadsPath

	if user != nil {
		userFolder = filepath.Join(uploadsPath, fmt.Sprintf("%s/", user.ID))
	}

	err = os.MkdirAll(userFolder, os.ModePerm)

	uploadsFilePath := filepath.Join(userFolder, newFileName)

	f, err := os.Create(uploadsFilePath)

	if err != nil {
		return nil, &general.ErrInternal
	}

	_, err = f.Write(fileContent)

	if err != nil {
		return nil, &general.ErrInternal
	}

	fileUrl := fmt.Sprintf("%s%s", getUploadsUrl(ctx, user), newFileName)

	return &fileUrl, nil
}

func getUploadsUrl(ctx *ExtendedContext, user *model.User) string {
	scheme := "http://"

	if ctx.Request.TLS != nil {
		scheme = "https://"
	}

	var userFolder = "/"
	if user != nil {
		userFolder = fmt.Sprintf("/%s/", user.ID)
	}

	return fmt.Sprintf("%s%s%s%s", scheme, ctx.Request.Host, "/uploads", userFolder)
}

func IsImageTypeSupported(contentType string) bool {
	switch contentType {
	case
		"image/jpeg",
		"image/png",
		"image/webp",
		"image/avif":
		return true
	}

	return false
}
