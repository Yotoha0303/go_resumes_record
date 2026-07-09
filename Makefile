.DEFAULT_GOAL:=help

GOOSE ?= goose
MIGRATIONS_DIR ?= migrations
DB_HOST ?= 127.0.0.1
DB_PORT ?= 3306
DB_USER ?= root
DB_NAME ?= go_resumes_record
MIGRATION_DSN ?= $(DB_USER):$(MYSQL_PASSWORD)@tcp($(DB_HOST):$(DB_PORT))/$(DB_NAME)?parseTime=true

.PHONY:help migrate-validate migrate-status migrate-up run

help:
	@echo Target: make target
	@echo help    Show command
	@echo run     run the application locally
	@echo Migrate
	@echo migrate-validate  validate mysql migrate
	@echo migrate-status    query mysql migrate status
	@echo migrate-up		migrate create mysql 


migrate-validate:
	$(GOOSE) -dir "$(MIGRATIONS_DIR)" validate

migrate-status:
	@$(GOOSE) -dir "$(MIGRATIONS_DIR)" mysql "$(MIGRATION_DSN)" status

migrate-up:
	@$(GOOSE) -dir "$(MIGRATIONS_DIR)" mysql "$(MIGRATION_DSN)" up

run:
	go run ./cmd