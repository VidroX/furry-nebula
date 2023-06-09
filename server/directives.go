package main

import (
	"context"
	"fmt"

	"github.com/99designs/gqlgen/graphql"
	"github.com/VidroX/furry-nebula/graph"
	"github.com/VidroX/furry-nebula/graph/model"
	"github.com/VidroX/furry-nebula/services/jwx"
	"github.com/VidroX/furry-nebula/services/translator"
)

var AppDirectives = graph.DirectiveRoot{
	HasRole:         hasRoleDirective,
	IsAuthenticated: isAuthenticatedDirective,
	NoUserOnly:      noUserOnlyDirective,
}

func isAuthenticatedDirective(ctx context.Context, obj interface{}, next graphql.Resolver) (interface{}, error) {
	gCtx := graph.GetGinContext(ctx)
	user, err := getUser(gCtx)

	if err != nil {
		return nil, err
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
		return nil, err
	}

	if user != nil && !user.HasRole(role) {
		return nil, fmt.Errorf(translator.WithKey(translator.KeysNotEnoughPermissions).Translate(gCtx.GetLocalizer()))
	}

	gCtx.Set(jwx.UserContextKey, user)

	return next(ctx)
}

func noUserOnlyDirective(ctx context.Context, obj interface{}, next graphql.Resolver) (interface{}, error) {
	gCtx := graph.GetGinContext(ctx)
	user, _ := getUser(gCtx)

	if user != nil {
		return nil, fmt.Errorf(translator.WithKey(translator.KeysNotEnoughPermissions).Translate(gCtx.GetLocalizer()))
	}

	return next(ctx)
}

func getUser(ctx *graph.ExtendedContext) (*model.User, error) {
	_, public, err := jwx.ReadKeySet()

	if err != nil {
		return nil, fmt.Errorf(translator.WithKey(translator.KeysInternalError).Translate(ctx.GetLocalizer()))
	}

	user := jwx.GetUserFromToken(
		ctx.Request.Header.Get("Authorization"),
		public,
		&ctx.GetRepositories().UserRepository,
	)

	if user == nil {
		return nil, fmt.Errorf(translator.WithKey(translator.KeysNotEnoughPermissions).Translate(ctx.GetLocalizer()))
	}

	return user, nil
}
