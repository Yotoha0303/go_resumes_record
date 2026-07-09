package app

import (
	"net/http"

	"go-resumes-record/config"
	"go-resumes-record/pkg/database"
	"go-resumes-record/router"

	"gorm.io/gorm"
)

type Deps struct {
	Config      *config.Config
	DB          *gorm.DB
	HTTPHandler http.Handler
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

	httpHandler := router.SetRouter(db)

	return &Deps{
		Config:      cfg,
		DB:          db,
		HTTPHandler: httpHandler,
	}, nil
}
