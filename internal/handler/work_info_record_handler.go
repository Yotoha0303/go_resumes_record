package handler

import (
	"go-resumes-record/internal/request"
	"go-resumes-record/internal/response"
	"go-resumes-record/internal/server"
	"net/http"

	"github.com/gin-gonic/gin"
)

type WorkInfoRecordServer interface {
	CreateWorkInfoRecord(ctx *gin.Context, req request.CreateWorkInfoRecordRequest) error
}

type WorkInfoRecordHandler struct {
	workInfoRecordServer WorkInfoRecordServer
}

func NewWorkInfoRecordHandler(workInfoRecordServer WorkInfoRecordServer) *WorkInfoRecordHandler {
	return &WorkInfoRecordHandler{
		workInfoRecordServer: workInfoRecordServer,
	}
}

var _ WorkInfoRecordServer = (*server.WorkInfoRecordServer)(nil)

func (w *WorkInfoRecordHandler) CreateWorkInfoRecordHandler(c *gin.Context) {
	var req request.CreateWorkInfoRecordRequest
	if err := c.ShouldBindBodyWithJSON(&req); err != nil {
		response.Fail(c, http.StatusNotFound, response.CodeParameterFailed, "request parameter failed")
		return
	}

	if err := w.workInfoRecordServer.CreateWorkInfoRecord(c, req); err != nil {
		response.Fail(c, http.StatusInternalServerError, response.CodeCreateWorkInfoRecordFailed, "request parameter failed")
		return
	}
	response.Success(c, nil)
}
