package main

import (
	"context"

	"github.com/99designs/gqlgen/graphql"
	nebula_errors "github.com/VidroX/furry-nebula/errors"
	general_errors "github.com/VidroX/furry-nebula/errors/general"
	"github.com/VidroX/furry-nebula/graph"
	"github.com/VidroX/furry-nebula/graph/model"
	"github.com/VidroX/furry-nebula/services/jwx"
)

var AppDirectives = graph.DirectiveRoot{
	HasRole:          hasRoleDirective,
	IsAuthenticated:  isAuthenticatedDirective,
	NoUserOnly:       noUserOnlyDirective,
	ApprovedUserOnly: approvedUserOnlyDirective,
	RefreshTokenOnly: refreshTokenOnlyDirective,
}

func isAuthenticatedDirective(ctx context.Context, obj interface{}, next graphql.Resolver) (interface{}, error) {
	gCtx := graph.GetGinContext(ctx)
	_, err := getUser(gCtx, model.TokenTypeAccess)

	if err != nil {
		return nil, graph.FormatError(gCtx.GetLocalizer(), err)
	}

	return next(ctx)
}

func refreshTokenOnlyDirective(ctx context.Context, obj interface{}, next graphql.Resolver) (interface{}, error) {
	gCtx := graph.GetGinContext(ctx)
	_, err := getUser(gCtx, model.TokenTypeRefresh)

	if err != nil {
		return nil, graph.FormatError(gCtx.GetLocalizer(), err)
	}

	return next(ctx)
}

func hasRoleDirective(ctx context.Context, obj interface{}, next graphql.Resolver, role model.Role) (interface{}, error) {
	gCtx := graph.GetGinContext(ctx)
	user, err := getUser(gCtx, model.TokenTypeAccess)

	if err != nil {
		return nil, graph.FormatError(gCtx.GetLocalizer(), err)
	}

	if !user.User.HasRole(role) {
		return nil, graph.FormatError(gCtx.GetLocalizer(), &general_errors.ErrNotEnoughPermissions)
	}

	return next(ctx)
}

func noUserOnlyDirective(ctx context.Context, obj interface{}, next graphql.Resolver) (interface{}, error) {
	gCtx := graph.GetGinContext(ctx)

	if isUserExists(gCtx) {
		return nil, graph.FormatError(gCtx.GetLocalizer(), &general_errors.ErrNotEnoughPermissions)
	}

	return next(ctx)
}

func approvedUserOnlyDirective(ctx context.Context, obj interface{}, next graphql.Resolver) (interface{}, error) {
	gCtx := graph.GetGinContext(ctx)
	user, err := getUser(gCtx, model.TokenTypeAccess)

	if err != nil {
		return nil, graph.FormatError(gCtx.GetLocalizer(), err)
	}

	isApproved, err2 := gCtx.GetRepositories().UserRepository.IsUserApproved(user.User.ID)

	if !isApproved || err2 != nil {
		return nil, graph.FormatError(gCtx.GetLocalizer(), &general_errors.ErrNotEnoughPermissions)
	}

	return next(ctx)
}

func getUser(ctx *graph.ExtendedContext, tokenType model.TokenType) (*model.TokenizedUser, *nebula_errors.APIError) {
	user, ok := ctx.Get(jwx.UserContextKey)

	if _, ok := user.(*model.TokenizedUser); !ok {
		return nil, &general_errors.ErrInvalidOrExpiredToken
	}

	normalizedUser := user.(*model.TokenizedUser)

	if normalizedUser.User == nil || normalizedUser.TokenType != tokenType {
		return nil, &general_errors.ErrInvalidOrExpiredToken
	}

	if user == nil || !ok {
		return nil, &general_errors.ErrNotEnoughPermissions
	}

	return &model.TokenizedUser{
		User:      normalizedUser.User,
		TokenType: normalizedUser.TokenType,
	}, nil
}

func isUserExists(ctx *graph.ExtendedContext) bool {
	user, ok := ctx.Get(jwx.UserContextKey)

	if user == nil || !ok {
		return false
	}

	if _, ok := user.(*model.TokenizedUser); !ok {
		return false
	}

	return true
}
