package app

import (
	"net/http"

	"go-resumes-record/config"
	"go-resumes-record/internal/handler"
	"go-resumes-record/internal/server"
	"go-resumes-record/pkg/database"
	"go-resumes-record/router"

	"gorm.io/gorm"
)

type Deps struct {
	Config      *config.Config
	DB          *gorm.DB
	HTTPHandler http.Handler
}

type Handler struct {
	WorkInforRecordHandler *handler.WorkInfoRecordHandler
}

func InitDeps() (*Deps, error) {
	config.LoadEnv()

	cfg, err := config.LoadConfig("config.yml")
	if err != nil {
		return nil, err
	}

	db, err := database.InitDB(cfg)
	if err != nil {
		return nil, err
	}

	workInfoRecordServer := server.NewWorkInfoRecord(db)
	workInforRecordHandler := handler.NewWorkInfoRecordHandler(workInfoRecordServer)

	handler := router.Handlers{
		WorkInforRecordHandler: workInforRecordHandler,
	}

	httpHandler := router.SetRouter(db, handler)

	return &Deps{
		Config:      cfg,
		DB:          db,
		HTTPHandler: httpHandler,
	}, nil
}
