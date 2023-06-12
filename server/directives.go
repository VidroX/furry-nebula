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
	user, err := getUser(gCtx)

	if err != nil {
		return nil, graph.FormatError(gCtx.GetLocalizer(), err)
	}

	if user.User == nil || user.TokenType != model.TokenTypeAccess {
		return nil, graph.FormatError(gCtx.GetLocalizer(), &general_errors.ErrInvalidOrExpiredToken)
	}

	return next(ctx)
}

func refreshTokenOnlyDirective(ctx context.Context, obj interface{}, next graphql.Resolver) (interface{}, error) {
	gCtx := graph.GetGinContext(ctx)
	user, err := getUser(gCtx)

	if err != nil {
		return nil, graph.FormatError(gCtx.GetLocalizer(), err)
	}

	if user.User == nil || user.TokenType != model.TokenTypeRefresh {
		return nil, graph.FormatError(gCtx.GetLocalizer(), &general_errors.ErrInvalidOrExpiredToken)
	}

	return next(ctx)
}

func hasRoleDirective(ctx context.Context, obj interface{}, next graphql.Resolver, role model.Role) (interface{}, error) {
	gCtx := graph.GetGinContext(ctx)
	user, err := getUser(gCtx)

	if err != nil {
		return nil, graph.FormatError(gCtx.GetLocalizer(), err)
	}

	if user == nil || user.TokenType != model.TokenTypeAccess {
		return nil, graph.FormatError(gCtx.GetLocalizer(), &general_errors.ErrInvalidOrExpiredToken)
	}

	if !user.User.HasRole(role) {
		return nil, graph.FormatError(gCtx.GetLocalizer(), &general_errors.ErrNotEnoughPermissions)
	}

	return next(ctx)
}

func noUserOnlyDirective(ctx context.Context, obj interface{}, next graphql.Resolver) (interface{}, error) {
	gCtx := graph.GetGinContext(ctx)
	user, _ := getUser(gCtx)

	if user != nil {
		return nil, graph.FormatError(gCtx.GetLocalizer(), &general_errors.ErrNotEnoughPermissions)
	}

	return next(ctx)
}

func approvedUserOnlyDirective(ctx context.Context, obj interface{}, next graphql.Resolver) (interface{}, error) {
	gCtx := graph.GetGinContext(ctx)
	user, err := getUser(gCtx)

	if err != nil {
		return nil, graph.FormatError(gCtx.GetLocalizer(), err)
	}

	if user == nil || user.TokenType != model.TokenTypeAccess {
		return nil, graph.FormatError(gCtx.GetLocalizer(), &general_errors.ErrInvalidOrExpiredToken)
	}

	isApproved, err2 := gCtx.GetRepositories().UserRepository.IsUserApproved(user.User.ID)

	if !isApproved || err2 != nil {
		return nil, graph.FormatError(gCtx.GetLocalizer(), &general_errors.ErrNotEnoughPermissions)
	}

	return next(ctx)
}

func getUser(ctx *graph.ExtendedContext) (*model.TokenizedUser, *nebula_errors.APIError) {
	user, ok := ctx.Get(jwx.UserContextKey)

	if user == nil || !ok {
		return nil, &general_errors.ErrNotEnoughPermissions
	}

	if _, ok := user.(*model.TokenizedUser); !ok {
		return nil, &general_errors.ErrNotEnoughPermissions
	}

	normalizedUser := user.(*model.TokenizedUser)

	return &model.TokenizedUser{
		User:      normalizedUser.User,
		TokenType: normalizedUser.TokenType,
	}, nil
}
