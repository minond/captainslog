package service

import (
	"context"
	"database/sql"

	"gopkg.in/src-d/go-kallax.v1"

	"github.com/minond/captainslog/model"
)

type ReportService struct {
	reportStore *model.ReportStore
}

func NewReportService(db *sql.DB) *ReportService {
	return &ReportService{
		reportStore: model.NewReportStore(db),
	}
}

type ReportRetrieveRequest struct {
	GUID *string `schema:"guid"`
}

type ReportRetrieveResponse struct {
	Reports []*model.Report `json:"reports"`
}

func (s ReportService) Retrieve(ctx context.Context, req *ReportRetrieveRequest) (*ReportRetrieveResponse, error) {
	userGUID, err := getUserGUID(ctx)
	if err != nil {
		return nil, err
	}

	query := model.NewReportQuery().
		Where(kallax.Eq(model.Schema.Report.UserFK, userGUID))

	// Retrieve a single report
	if req.GUID != nil {
		query.Where(kallax.Eq(model.Schema.Report.GUID, req.GUID))
	}

	reports, err := s.reportStore.FindAll(query)
	if err != nil {
		return nil, err
	}

	return &ReportRetrieveResponse{Reports: reports}, nil
}
