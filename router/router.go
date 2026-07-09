package router

import (
	"go-resumes-record/internal/handler"
	"go-resumes-record/internal/response"
	"go-resumes-record/internal/server"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type Handler struct {
	WorkInforRecordHandler *handler.WorkInfoRecordHandler
}

func SetRouter(db *gorm.DB) *gin.Engine {
	r := gin.New()

	r.Use(gin.Logger(), gin.Recovery())

	workInfoRecordServer := server.NewWorkInfoRecord(db)
	workInforRecordHandler := handler.NewWorkInfoRecordHandler(workInfoRecordServer)

	handler := Handler{
		WorkInforRecordHandler: workInforRecordHandler,
	}
	registerWorkInfoRecordRoutersAPI(r, handler)
	registerHealthRoutesAPI(r)
	return r
}

func registerHealthRoutesAPI(r *gin.Engine) {
	r.GET("/ping", func(c *gin.Context) {
		response.Success(c, nil)
	})
}

func registerWorkInfoRecordRoutersAPI(r *gin.Engine, handler Handler) {
	r.POST("/work", handler.WorkInforRecordHandler.CreateWorkInfoRecordHandler)
}
