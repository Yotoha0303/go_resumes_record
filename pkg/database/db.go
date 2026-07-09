package database

import (
	"errors"
	"fmt"
	"go-resumes-record/config"
	"os"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

func InitDB(cfg *config.Config) (*gorm.DB, error) {
	dsn, err := buildDSN(cfg)
	if err != nil {
		return nil, err
	}

	return openMySQL(dsn)
}

func buildDSN(cfg *config.Config) (string, error) {
	dbPassword := os.Getenv("MYSQL_PASSWORD")

	mysql := cfg.MySQL
	if dbPassword == "" || mysql.User == "" || mysql.Port == 0 || mysql.Database == "" || mysql.Host == "" {
		return "", errors.New("mysql config missing")
	}

	dsn := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=utf8mb4&parseTime=True&loc=Local", mysql.User, dbPassword, mysql.Host, mysql.Port, mysql.Database)
	return dsn, nil
}

func openMySQL(dsn string) (*gorm.DB, error) {
	return gorm.Open(mysql.New(mysql.Config{
		DSN: dsn,
	}))
}
