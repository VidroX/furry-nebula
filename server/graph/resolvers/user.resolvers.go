package graph

// This file will be automatically regenerated based on the schema, any resolver implementations
// will be copied through when generating and any unknown code will be moved to the end.
// Code generated by github.com/99designs/gqlgen version v0.17.31

import (
	"context"
	"strings"

	generalErrors "github.com/VidroX/furry-nebula/errors/general"
	"github.com/VidroX/furry-nebula/errors/validation"
	"github.com/VidroX/furry-nebula/graph"
	"github.com/VidroX/furry-nebula/graph/model"
	"github.com/VidroX/furry-nebula/services/database"
	"github.com/VidroX/furry-nebula/services/translator"
)

// Login is the resolver for the login field.
func (r *mutationResolver) Login(ctx context.Context, email string, password string) (*model.UserWithToken, error) {
	gCtx := graph.GetGinContext(ctx)
	userService := gCtx.GetServices().UserService

	user, err := userService.Login(email, password)

	if err != nil && len(err) > 0 {
		graph.ProcessErrorsSlice(&ctx, gCtx.GetLocalizer(), err)

		return nil, nil
	}

	return user, nil
}

// Register is the resolver for the register field.
func (r *mutationResolver) Register(ctx context.Context, userInfo model.UserRegistrationInput) (*model.UserWithToken, error) {
	gCtx := graph.GetGinContext(ctx)
	userService := gCtx.GetServices().UserService

	user, err := userService.Register(userInfo)

	if err != nil && len(err) > 0 {
		graph.ProcessErrorsSlice(&ctx, gCtx.GetLocalizer(), err)

		return nil, nil
	}

	return user, nil
}

// ChangeUserApprovalStatus is the resolver for the changeUserApprovalStatus field.
func (r *mutationResolver) ChangeUserApprovalStatus(ctx context.Context, userID string, isApproved bool) (*model.ResponseMessage, error) {
	gCtx := graph.GetGinContext(ctx)
	user, err := gCtx.RequireUser(model.TokenTypeAccess)

	if err != nil {
		return nil, graph.FormatError(gCtx.GetLocalizer(), err)
	}

	if strings.EqualFold(user.ID, userID) {
		return nil, graph.FormatError(gCtx.GetLocalizer(), validation.ConstructValidationError(validation.ErrChangeOwnStatus, "userId"))
	}

	userService := gCtx.GetServices().UserService
	err = userService.ChangeUserApprovalStatus(userID, isApproved)

	if err != nil {
		return nil, graph.FormatError(gCtx.GetLocalizer(), err)
	}

	return &model.ResponseMessage{
		Message: translator.WithKey(translator.KeysUserServiceStatusChanged).Translate(gCtx.GetLocalizer()),
	}, nil
}

// UpdateFCMToken is the resolver for the updateFCMToken field.
func (r *mutationResolver) UpdateFCMToken(ctx context.Context, token string) (*model.User, error) {
	gCtx := graph.GetGinContext(ctx)
	user, err := gCtx.RequireUser(model.TokenTypeAccess)

	if err != nil {
		return nil, graph.FormatError(gCtx.GetLocalizer(), err)
	}

	userService := gCtx.GetServices().UserService
	user, err = userService.SetUserFCMToken(user.ID, token)

	return user, nil
}

// User is the resolver for the user field.
func (r *queryResolver) User(ctx context.Context) (*model.User, error) {
	gCtx := graph.GetGinContext(ctx)
	user, err := gCtx.RequireUser(model.TokenTypeAccess)

	if err != nil {
		return nil, graph.FormatError(gCtx.GetLocalizer(), err)
	}

	return user, nil
}

// Users is the resolver for the users field.
func (r *queryResolver) Users(ctx context.Context, pagination *model.Pagination) (*model.UsersConnection, error) {
	gCtx := graph.GetGinContext(ctx)
	userRepo := gCtx.GetRepositories().UserRepository

	users, total, err := userRepo.GetUsers(pagination)

	if err != nil {
		return nil, graph.FormatError(gCtx.GetLocalizer(), &generalErrors.ErrInternal)
	}

	return &model.UsersConnection{
		Node:     users,
		PageInfo: database.GetPageInfo(total, pagination),
	}, nil
}

// UserApprovals is the resolver for the userApprovals field.
func (r *queryResolver) UserApprovals(ctx context.Context, filters *model.ApprovalFilters, pagination *model.Pagination) (*model.UserApprovalsConnection, error) {
	gCtx := graph.GetGinContext(ctx)
	userRepo := gCtx.GetRepositories().UserRepository

	var approvals []*model.UserApproval
	var err error
	var total int64

	if filters != nil {
		approvals, total, err = userRepo.GetUserApprovals(filters.IsApproved, filters.IsReviewed, pagination)
	} else {
		approvals, total, err = userRepo.GetUserApprovals(nil, nil, pagination)
	}

	if err != nil {
		return nil, graph.FormatError(gCtx.GetLocalizer(), &generalErrors.ErrInternal)
	}

	var users []*model.User
	for _, approval := range approvals {
		users = append(users, &approval.User)
	}

	return &model.UserApprovalsConnection{
		Node:     users,
		PageInfo: database.GetPageInfo(total, pagination),
	}, nil
}

// Role is the resolver for the role field.
func (r *userResolver) Role(ctx context.Context, obj *model.User) (model.Role, error) {
	gCtx := graph.GetGinContext(ctx)
	role := model.Role(obj.RoleName)

	var err error
	if !role.IsValid() {
		err = graph.FormatError(gCtx.GetLocalizer(), &generalErrors.ErrInternal)
	}

	return role, err
}

// IsApproved is the resolver for the isApproved field.
func (r *userResolver) IsApproved(ctx context.Context, obj *model.User) (bool, error) {
	gCtx := graph.GetGinContext(ctx)
	userRepo := gCtx.GetRepositories().UserRepository

	isApproved, err := userRepo.IsUserApproved(obj.ID)

	if err != nil {
		return false, graph.FormatError(gCtx.GetLocalizer(), &generalErrors.ErrInternal)
	}

	return isApproved, nil
}

// User returns graph.UserResolver implementation.
func (r *Resolver) User() graph.UserResolver { return &userResolver{r} }

type userResolver struct{ *Resolver }
