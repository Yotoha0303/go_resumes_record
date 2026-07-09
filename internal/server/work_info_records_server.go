package server

import (
	appError "go-resumes-record/internal/apperror"
	"go-resumes-record/internal/dao"
	"go-resumes-record/internal/model"
	"go-resumes-record/internal/request"
	"go-resumes-record/internal/response"
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type WorkInfoRecordServer struct {
	db *gorm.DB
}

func NewWorkInfoRecord(db *gorm.DB) *WorkInfoRecordServer {
	return &WorkInfoRecordServer{
		db: db,
	}
}

func (w *WorkInfoRecordServer) CreateWorkInfoRecord(ctx *gin.Context, req request.CreateWorkInfoRecordRequest) error {
	workInfoRecord := model.WorkInfoRecord{
		JobName:             req.JobName,
		CompanyName:         req.CompanyName,
		EducationBackground: model.EducationBackground(req.EducationBackground),
		Workplace:           req.Workplace,
	}
	err := dao.CreateWorkInfoRecord(ctx, w.db, workInfoRecord)
	if err != nil {
		return appError.New(
			http.StatusNotFound,
			response.CodeCreateWorkInfoRecordFailed,
			"create WorkInfoRecord failed",
		)
	}
	return nil
}
