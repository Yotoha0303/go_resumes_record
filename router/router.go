package router

import (
	"go-resumes-record/internal/handler"
	"go-resumes-record/internal/response"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type Handlers struct {
	WorkInforRecordHandler *handler.WorkInfoRecordHandler
}

func SetRouter(db *gorm.DB, handler Handlers) *gin.Engine {
	r := gin.New()

	r.Use(gin.Logger(), gin.Recovery())

	registerWorkInfoRecordRoutersAPI(r, handler)
	registerHealthRoutesAPI(r)
	return r
}

func registerHealthRoutesAPI(r *gin.Engine) {
	r.GET("/ping", func(c *gin.Context) {
		response.Success(c, nil)
	})
}

func registerWorkInfoRecordRoutersAPI(r *gin.Engine, handler Handlers) {
	r.POST("/work", handler.WorkInforRecordHandler.CreateWorkInfoRecordHandler)
}
