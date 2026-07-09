package dao

import (
	"go-resumes-record/internal/model"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func CreateWorkInfoRecord(ctx *gin.Context, db *gorm.DB, workInfoRecord model.WorkInfoRecord) error {
	return db.WithContext(ctx).Create(&workInfoRecord).Error
}

func GetWorkInfoRecordByID(ctx *gin.Context, db *gorm.DB, id int64) (*model.WorkInfoRecord, error) {
	var workInfoRecord model.WorkInfoRecord
	return &workInfoRecord, db.WithContext(ctx).Where("id = ?", id).First(&workInfoRecord).Error
}
