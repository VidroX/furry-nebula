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
}

func isAuthenticatedDirective(ctx context.Context, obj interface{}, next graphql.Resolver) (interface{}, error) {
	gCtx := graph.GetGinContext(ctx)
	user, err := getUser(gCtx)

	if err != nil {
		return nil, graph.FormatError(gCtx.GetLocalizer(), err)
	}

	if user != nil {
		gCtx.Set(jwx.UserContextKey, user)
	}

	return next(ctx)
}

func hasRoleDirective(ctx context.Context, obj interface{}, next graphql.Resolver, role model.Role) (interface{}, error) {
	gCtx := graph.GetGinContext(ctx)
	user, err := getUser(gCtx)

	if err != nil {
		return nil, graph.FormatError(gCtx.GetLocalizer(), err)
	}

	if user != nil && !user.HasRole(role) {
		return nil, graph.FormatError(gCtx.GetLocalizer(), &general_errors.ErrNotEnoughPermissions)
	}

	gCtx.Set(jwx.UserContextKey, user)

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

	if user == nil {
		return nil, graph.FormatError(gCtx.GetLocalizer(), &general_errors.ErrNotEnoughPermissions)
	}

	isApproved, err2 := gCtx.GetRepositories().UserRepository.IsUserApproved(user.ID)

	if !isApproved || err2 != nil {
		return nil, graph.FormatError(gCtx.GetLocalizer(), &general_errors.ErrNotEnoughPermissions)
	}

	gCtx.Set(jwx.UserContextKey, user)

	return next(ctx)
}

func getUser(ctx *graph.ExtendedContext) (*model.User, *nebula_errors.APIError) {
	user, ok := ctx.Get(jwx.UserContextKey)

	if user == nil || !ok {
		return nil, &general_errors.ErrNotEnoughPermissions
	}

	if _, ok := user.(*model.User); !ok {
		return nil, &general_errors.ErrNotEnoughPermissions
	}

	return user.(*model.User), nil
}
