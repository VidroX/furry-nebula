package database

import (
	"github.com/VidroX/furry-nebula/graph/model"
	"gorm.io/gorm"
)

var defaultPage = 1
var defaultResultsPerPage = 10

type pagination struct {
	page           int
	resultsPerPage int
}

var defaultPagination = pagination{
	page:           defaultPage,
	resultsPerPage: defaultResultsPerPage,
}

func PaginationScope(apiPagination *model.Pagination) func(db *gorm.DB) *gorm.DB {
	return func(db *gorm.DB) *gorm.DB {
		normalizedPagination := normalizePagination(apiPagination)

		offset := (normalizedPagination.page - 1) * normalizedPagination.resultsPerPage
		return db.Offset(offset).Limit(normalizedPagination.resultsPerPage)
	}
}

func GetPageInfo(total int64, apiPagination *model.Pagination) *model.PageInfo {
	normalizedPagination := normalizePagination(apiPagination)

	totalPages := total / (int64(normalizedPagination.page) * int64(normalizedPagination.resultsPerPage))
	hasNextPage := int64(normalizedPagination.page*normalizedPagination.resultsPerPage) < total
	hasPreviousPage := int64(normalizedPagination.page) <= totalPages && normalizedPagination.page > 1

	return &model.PageInfo{
		Page:            &normalizedPagination.page,
		ResultsPerPage:  &normalizedPagination.resultsPerPage,
		TotalResults:    &total,
		HasNextPage:     &hasNextPage,
		HasPreviousPage: &hasPreviousPage,
	}
}

func normalizePagination(apiPagination *model.Pagination) pagination {
	if apiPagination == nil {
		return defaultPagination
	}

	var normalizedPage = defaultPage
	var normalizedResultsPerPage = defaultResultsPerPage

	if apiPagination.Page != nil {
		normalizedPage = *apiPagination.Page
	}

	if apiPagination.ResultsPerPage != nil {
		normalizedResultsPerPage = *apiPagination.ResultsPerPage
	}

	if normalizedPage <= 0 {
		normalizedPage = 1
	}

	if normalizedResultsPerPage <= 0 {
		normalizedResultsPerPage = defaultResultsPerPage
	}

	return pagination{
		page:           normalizedPage,
		resultsPerPage: normalizedResultsPerPage,
	}
}
